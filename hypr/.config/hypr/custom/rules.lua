-- This file will not be overwritten across dots-hyprland updates.
-- The file name is for the extra of organization and does not matter
-- See the corresponding files in ~/.config/hypr/hyprland for examples

-- Global opacity (inactive windows slightly dimmed)
hl.window_rule({match = {class = ".*"}, opacity = "1 0.9"})

-- Keep full opacity for communication apps
hl.window_rule({match = {class = "^(discord)$"}, opacity = "1.0 override 1.0 override"})
hl.window_rule({match = {class = "^(discord)$"}, no_dim = true})
hl.window_rule({match = {title = ".*(Meet|Microsoft Teams).*"}, opacity = "1.0 override 1.0 override"})
hl.window_rule({match = {title = ".*(Meet|Microsoft Teams).*"}, no_dim = true})

-- App-specific
hl.window_rule({match = {class = "^(Spotify)$"}, border_color = "rgba(683B8211) rgba(683B8211) 45deg"})

-- Waydroid
hl.window_rule({match = {class = "^(Waydroid)$"}, float = true})
hl.window_rule({match = {class = "^(Waydroid)$"}, size = {720, 1280}})
hl.window_rule({match = {class = "^(Waydroid)$"}, center = true})
hl.window_rule({match = {class = "^(waydroid%..*)$"}, float = true})
hl.window_rule({match = {class = "^(waydroid%..*)$"}, size = {720, 1280}})
hl.window_rule({match = {class = "^(waydroid%..*)$"}, center = true})

-- XWayland video bridge (screen sharing)
hl.window_rule({
    name  = "xwayland-bridge",
    match = {class = "^(xwaylandvideobridge)$"},
    opacity           = "0.0 override",
    no_anim           = true,
    no_initial_focus  = true,
    max_size          = {1, 1},
    no_blur           = true,
})

-- Workspace rules
hl.workspace_rule({workspace = 8, layout = "scrolling"})
