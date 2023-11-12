##### cartoon-raccoon's qtile config file #####

# symlinked to ~/.config/qtile/config.py.

from typing import List  # noqa: F401
import copy

from libqtile import bar, layout, widget
from libqtile.config import Click, Drag, Group, ScratchPad, DropDown, Key, KeyChord, Match, Screen, Rule
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile import hook
from libqtile import qtile

import os
import subprocess
import datetime
import cgi

import bars

mod = "mod4"

if qtile.core.name == "x11":
    terminal = "alacritty"
elif qtile.core.name == "wayland":
    terminal = "kitty"
else:
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
    Key([mod], "y", lazy.window.toggle_floating(), desc="Toggle floating,"),
    Key([mod], "m", lazy.group.setlayout("  max  ")),
    Key([mod], "e", lazy.group.setlayout(" equal ")),
    Key([mod], "t", lazy.group.setlayout(" tile  ")),
    Key([mod], "w", lazy.group.setlayout("tabbed ")),

    # Basic QTile commands
    Key([mod, "control"], "r", lazy.restart(), desc="Restart Qtile"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawncmd(),
        desc="Spawn a command using a prompt widget"),

    # dropdown commands
    Key([], 'F11', lazy.group['dropdowns'].dropdown_toggle('term')),
    Key([], 'F12', lazy.group['dropdowns'].dropdown_toggle('qshell')),

    # music control keys
    Key([mod], "grave", lazy.spawn("mpc toggle")),
    Key([mod], "period", lazy.spawn("mpc next")),
    Key([mod], "comma", lazy.spawn("mpc prev")),
    Key([mod], "XF86AudioPlay", lazy.spawn("mpc toggle")),
    Key([mod], "XF86AudioNext", lazy.spawn("mpc next")),
    Key([mod], "XF86AudioPrev", lazy.spawn("mpc prev")),
    Key([mod, "shift"], "m", lazy.function(bars.mpd_play_playlist)),

    Key([], "XF86AudioPlay", lazy.spawn("/home/sammy/.config/spotify-dbus.sh -t")),
    Key([], "XF86AudioNext", lazy.spawn("/home/sammy/.config/spotify-dbus.sh -n")),
    Key([], "XF86AudioPrev", lazy.spawn("/home/sammy/.config/spotify-dbus.sh -p")),
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
    Key([mod, "shift"], "f", lazy.spawn("flameshot")),    
    
    # Launch mode: keyboard shortcuts to launch a bunch of programs.
    KeyChord([mod],"p", [
        KeyChord([], "f", [
            Key([], "i", lazy.spawn("firefox")),
            Key([], "r", lazy.spawn("freecad")),
        ], name="f"),
        KeyChord([], "s", [
            Key([], "p", lazy.spawn("spotify")),
            Key([], "t", lazy.spawn("steam")),
        ], name="s"),
        KeyChord([], "t", [
            Key([], "h", lazy.spawn("thunar")),
            Key([], "e", lazy.spawn("texmaker")),
        ], name="t"),
        Key([], "a", lazy.spawn("anki")),
        Key([], "k", lazy.spawn("kicad")),
        Key([], "o", lazy.spawn("obsidian")),
        Key([], "n", lazy.spawn("notion-app")),
        Key([], "d", lazy.spawn("discord")),
        Key([], "c", lazy.spawn("code")),
        Key([], "r", lazy.spawn("alacritty -e ranger")),
        Key([], "m", lazy.spawn("minecraft-launcher")),
        Key([], "v", lazy.spawn("vmware")),
    ], name="launch"),

    # chord to launch cysec tools but i use more cli tools lol
    KeyChord([mod], "o", [
        Key([], "c", lazy.spawn("cutter")),
        Key([], "g", lazy.spawn("gdbgui")),
        Key([], "d", lazy.spawn("ghidra")),
        Key([], "w", lazy.spawn("wireshark")),
        Key([], "v", lazy.spawn("vmware")),
        Key([], "q", lazy.spawn("qFlipper")),
    ], name="hackery"),

    KeyChord([mod], "i", [
        Key([], "f", lazy.spawn("freecad")),
        Key([], "k", lazy.spawn("kicad")),
    ], name="design"),

    Key([mod], "g", lazy.spawn("/home/sammy/.config/i3/i3lock"))
]

# Drag floating layouts.
mouse = [
    Drag(
        [mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()
    ),
    Drag(
        [mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()
    ),
    Click(
        [mod], "Button4", lazy.group.next_window(),
    ),
    Click(
        [mod], "Button5", lazy.group.prev_window(),
    ),
    Click(
        [mod], "Button8", lazy.screen.next_group(),
    ),
    Click(
        [mod], "Button9", lazy.screen.prev_group(),
    ),
    Click(
        [mod], "Button2", lazy.window.bring_to_front()
    )
]

groups = [
    # main
    Group('HOME', layout="  max  ", spawn=["firefox"], label=' '), 
    # dev
    Group('DEV', layout="  max  ", label=' '), 
    # terminals
    Group('TERMINAL', layout=" equal ", spawn = ["alacritty", "alacritty"], label=' '),
    # files
    Group('FILES', spawn = ["thunar"], label=' '), 
    # social
    Group('SOCIAL', label=' '),
    # music
    Group('MUSIC', layout=" equal ", spawn=["spotify", "alacritty -e ncmpcpp"], label=' '),
    # misc
    Group('MISC', layout=" equal ", label=' '),
    # note taking
    Group('NOTES', layout="  max  ", spawn=["obsidian"], label='󰠮 '),
    # reading
    Group('READING', layout="tabbed ", label=' '),
    # dropdowns
    ScratchPad("dropdowns", [
        DropDown("term", "alacritty", opacity = 0.9),
        DropDown("qshell", "alacritty -e qtile shell", opacity = 0.9)
    ]),
]

# Bind group to its index in the group list and define mappings for window management.
for i in range(1, len(groups)):
    group = groups[i - 1]
    if isinstance(group, Group):
        keys.extend([
            # mod1 + letter of group = switch to group
            Key([mod], str(i), lazy.group[group.name].toscreen(toggle=True),
                desc="Switch to group {}".format(group.name)),

            # mod1 + shift + letter of group = switch to & move focused window to group
            Key([mod, "shift"], str(i), lazy.window.togroup(group.name, switch_group=True),
                desc="Switch to & move focused window to group {}".format(group.name)),

            # mod1 + ctrl + letter of group = move focused to group but do not switch
            Key([mod, "mod1"], str(i), lazy.window.togroup(group.name),
                desc="Move focused window to group {}".format(group.name)),
        ])

#####! LAYOUTS !#####
# naming convention: keep names to 7 characters long, pad with spaces on each side
# if cannot align in the exact middle, align left
layouts = [
    layout.Tile(
        add_after_last = True,
        add_on_top = False,
        border_focus = "#efefef",
        border_normal = "#5f676a",
        margin = 4,
        ratio = 0.55,
        ratio_increment = 0.05,
        name = " tile  "
    ),
    layout.Tile(
        add_after_last = True,
        add_on_top = False,
        border_focus = "#efefef",
        border_normal = "#5f676a",
        margin = 4,
        ratio = 0.5,
        ratio_increment = 0.05,
        name = " equal "
    ),
    layout.MonadTall(
        border_focus = "#efefef",
        border_normal = "#5f676a",
        margin = 4,
        ratio = 0.55,
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
    foreground="#efefef",
)
extension_defaults = widget_defaults.copy()

from bars import primary_bottom, primary_top, secondary_top, secondary_bottom

screens = [
    Screen(
        top=primary_top,
        bottom=primary_bottom,
        left = bar.Gap(size=8),
        right = bar.Gap(size=8),
    ),
    Screen(
        top=secondary_top,
        bottom=secondary_bottom,
        left = bar.Gap(size=8),
        right = bar.Gap(size=8),
    )
]

#####! ADDITIONAL VARIABLES !#####

dgroups_key_binder = None
dgroups_app_rules = [
    Rule(
        Match(wm_type=[
            "confirm",
            "download",
            "notification",
            "toolbar",
            "splash",
            "dialog",
            "error",
        ]),
        float=True
    ),
    Rule(
        Match(wm_class=[
            "Pavucontrol",
            "Oomox",
        ]),
        float=True,
        break_on_match=False
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
    border_focus="#efefef",
    border_normal="#5f676a"
)
auto_fullscreen = True
focus_on_window_activation = "smart"

#####! WINDOW HOOKS !#####

if qtile.core.name == "x11":
    startup_script = "~/.config/qtile/autostart.sh"
elif qtile.core.name == "wayland":
    startup_script = ""

@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser(startup_script)
    subprocess.call([home])

@hook.subscribe.client_new
def floating_dialogs(window):
    dialog = window.window.get_wm_type() == 'dialog'
    transient = window.window.get_wm_transient_for()
    bubble = window.window.get_wm_window_role() == 'bubble'
    if dialog or bubble or transient:
        window.floating = True

@hook.subscribe.client_mouse_enter
def on_focus_change(window):
    if window.info()['floating']:
        window.bring_to_front()


# Needed by some Java programs
wmname = "LG3D"
