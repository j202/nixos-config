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
hl.bind(vars.mod .. " + Return", hl.dsp.exec_cmd("kitty")) -- Terminal
hl.bind(vars.mod .. " + F1", hl.dsp.exec_cmd(vars.cheatsheet_cmd)) -- Keybind Cheatsheet
hl.bind(vars.mod .. " + slash", hl.dsp.exec_cmd(vars.cheatsheet_cmd)) -- Keybind Cheatsheet
hl.bind(vars.mod .. " + R", hl.dsp.exec_cmd(vars.launcher_cmd)) -- App Launcher
hl.bind(vars.mod .. " + E", hl.dsp.exec_cmd("thunar")) -- File Manager
hl.bind(vars.mod .. " + W", hl.dsp.exec_cmd("brave")) -- Browser
hl.bind(vars.mod .. " + Super_L", hl.dsp.exec_cmd(vars.launcher_tap_cmd), { release = true }) -- App Launcher (tap Super)
hl.bind(vars.mod .. " + Super_R", hl.dsp.exec_cmd(vars.launcher_tap_cmd), { release = true }) -- App Launcher (tap Super)

-- 2. Task Switcher (Alt+Tab = hyprshell, Super+Tab = rofi window list)
hl.bind(vars.mod .. " + Tab", hl.dsp.exec_cmd("rofi -show window")) -- Window List (rofi)

-- 3. Windows
hl.bind(vars.mod .. " + Q", hl.dsp.window.close()) -- Close Window
hl.bind(vars.mod .. " + F", hl.dsp.window.fullscreen()) -- Fullscreen
hl.bind(vars.mod .. " + V", hl.dsp.window.float({ action = "toggle" })) -- Toggle Float
hl.bind(vars.mod .. " + P", hl.dsp.window.pseudo()) -- Pseudo Tile
hl.bind(vars.mod .. " + S", hl.dsp.layout("togglesplit")) -- Toggle Split

-- 4. Focus
hl.bind(vars.mod .. " + left", hl.dsp.focus({ direction = "left" })) -- Focus Left
hl.bind(vars.mod .. " + right", hl.dsp.focus({ direction = "right" })) -- Focus Right
hl.bind(vars.mod .. " + up", hl.dsp.focus({ direction = "up" })) -- Focus Up
hl.bind(vars.mod .. " + down", hl.dsp.focus({ direction = "down" })) -- Focus Down
hl.bind(vars.mod .. " + h", hl.dsp.focus({ direction = "left" })) -- Focus Left (h)
hl.bind(vars.mod .. " + l", hl.dsp.focus({ direction = "right" })) -- Focus Right (l)
hl.bind(vars.mod .. " + k", hl.dsp.focus({ direction = "up" })) -- Focus Up (k)
hl.bind(vars.mod .. " + j", hl.dsp.focus({ direction = "down" })) -- Focus Down (j)

-- 5. Move Windows
hl.bind(vars.mod .. " + SHIFT + left", hl.dsp.window.swap({ direction = "left" })) -- Move Left
hl.bind(vars.mod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "right" })) -- Move Right
hl.bind(vars.mod .. " + SHIFT + up", hl.dsp.window.swap({ direction = "up" })) -- Move Up
hl.bind(vars.mod .. " + SHIFT + down", hl.dsp.window.swap({ direction = "down" })) -- Move Down
hl.bind(vars.mod .. " + SHIFT + h", hl.dsp.window.swap({ direction = "left" })) -- Move Left (h)
hl.bind(vars.mod .. " + SHIFT + l", hl.dsp.window.swap({ direction = "right" })) -- Move Right (l)
hl.bind(vars.mod .. " + SHIFT + k", hl.dsp.window.swap({ direction = "up" })) -- Move Up (k)
hl.bind(vars.mod .. " + SHIFT + j", hl.dsp.window.swap({ direction = "down" })) -- Move Down (j)

-- 6. Workspaces
hl.bind(vars.mod .. " + 1", hl.dsp.focus({ workspace = 1 })) -- Workspace 1
hl.bind(vars.mod .. " + 2", hl.dsp.focus({ workspace = 2 })) -- Workspace 2
hl.bind(vars.mod .. " + 3", hl.dsp.focus({ workspace = 3 })) -- Workspace 3
hl.bind(vars.mod .. " + 4", hl.dsp.focus({ workspace = 4 })) -- Workspace 4
hl.bind(vars.mod .. " + 5", hl.dsp.focus({ workspace = 5 })) -- Workspace 5
hl.bind(vars.mod .. " + 6", hl.dsp.focus({ workspace = 6 })) -- Workspace 6
hl.bind(vars.mod .. " + 7", hl.dsp.focus({ workspace = 7 })) -- Workspace 7
hl.bind(vars.mod .. " + 8", hl.dsp.focus({ workspace = 8 })) -- Workspace 8
hl.bind(vars.mod .. " + 9", hl.dsp.focus({ workspace = 9 })) -- Workspace 9
hl.bind(vars.mod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 })) -- Send to Workspace 1
hl.bind(vars.mod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 })) -- Send to Workspace 2
hl.bind(vars.mod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 })) -- Send to Workspace 3
hl.bind(vars.mod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 })) -- Send to Workspace 4
hl.bind(vars.mod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 })) -- Send to Workspace 5
hl.bind(vars.mod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 })) -- Send to Workspace 6
hl.bind(vars.mod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 })) -- Send to Workspace 7
hl.bind(vars.mod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 })) -- Send to Workspace 8
hl.bind(vars.mod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9 })) -- Send to Workspace 9
hl.bind(vars.mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" })) -- Next Workspace
hl.bind(vars.mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" })) -- Previous Workspace

-- 7. Utilities
hl.bind(vars.mod .. " + CTRL + L", hl.dsp.exec_cmd(vars.lock_cmd)) -- Lock Screen
if vars.restart_noctalia then
	hl.bind(vars.mod .. " + SHIFT + N", hl.dsp.exec_cmd("restart-noctalia")) -- Restart Noctalia
end
hl.bind(vars.mod .. " + SHIFT + C", hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy")) -- Clipboard History
hl.bind(vars.mod .. " + SHIFT + M", hl.dsp.exec_cmd(vars.session_menu_cmd)) -- Session Menu
hl.bind("Print", hl.dsp.exec_cmd("screenshot area")) -- Screenshot Area
hl.bind(vars.mod .. " + Print", hl.dsp.exec_cmd("screenshot active")) -- Screenshot Window
hl.bind(vars.mod .. " + SHIFT + Print", hl.dsp.exec_cmd("screenshot output")) -- Screenshot Monitor
hl.bind(vars.mod .. " + SHIFT + B", hl.dsp.dpms({ action = "toggle", monitor = "DP-1" })) -- Toggle Monitor Blank

-- 8. Media
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
) -- Volume Up
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
) -- Volume Down
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
) -- Mute
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true }) -- Brightness Up
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true }) -- Brightness Down
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true }) -- Play / Pause
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true }) -- Next Track
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true }) -- Previous Track

hl.bind(vars.mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(vars.mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
