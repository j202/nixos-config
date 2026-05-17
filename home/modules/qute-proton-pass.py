#!/usr/bin/env python3
"""
qute-proton-pass: fill login forms in qutebrowser from Proton Pass.

Prerequisites: run `pass-cli login` once to authenticate.
Keybinds (set in qutebrowser.nix):
  ,p  — fill username + password (copies TOTP to clipboard if present)
  ,pu — copy username to clipboard
  ,pp — copy password to clipboard
  ,pt — copy current TOTP code to clipboard
"""

import base64
import hashlib
import hmac
import json
import os
import struct
import subprocess
import sys
import time
from urllib.parse import parse_qs, urlparse


def send(fifo, *cmds):
    with open(fifo, "a") as f:
        for cmd in cmds:
            f.write(cmd + "\n")


def run_cli(*args):
    result = subprocess.run(["pass-cli", *args], capture_output=True, text=True)
    if result.returncode != 0:
        stderr = " — ".join(result.stderr.strip().splitlines()) or "pass-cli exited non-zero"
        raise RuntimeError(stderr)
    return json.loads(result.stdout)


def extract_urls(item):
    try:
        raw = item["content"]["content"]["Login"]["urls"]
        if isinstance(raw, list):
            out = []
            for u in raw:
                if isinstance(u, str):
                    out.append(u)
                elif isinstance(u, dict):
                    out.append(u.get("url") or u.get("value") or "")
            return [u for u in out if u]
        if isinstance(raw, str) and raw:
            return [raw]
    except (KeyError, TypeError):
        pass
    return []


def host_matches(urls, target):
    for u in urls:
        h = urlparse(u).hostname or ""
        if h == target or target.endswith("." + h) or h.endswith("." + target):
            return True
    return False


def item_label(item):
    """Return 'Title (username)' for rofi — helps distinguish multiple accounts."""
    title = item.get("content", {}).get("title") or item.get("id", "Untitled")
    try:
        login = item["content"]["content"]["Login"]
        if isinstance(login, dict):
            user = login.get("username") or login.get("email") or ""
            if user:
                return f"{title} ({user})"
    except (KeyError, TypeError):
        pass
    return title


def rofi_pick(labels, prompt="Proton Pass"):
    r = subprocess.run(
        ["rofi", "-dmenu", "-i", "-p", f" {prompt}", "-no-custom"],
        input="\n".join(labels),
        capture_output=True,
        text=True,
    )
    return r.stdout.strip() if r.returncode == 0 else None


def totp_now(uri):
    """Generate the current TOTP code from an otpauth:// URI."""
    try:
        parsed = urlparse(uri)
        if parsed.scheme != "otpauth":
            return None
        params  = parse_qs(parsed.query)
        raw     = params.get("secret", [""])[0].upper()
        if not raw:
            return None
        secret  = base64.b32decode(raw + "=" * (-len(raw) % 8))
        period  = int(params.get("period", ["30"])[0])
        digits  = int(params.get("digits", ["6"])[0])
        counter = int(time.time()) // period
        h       = hmac.new(secret, struct.pack(">Q", counter), hashlib.sha1).digest()
        offset  = h[-1] & 0x0F
        code    = struct.unpack(">I", bytes([h[offset] & 0x7F]) + h[offset + 1:offset + 4])[0]
        return str(code % (10 ** digits)).zfill(digits)
    except Exception:
        return None


def clip(text):
    subprocess.run(["wl-copy"], input=text, text=True, check=True)


def js_fill_cmd(username, email, password):
    """Base64-encode the JS fill script to avoid FIFO quote-escaping issues.

    Passes both username and email; the injected JS inspects the input field's
    type/autocomplete/name to decide which value the page is actually asking for.
    """
    u_js = json.dumps(username)
    e_js = json.dumps(email)
    p_js = json.dumps(password)
    js = (
        "(function(){"
        "function fill(el,v){"
        "var s=Object.getOwnPropertyDescriptor(HTMLInputElement.prototype,'value').set;"
        "s.call(el,v);"
        "['input','change'].forEach(function(e){"
        "el.dispatchEvent(new Event(e,{bubbles:true}));});};"
        "var u=document.querySelector("
        "'input[autocomplete=username],input[autocomplete=email],"
        "input[type=email],input[name*=user],input[name*=email],"
        "input[id*=user],input[id*=email]');"
        "var p=document.querySelector('input[type=password]');"
        f"var uval={u_js},eval_={e_js};"
        "var wantsEmail=u&&(u.type==='email'||u.autocomplete==='email'"
        "||/email/i.test(u.name||'')||/email/i.test(u.id||''));"
        "if(u)fill(u,(wantsEmail&&eval_)?eval_:uval);"
        "if(p)fill(p," + p_js + ");"
        "})()"
    )
    b64 = base64.b64encode(js.encode()).decode()
    return f"jseval -q eval(atob('{b64}'))"


AUTH_KEYWORDS = ("auth", "login", "session", "sign", "unauthorized", "unauthenticated")


def looks_like_auth_error(msg):
    return any(w in msg.lower() for w in AUTH_KEYWORDS)


def notify_and_launch(fifo, msg):
    """Show a desktop notification and open a terminal to run pass-cli login."""
    send(fifo, f"message-error 'Proton Pass: {msg}'",
         "spawn --detach kitty -- pass-cli login")
    subprocess.run(
        ["notify-send", "-u", "normal", "-i", "dialog-password",
         "Proton Pass", "Not signed in — signing in via browser."],
        capture_output=True,
    )


def fetch_items(fifo):
    try:
        data = run_cli("item", "list", "--filter-type", "login", "--output", "json")
    except RuntimeError as e:
        msg = str(e)
        if looks_like_auth_error(msg):
            notify_and_launch(fifo, "not signed in")
        else:
            send(fifo, f"message-error 'Proton Pass: {msg}'")
        return None
    except json.JSONDecodeError:
        notify_and_launch(fifo, "not signed in")
        return None

    items = data.get("items", []) if isinstance(data, dict) else data
    if not isinstance(items, list):
        send(fifo, "message-error 'Proton Pass: unrecognised item list format'")
        return None
    return items


def pick_item(fifo, items, target):
    """Return selected item, or None if cancelled/empty."""
    url_matched = [i for i in items if host_matches(extract_urls(i), target)]
    candidates  = url_matched if url_matched else items

    if not candidates:
        send(fifo, "message-info 'Proton Pass: vault is empty'")
        return None

    if len(url_matched) == 1:
        return url_matched[0]

    label_map = {}
    for item in candidates:
        label_map[item_label(item)] = item

    choice = rofi_pick(list(label_map))
    if not choice:
        return None
    return label_map.get(choice)


def fetch_credentials(fifo, selected):
    item_id  = selected.get("id")
    share_id = selected.get("share_id") or selected.get("vault_id")

    if not item_id:
        send(fifo, "message-error 'Proton Pass: item has no ID'")
        return None

    view_args = ["item", "view", "--output", "json", "--item-id", item_id]
    if share_id:
        view_args += ["--share-id", share_id]

    try:
        full = run_cli(*view_args)
    except RuntimeError as e:
        send(fifo, f"message-error 'Proton Pass: {e}'")
        return None

    if isinstance(full, dict) and "item" in full:
        full = full["item"]

    try:
        return full["content"]["content"]["Login"]
    except (KeyError, TypeError):
        send(fifo, "message-error 'Proton Pass: unexpected item view structure'")
        return None


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "fill"
    fifo = os.environ.get("QUTE_FIFO", "")
    url  = os.environ.get("QUTE_URL", "")
    if not fifo:
        sys.exit(1)

    target = urlparse(url).hostname or ""

    items = fetch_items(fifo)
    if items is None:
        sys.exit(1)

    selected = pick_item(fifo, items, target)
    if selected is None:
        sys.exit(0)

    login = fetch_credentials(fifo, selected)
    if login is None:
        sys.exit(1)

    username = login.get("username") or ""
    email    = login.get("email") or ""
    password = login.get("password") or ""
    totp_uri = login.get("totp_uri") or ""
    title    = selected.get("content", {}).get("title") or selected.get("id", "")

    if not username and not email and not password:
        send(fifo, "message-error 'Proton Pass: no credentials in item'")
        sys.exit(1)

    if mode == "copy-username":
        clip(username or email)
        send(fifo, "message-info 'Proton Pass: username copied'")
    elif mode == "copy-password":
        clip(password)
        send(fifo, "message-info 'Proton Pass: password copied'")
    elif mode == "copy-totp":
        if not totp_uri:
            send(fifo, "message-error 'Proton Pass: item has no TOTP secret'")
            sys.exit(1)
        code = totp_now(totp_uri)
        if not code:
            send(fifo, "message-error 'Proton Pass: failed to generate TOTP code'")
            sys.exit(1)
        clip(code)
        send(fifo, "message-info 'Proton Pass: TOTP code copied'")
    else:
        send(fifo, js_fill_cmd(username, email, password))
        if totp_uri:
            code = totp_now(totp_uri)
            if code:
                clip(code)
                send(fifo, f"message-info 'Filled: {title} (TOTP copied)'")
                return
        send(fifo, f"message-info 'Filled: {title}'")


if __name__ == "__main__":
    main()
