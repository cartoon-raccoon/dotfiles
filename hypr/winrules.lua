--                   o8o                                   oooo                     
--                   `"'                                   `888                     
-- oooo oooo    ooo oooo  ooo. .oo.   oooo d8b oooo  oooo   888   .ooooo.   .oooo.o 
--  `88. `88.  .8'  `888  `888P"Y88b  `888""8P `888  `888   888  d88' `88b d88(  "8 
--   `88..]88..8'    888   888   888   888      888   888   888  888ooo888 `"Y88b.  
--    `888'`888'     888   888   888   888      888   888   888  888    .o o.  )88b 
--     `8'  `8'     o888o o888o o888o d888b     `V88V"V8P' o888o `Y8bod8P' 8""888P' 

local ws = require("workspaces")

local wr = {}

-- window rules pertaining to workspaces.
wr.workspace = {
    browser_on_main = hl.window_rule({name = "browser_on_main",
        match = { class = "^(firefox|zen)" },
        workspace = ws.main:sel_id()
    }),
    code_on_dev = hl.window_rule({name = "code_on_dev",
        match = { class = "^(com.microsoft.VSCode)$" },
        workspace = ws.dev:sel_id()
    }),
    zed_on_dev = hl.window_rule({name = "zed_on_dev",
        match = { class = "^(dev.zed.Zed)$" },
        workspace = ws.dev:sel_id()
    }),
    discord_on_chat = hl.window_rule({name = "discord_on_chat",
        match = { class = "^(discord)$" },
        workspace = ws.chat:sel_id()
    }),
    element_on_chat = hl.window_rule({name = "element_on_chat",
        match = { class = "^(Element)$" },
        workspace = ws.chat:sel_id()
    }),
    telegram_on_chat = hl.window_rule({name = "telegram_on_chat",
        match = { class = "^(org.telegram.desktop)$" },
        workspace = ws.chat:sel_id()
    }),
    spotify_on_music = hl.window_rule({name = "spotify_on_music",
        match = { class = "^(spotify)$" },
        workspace = ws.music:sel_id()
    })
}

-- Bodge rules for windows that misbehave with Hyprland.
wr.bodge = {
    blender_settings = hl.window_rule({name = "blender_settings",
        match = { class = "(blender)", title = "^(Blender Preferences)$" },
        float = true
    }),
    picture_in_picture = hl.window_rule({name = "picture_in_picture",
        match = { class = "^(firefox|zen)$", title = "^(Picture-in-Picture)$" },
        float = true
    }),

    freecad_splash = hl.window_rule({name = "freecad_splash",
        match = { class = "^(org.freecad.FreeCAD)$", title = "^(FreeCAD)$" },
        float = true,
        border_size = 0,
        no_shadow = true,
        no_blur = true
    }),
    steam_dialogs_float = hl.window_rule({name = "steam_dialogs_float",
        match = { class = "^(steam)$", title = "negative:^(Steam)$" },
        float = true
    }),
    nemo_properties_float = hl.window_rule({name = "nemo_properties_float",
        match = { class = "^(nemo)$", title = "(.* Properties)$" },
        float = true
    }),
    telegram_media_viewer_flt = hl.window_rule({name = "telegram_media_viewer_flt",
        match = { class = "^(org.telegram.desktop)$", title = "^(Media viewer)$" },
        float = true
    }),
    qbittorrent_dialog_float = hl.window_rule({name = "qbittorrent_dialog_float",
        match = {
            class = "^(org\\.qbittorrent\\.qBittorrent)$",
            title = "negative:^(qBittorrent v[0-9]+\\.[0-9]+\\.[0-9]+)$"
        },
        float = true,
    }),
    -- suppress_code_activate = hl.window_rule({name = "suppress_code_activate",
    --     match = { class = "^(com.microsoft.VSCode)$" },
    --     suppress_event = "activate"
    -- }),
}

local system_window_size = { 1700, 1200 }

wr.systemwins = {
    noctalia = hl.window_rule({name = "noctalia_window_rules",
        match = { class = "^(dev.noctalia.Noctalia)$" },
        float = true,
        size = system_window_size,
        group = "deny",
    }),
    corectrl = hl.window_rule({name = "corectrl_window_rules",
        match = { class = "^(org.corectrl.CoreCtrl)$" },
        float = true,
        size = system_window_size,
        group = "deny",
    }),
    easyeffects = hl.window_rule({name = "easyeffects_window_rules",
        match = { class = "^(com.github.wwmm.easyeffects)$" },
        float = true,
        size = system_window_size,
        group = "deny",
    }),
    lact = hl.window_rule({name = "lact_window_rules",
        match = { class = "^(io.github.ilya_zlobintsev.LACT)$" },
        float = true,
        size = system_window_size,
        group = "deny",
    }),
    drkonqi = hl.window_rule({name = "drkonqi_window_rules",
        match = { class = "^(org.kde.drkonqi.coredump.gui)$" },
        float = true,
        size = system_window_size,
        group = "deny",
    }),
    blueman = hl.window_rule({name = "blueman_window_rules",
        match = { class = "^(blueman-manager)$", title = "^(Bluetooth Devices)$" },
        float = true,
        size = { "(monitor_w*0.333)", "(monitor_h*0.5)" },
        group = "deny",
    }),
    zenity = hl.window_rule({name = "zenity_window_rules",
        match = { class = "^(zenity)$" },
        float = true,
        group = "deny",
    }),
}

wr.wanted = {
    media_float = hl.window_rule({name = "media_float",
        match = { class = "^(vlc|mpv)$" },
        float = true
    }),
    pin_floating_media = hl.window_rule({name = "pin_floating_media",
        match = { class = "^(vlc|mpv)$", float = true },
        pin = true,
    }),
    image_viewer_float = hl.window_rule({name = "image_viewer_float",
        match = { class = "^(imv|org.kde.gwenview)$" },
        float = true
    })
}

wr.scrollwidth = {
    alacritty = hl.window_rule({name = "alacritty_scroll_width",
        match = { class = "^(Alacritty)$", float = false },
        scrolling_width = 0.5
    }),
    bitwarden = hl.window_rule({name = "bitwarden_scroll_width",
        match = { class = "^(Bitwarden)$", float = false },
        scrolling_width = 0.5
    }),
    keyrack = hl.window_rule({name = "keyrack_scroll_width",
        match = { class = "^(app.drey.KeyRack)$", float = false },
        scrolling_width = 0.5
    }),
}

wr.wev = hl.window_rule({name = "wev_size",
    match = { class = "^(wev)$" },
    float = true,
    size = { 500, 500 },
})

wr.pin = {
    media = hl.window_rule({name = "media_pin",
        match = { class = "^(vlc|mpv)$", float = true },
        pin = true
    }),
    browser_pip = hl.window_rule({name = "browser_pip_pin",
        match = { class = "^(firefox|zen)$", float = true },
        pin = true
    }),
    bordercolor = hl.window_rule({name = "pin_border_color",
        match = { pin = true },
        border_color = { colors = { "rgba(eab5ecff)", "rgba(48214dff)" }, angle = 45 }
    })
}

wr.idleinhibit = {
    media = hl.window_rule({name = "media_idle_inhibit",
        match = { class = "^(vlc|mpv)$" },
        idle_inhibit = "always"
    }),
    browser = hl.window_rule({name = "browser_idle_inhibit",
        match = { class = "^(firefox|zen)$", title = ".*(YouTube|Roll20).*" },
        idle_inhibit = "focus"
    }),
    gamescope = hl.window_rule({name = "gamescope_idle_inhibit",
        match = { class = "^(gamescope)$" },
        idle_inhibit = "always"
    }),
    -- todo: cyberpunk (maybe)
}

-- mod.catchall_windows_on_main = hl.window_rule({name = "catchall_windows_on_main",
--     workspace = ws.main:sel_id()
-- })

return wr