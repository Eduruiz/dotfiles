-- This file will not be overwritten across dots-hyprland updates.
-- The file name is for the sake of organization and does not matter
-- See the corresponding files in ~/.config/hypr/hyprland for examples

local mainMod = "SUPER"
local terminal = "kitty"

-- Monitor config
hl.monitor({output = "", mode = "preferred", position = "auto", scale = 1})
hl.monitor({output = "eDP-1", disabled = true})

-- Device config
hl.device({name = "synaptics-tm3276-022", enabled = false})

-- Override end-4 defaults
hl.unbind("SUPER + Return")
hl.unbind("SUPER + E")
hl.unbind("SUPER + H")
hl.unbind("SUPER + L")
hl.unbind("SUPER + K")
hl.unbind("SUPER + J")
hl.unbind("SUPER + SHIFT + H")
hl.unbind("SUPER + SHIFT + L")
hl.unbind("SUPER + SHIFT + K")
hl.unbind("SUPER + SHIFT + J")
hl.unbind("SUPER + S")
hl.unbind("SUPER + O")
hl.unbind("SUPER + T")
hl.unbind("SUPER + X")
hl.unbind("SUPER + SHIFT + P")
hl.unbind("SUPER + Period")
hl.unbind("SUPER + D")
hl.unbind("SUPER + B")

-- Terminal
hl.bind("SUPER + Return", hl.dsp.exec_cmd(terminal))

-- Window management
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + E", hl.dsp.layout("togglesplit"))

-- Toggle layout dwindle <-> scrolling for current workspace
hl.bind("SUPER + backslash", function()
    local ws = hl.get_active_workspace()
    if not ws then return end
    if ws.tiled_layout == "scrolling" then
        hl.workspace_rule({workspace = ws.name, layout = "dwindle"})
    else
        hl.workspace_rule({workspace = ws.name, layout = "scrolling"})
    end
end)

-- Focus (arrow keys)
hl.bind("SUPER + left",  hl.dsp.focus({direction = "left"}))
hl.bind("SUPER + right", hl.dsp.focus({direction = "right"}))
hl.bind("SUPER + up",    hl.dsp.focus({direction = "up"}))
hl.bind("SUPER + down",  hl.dsp.focus({direction = "down"}))

-- Focus (hjkl)
hl.bind("SUPER + h", hl.dsp.focus({direction = "left"}))
hl.bind("SUPER + l", hl.dsp.focus({direction = "right"}))
hl.bind("SUPER + k", hl.dsp.focus({direction = "up"}))
hl.bind("SUPER + j", hl.dsp.focus({direction = "down"}))

-- Move windows (hjkl)
hl.bind("SUPER + SHIFT + h", hl.dsp.window.move({direction = "left"}))
hl.bind("SUPER + SHIFT + l", hl.dsp.window.move({direction = "right"}))
hl.bind("SUPER + SHIFT + k", hl.dsp.window.move({direction = "up"}))
hl.bind("SUPER + SHIFT + j", hl.dsp.window.move({direction = "down"}))

-- Switch workspaces + move windows
for i = 1, 9 do
    hl.bind("SUPER + " .. i,         hl.dsp.focus({workspace = i}))
    hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({workspace = i, follow = false}))
end
hl.bind("SUPER + 0",         hl.dsp.focus({workspace = 10}))
hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({workspace = 10, follow = false}))

-- Scroll through workspaces
hl.bind("SUPER + mouse_down", hl.dsp.focus({workspace = "e+1"}))
hl.bind("SUPER + mouse_up",   hl.dsp.focus({workspace = "e-1"}))

-- Move/resize with mouse
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   {mouse = true})
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), {mouse = true})

-- Move workspace to next monitor
hl.bind("SUPER + X", hl.dsp.exec_cmd("hyprctl dispatch movecurrentworkspacetomonitor +1"))

-- Screenshot
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | swappy -f -"))

-- Clipboard
hl.bind("SUPER + C", hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy"))

-- Lock screen
hl.bind("SUPER + SHIFT + X", hl.dsp.exec_cmd("hyprlock"))

-- Session menu
hl.bind("SUPER + SHIFT + E", hl.dsp.global("quickshell:sessionToggle"))

-- Brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s +5%"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"))

-- Toggle trackpad
hl.bind("SUPER + F1", hl.dsp.exec_cmd("~/scripts/toggle-trackpad.sh"))

-- Special workspaces
hl.workspace_rule({workspace = "special:songs",      gaps_out = 150})
hl.workspace_rule({workspace = "special:telegram",   gaps_out = 50})
hl.workspace_rule({workspace = "special:dropinterm", gaps_out = 180})

hl.bind("SUPER + MINUS",         hl.dsp.workspace.toggle_special("scratch"))
hl.bind("SUPER + SHIFT + MINUS", hl.dsp.window.move({workspace = "special:scratch", follow = false}))
hl.bind("SUPER + S", function()
    if #hl.get_workspace_windows("special:songs") == 0 then
        hl.exec_cmd("gtk-launch chrome-ljkbjndfbphodmclfdpfpjddhpapgolj-Default")
    end
    hl.dispatch(hl.dsp.workspace.toggle_special("songs"))
end)
hl.bind("SUPER + O", function()
    if #hl.get_workspace_windows("special:telegram") == 0 then
        hl.exec_cmd("Telegram")
    end
    hl.dispatch(hl.dsp.workspace.toggle_special("telegram"))
end)
hl.bind("SUPER + T", function()
    if #hl.get_workspace_windows("special:dropinterm") == 0 then
        hl.exec_cmd("kitty")
    end
    hl.dispatch(hl.dsp.workspace.toggle_special("dropinterm"))
end)
