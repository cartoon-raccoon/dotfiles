##### cartoon-raccoon's qtile config file #####

from typing import List  # noqa: F401

from libqtile import bar, layout, widget
from libqtile.config import Click, Drag, Group, ScratchPad, DropDown, Key, KeyChord, Match, Screen, Rule
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile import hook

import os
import subprocess
import datetime
import cgi

mod = "mod4"
terminal = guess_terminal()

#####! KEYBINDS !#####

keys = [
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(),
        desc="Move window focus to other window"),

    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(),
        desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(),
        desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(),
        desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),

    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.decrease_ratio(),
        desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.increase_ratio(),
        desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(),
        desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    Key([mod], "Left", lazy.screen.prev_group()),
    Key([mod], "Right", lazy.screen.next_group()),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "shift"], "Return", lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack"),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),

    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    
    # Toggle fullscreen and floating
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen."),
    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating,"),
    Key([mod], "m", lazy.group.setlayout("  max  ")),
    Key([mod], "w", lazy.group.setlayout("tabbed ")),

    # Basic QTile commands
    Key([mod, "control"], "r", lazy.restart(), desc="Restart Qtile"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawncmd(),
        desc="Spawn a command using a prompt widget"),

    # dropdown commands
    #Key([], 'F11', lazy.group['dropdowns'].dropdown_toggle('term')),
    #Key([], 'F12', lazy.group['dropdowns'].dropdown_toggle('qshell')),

    # music control keys
    Key([mod], "grave", lazy.spawn("mpc toggle")),
    Key([mod], "period", lazy.spawn("mpc next")),
    Key([mod], "comma", lazy.spawn("mpc prev")),

    Key([mod, "shift"], "grave", lazy.spawn("/home/sammy/.config/spotify-dbus.sh -t")),
    Key([mod, "shift"], "period", lazy.spawn("/home/sammy/.config/spotify-dbus.sh -n")),
    Key([mod, "shift"], "comma", lazy.spawn("/home/sammy/.config/spotify-dbus.sh -p")),

    # volume and brightness control
    Key([], 'XF86AudioRaiseVolume', lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")),
    Key([], 'XF86AudioLowerVolume', lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")),
    Key([], 'XF86AudioMute', lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")),

    Key([], 'XF86MonBrightnessUp', lazy.spawn("brightnessctl set +10%")),
    Key([], 'XF86MonBrightnessDown', lazy.spawn("brightnessctl set 10%-")),

    # screenshot keys
    Key([mod],"Print", lazy.spawn("/home/sammy/.config/scrot/run.sh")),
    Key([mod, "shift"], "Print", lazy.spawn("/home/sammy/.config/scrot/run.sh -u")),
    
    # Launch mode: keyboard shortcuts to launch a bunch of programs.
    KeyChord([mod],"p", [
        Key([], "f", lazy.spawn("firefox")),
        Key([], "s", lazy.spawn("spotify")),
        Key([], "d", lazy.spawn("discord")),
        Key([], "c", lazy.spawn("code")),
        Key([], "r", lazy.spawn("alacritty -e ranger")),
        Key([], "t", lazy.spawn("thunar")),
        Key([], "m", lazy.spawn("multimc"))
    ], mode = "launch")
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front())
]

groups = [
    # main
    Group(' '), 
    # dev
    Group(' '), 
    # files
    Group(' '), 
    # social
    Group(' '), 
    # misc
    Group('ﳁ '),
    # dropdowns
    # ScratchPad("dropdowns",
    #     DropDown("term", "alacritty", opacity = 0.9),
    #     DropDown("qshell", "alacritty -e qtile shell", opacity = 0.9)
    # )
]

# Bind group to its index in the group list and define mappings for window management.
for i in range(1, len(groups) + 1):
    group = groups[i - 1]
    keys.extend([
        # mod1 + letter of group = switch to group
        Key([mod], str(i), lazy.group[group.name].toscreen(),
            desc="Switch to group {}".format(group.name)),

        # mod1 + shift + letter of group = switch to & move focused window to group
        Key([mod, "shift"], str(i), lazy.window.togroup(group.name, switch_group=True),
            desc="Switch to & move focused window to group {}".format(group.name)),

        # mod1 + ctrl + letter of group = move focused to group but do not switch
        Key([mod, "control"], str(i), lazy.window.togroup(group.name),
            desc="Move focused window to group {}".format(group.name)),
    ])

#####! LAYOUTS !#####

layouts = [
    layout.Tile(
        border_focus = "#efefef",
        border_normal = "#5f676a",
        margin = 4,
        ratio = 0.55,
        ratio_increment = 0.03,
        name = " tile  "
    ),
    layout.MonadTall(
        border_focus = "#efefef",
        border_normal = "#5f676a",
        margin = 4,
        name = "monadt "
    ),
    layout.TreeTab(
        active_bg = "#efefef",
        active_fg = "#222222",
        bg_color  = "#202020",
        border_width = 2,
        font = "FiraCode Nerd Font",
        fontsize = 12,
        inactive_bg = "#5f676a",
        inactive_fg = "#efefef",
        sections = ['Tabs'],
        name = "tabbed "
    ),
    layout.Max(
        name = "  max  "
    ),
    #layout.Columns(
    #    border_focus_stack='#efefef',
    #    border_focus='#efefef',
    #    border_normal='#5f676a',
    #    margin = 4,
    #    name = "columns"
    #),
    #layout.Stack(
    #    border_focus = "#efefef",
    #    border_normal = "#5f676a",
    #    num_stacks=2,
    #    margin = 4,
    #    name = " stack "
    #),
    #layout.Bsp(
    #    border_focus = "#efefef",
    #    border_normal = "#5f676a",
    #    margin = 4,
    #    name = "  bsp  "
    #),
    #layout.MonadWide(
    #    border_focus = "#efefef",
    #    border_normal = "#5f676a",
    #    margin = 4,
    #    name = "monadw "
    #),
    # layout.Matrix(),
    # layout.RatioTile(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

#####! SCREENS AND WIDGETS !#####

widget_defaults = dict(
    font='FiraCode Nerd Font',
    fontsize=14,
    padding=3,
)
extension_defaults = widget_defaults.copy()

# Used in the MPD widget to truncate titles if they get too long
def truncate(s):
    if len(s) > 20:
        return f"{s[:20]}..."
    else:
        return s

# the top bar. not currently in use.
top_bar = bar.Bar(
    [
        widget.Mpd2(
            status_format = "{play_status} {artist}: {title} ({elapsed}/{duration}) [{repeat}{random}{single}{consume}{updating_db}]",
            idle_format = " {idle_message} ",
            idle_message = "Nothing playing",
            format_fns = dict(
                #all=lambda s: cgi.escape(s),
                title=truncate,
                elapsed=lambda s: str(datetime.timedelta(seconds=int(float(s))))[2:],
                duration=lambda s: str(datetime.timedelta(seconds=int(float(s))))[2:],
            ),
            padding = 10,

        ),
        widget.Volume(fmt = '墳 {}'),
        widget.Spacer(length = bar.STRETCH),
        widget.Memory(
            fmt = "  {}",
            format = '{MemUsed}M ({MemPercent}%)'
        ),
        widget.CPU(
            fmt = " {}",
            format = "{freq_current}GHz ({load_percent}%)"
        )
    ],
    30,
    background = "#202020",
)

# the bottom bar.
bottom_bar = bar.Bar(
    [
        widget.CurrentLayout(),
        widget.GroupBox(
            highlight_method = 'line',
            highlight_color = ['#202020', '#343434'],
            this_current_screen_border = '#fabd2f',
            this_screen_border = '#fabd2f',
        ),
        widget.Spacer(length = 15),
        widget.Prompt(),
        widget.WindowName(),
        widget.Chord(
            chords_colors={
                'launch': ("#fabd2f", "#282828"),
            },
            name_transform=lambda name: name.upper(),
        ),
        widget.Systray(),
        widget.Spacer(length = 8),
        widget.Clock(format='%A, %d %b %Y %I:%M%p'),
        widget.Spacer(length = 8),
        widget.QuickExit(
            padding = 1,
            foreground = 'fb4934',
            default_text = '[  ]',
            countdown_format = '[ {} ]'
        ),
    ],
    30,
    background = '202020'
)

screens = [
    Screen(
        #top=top_bar,
        bottom=bottom_bar,
        left = bar.Gap(size = 8),
        right = bar.Gap(size = 8),
    ),
]

#####! ADDITIONAL VARIABLES !#####

dgroups_key_binder = None
dgroups_app_rules = [
    Rule(
        Match(wm_type = [
            "confirm",
            "download",
            "notification",
            "toolbar",
            "splash",
            "dialog",
            "error",
        ]),
        float = True
    ),
    Rule(
        Match(wm_class = [
            "Pavucontrol",
            "Oomox",
        ]),
        float = True,
        break_on_match = False
    )
] 
main = None  # WARNING: this is deprecated and will be removed soon
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class='confirmreset'),  # gitk
        Match(wm_class='makebranch'),  # gitk
        Match(wm_class='maketag'),  # gitk
        Match(wm_class='ssh-askpass'),  # ssh-askpass
        Match(title='branchdialog'),  # gitk
        Match(title='pinentry'),  # GPG key password entry
    ],
    border_focus = "#efefef",
    border_normal = "#5f676a"
)
auto_fullscreen = True
focus_on_window_activation = "smart"

#####! WINDOW HOOKS !#####

@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser('~/.config/qtile/autostart.sh')
    subprocess.call([home])

@hook.subscribe.client_new
def floating_dialogs(window):
    dialog = window.window.get_wm_type() == 'dialog'
    transient = window.window.get_wm_transient_for()
    bubble = window.window.get_wm_window_role() == 'bubble'
    if dialog or bubble or transient:
        window.floating = True


# Needed by some Java programs
wmname = "LG3D"
