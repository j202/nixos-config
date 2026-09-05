-- Generated values (mod key, noctalia-conditional commands, autostart list) come
-- from vars.lua, which is templated by Nix from home/modules/hyprland/wm.nix.
local vars = require("vars")

-- Autostart
hl.on("hyprland.start", function()
	for _, cmd in ipairs(vars.exec_once_commands) do
		hl.exec_cmd(cmd)
	end
end)

-- 1. Launchers
hl.bind(vars.mod .. " + Return", hl.dsp.exec_cmd("kitty"), { description = "Terminal" })
hl.bind(vars.mod .. " + F1", hl.dsp.exec_cmd(vars.cheatsheet_cmd), { description = "Keybind Cheatsheet" })
hl.bind(vars.mod .. " + slash", hl.dsp.exec_cmd(vars.cheatsheet_cmd), { description = "Keybind Cheatsheet" })
hl.bind(vars.mod .. " + R", hl.dsp.exec_cmd(vars.launcher_cmd), { description = "App Launcher" })
hl.bind(vars.mod .. " + E", hl.dsp.exec_cmd("thunar"), { description = "File Manager" })
hl.bind(vars.mod .. " + W", hl.dsp.exec_cmd("brave"), { description = "Browser" })
hl.bind(
	vars.mod .. " + Super_L",
	hl.dsp.exec_cmd(vars.launcher_tap_cmd),
	{ release = true, description = "App Launcher (tap Super)" }
)
hl.bind(
	vars.mod .. " + Super_R",
	hl.dsp.exec_cmd(vars.launcher_tap_cmd),
	{ release = true, description = "App Launcher (tap Super)" }
)

-- 2. Task Switcher
-- Alt+Tab = hyprshell, Super+Tab = rofi window list
hl.bind(vars.mod .. " + Tab", hl.dsp.exec_cmd("rofi -show window"), { description = "Window List (rofi)" })

-- 3. Windows
hl.bind(vars.mod .. " + Q", hl.dsp.window.close(), { description = "Close Window" })
hl.bind(vars.mod .. " + F", hl.dsp.window.fullscreen(), { description = "Fullscreen" })
hl.bind(vars.mod .. " + V", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle Float" })
hl.bind(vars.mod .. " + P", hl.dsp.window.pseudo(), { description = "Pseudo Tile" })
hl.bind(vars.mod .. " + S", hl.dsp.layout("togglesplit"), { description = "Toggle Split" })

-- 4. Focus
hl.bind(vars.mod .. " + left", hl.dsp.focus({ direction = "left" }), { description = "Focus Left" })
hl.bind(vars.mod .. " + right", hl.dsp.focus({ direction = "right" }), { description = "Focus Right" })
hl.bind(vars.mod .. " + up", hl.dsp.focus({ direction = "up" }), { description = "Focus Up" })
hl.bind(vars.mod .. " + down", hl.dsp.focus({ direction = "down" }), { description = "Focus Down" })
hl.bind(vars.mod .. " + h", hl.dsp.focus({ direction = "left" }), { description = "Focus Left (h)" })
hl.bind(vars.mod .. " + l", hl.dsp.focus({ direction = "right" }), { description = "Focus Right (l)" })
hl.bind(vars.mod .. " + k", hl.dsp.focus({ direction = "up" }), { description = "Focus Up (k)" })
hl.bind(vars.mod .. " + j", hl.dsp.focus({ direction = "down" }), { description = "Focus Down (j)" })

-- 5. Move Windows
hl.bind(vars.mod .. " + SHIFT + left", hl.dsp.window.swap({ direction = "left" }), { description = "Move Left" })
hl.bind(vars.mod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "right" }), { description = "Move Right" })
hl.bind(vars.mod .. " + SHIFT + up", hl.dsp.window.swap({ direction = "up" }), { description = "Move Up" })
hl.bind(vars.mod .. " + SHIFT + down", hl.dsp.window.swap({ direction = "down" }), { description = "Move Down" })
hl.bind(vars.mod .. " + SHIFT + h", hl.dsp.window.swap({ direction = "left" }), { description = "Move Left (h)" })
hl.bind(vars.mod .. " + SHIFT + l", hl.dsp.window.swap({ direction = "right" }), { description = "Move Right (l)" })
hl.bind(vars.mod .. " + SHIFT + k", hl.dsp.window.swap({ direction = "up" }), { description = "Move Up (k)" })
hl.bind(vars.mod .. " + SHIFT + j", hl.dsp.window.swap({ direction = "down" }), { description = "Move Down (j)" })

-- 6. Workspaces
hl.bind(vars.mod .. " + 1", hl.dsp.focus({ workspace = 1 }), { description = "Workspace 1" })
hl.bind(vars.mod .. " + 2", hl.dsp.focus({ workspace = 2 }), { description = "Workspace 2" })
hl.bind(vars.mod .. " + 3", hl.dsp.focus({ workspace = 3 }), { description = "Workspace 3" })
hl.bind(vars.mod .. " + 4", hl.dsp.focus({ workspace = 4 }), { description = "Workspace 4" })
hl.bind(vars.mod .. " + 5", hl.dsp.focus({ workspace = 5 }), { description = "Workspace 5" })
hl.bind(vars.mod .. " + 6", hl.dsp.focus({ workspace = 6 }), { description = "Workspace 6" })
hl.bind(vars.mod .. " + 7", hl.dsp.focus({ workspace = 7 }), { description = "Workspace 7" })
hl.bind(vars.mod .. " + 8", hl.dsp.focus({ workspace = 8 }), { description = "Workspace 8" })
hl.bind(vars.mod .. " + 9", hl.dsp.focus({ workspace = 9 }), { description = "Workspace 9" })
hl.bind(vars.mod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }), { description = "Send to Workspace 1" })
hl.bind(vars.mod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }), { description = "Send to Workspace 2" })
hl.bind(vars.mod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }), { description = "Send to Workspace 3" })
hl.bind(vars.mod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }), { description = "Send to Workspace 4" })
hl.bind(vars.mod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }), { description = "Send to Workspace 5" })
hl.bind(vars.mod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }), { description = "Send to Workspace 6" })
hl.bind(vars.mod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }), { description = "Send to Workspace 7" })
hl.bind(vars.mod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }), { description = "Send to Workspace 8" })
hl.bind(vars.mod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }), { description = "Send to Workspace 9" })
hl.bind(vars.mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Next Workspace" })
hl.bind(vars.mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), { description = "Previous Workspace" })

-- 7. Utilities
hl.bind(vars.mod .. " + CTRL + L", hl.dsp.exec_cmd(vars.lock_cmd), { description = "Lock Screen" })
if vars.restart_noctalia then
	hl.bind(vars.mod .. " + SHIFT + N", hl.dsp.exec_cmd("restart-noctalia"), { description = "Restart Noctalia" })
end
hl.bind(
	vars.mod .. " + SHIFT + C",
	hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"),
	{ description = "Clipboard History" }
)
hl.bind(vars.mod .. " + SHIFT + M", hl.dsp.exec_cmd(vars.session_menu_cmd), { description = "Session Menu" })
hl.bind("Print", hl.dsp.exec_cmd("screenshot area"), { description = "Screenshot Area" })
hl.bind(vars.mod .. " + Print", hl.dsp.exec_cmd("screenshot active"), { description = "Screenshot Window" })
hl.bind(vars.mod .. " + SHIFT + Print", hl.dsp.exec_cmd("screenshot output"), { description = "Screenshot Monitor" })
hl.bind(
	vars.mod .. " + SHIFT + B",
	hl.dsp.dpms({ action = "toggle", monitor = "DP-1" }),
	{ description = "Toggle Monitor Blank" }
)

-- 8. Media
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true, description = "Volume Up" }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true, description = "Volume Down" }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true, description = "Mute" }
)
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("brightnessctl set 5%+"),
	{ locked = true, repeating = true, description = "Brightness Up" }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("brightnessctl set 5%-"),
	{ locked = true, repeating = true, description = "Brightness Down" }
)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Play / Pause" })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true, description = "Next Track" })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true, description = "Previous Track" })

hl.bind(vars.mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Move Window (mouse)" })
hl.bind(vars.mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize Window (mouse)" })
