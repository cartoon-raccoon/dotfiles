##### cartoon-raccoon's qtile config file #####

# symlinked to ~/.config/qtile/config.py.

from typing import List  # noqa: F401

from libqtile import bar, layout
from libqtile.config import Click, Drag, Group, ScratchPad, DropDown, Key, KeyChord, Match, Screen, Rule
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile import hook
from libqtile import qtile
from libqtile.log_utils import logger

import os
import subprocess
import datetime

import bars

mod = "mod4"

terminal = "alacritty" 

#####! KEYBINDS !#####

keys = [
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(),
        desc="Move window focus to other window"),
    Key(["mod1"], "Page_Up", lazy.layout.next(), desc="Move focus to next window"),
    Key(["mod1"], "Page_Down", lazy.layout.previous(), desc="Move focus to previous window"),

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
    Key([mod], "minus", lazy.window.toggle_minimized()),
    Key([mod], "m", lazy.group.setlayout("max"), desc="Set 'max' layout"),
    Key([mod], "e", lazy.group.setlayout("equal"), desc="Set 'equal' layout"),
    Key([mod], "t", lazy.group.setlayout("tile"), desc="Set 'tile' layout"),
    Key([mod], "w", lazy.group.setlayout("tabbed"), desc="Set 'tabbed' layout"),

    # Basic QTile commands
    Key([mod, "control"], "r", lazy.restart(), desc="Restart Qtile"),
    Key([mod, "shift"], "r", lazy.reload_config(), desc="Reload Qtile config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.function(bars.spawncmd),
        desc="Spawn a command using a prompt widget"),

    # dropdown commands
    Key([], 'F11', lazy.group['dropdowns'].dropdown_toggle('term'),
        desc="Toggle a dropdown terminal"),
    Key([], 'F12', lazy.group['dropdowns'].dropdown_toggle('qshell'),
        desc="Toggle a dropdown Qtile shell"),

    # music control keys
    Key([mod], "grave", lazy.spawn("mpc toggle"), desc="Pause or play MPD"),
    Key([mod], "period", lazy.spawn("mpc next"), desc="Skip to the next song on MPD"),
    Key([mod], "comma", lazy.spawn("mpc prev"), desc="Move to the previous song on MPD"),
    Key([mod], "XF86AudioPlay", lazy.spawn("mpc toggle"), desc="Play/pause MPD"),
    Key([mod], "XF86AudioNext", lazy.spawn("mpc next"), desc="Skip to next song on MPD"),
    Key([mod], "XF86AudioPrev", lazy.spawn("mpc prev"), desc="Move to previous song on MPD"),
    Key(["mod1"], "XF86AudioPlay", lazy.spawn("mpc toggle"), desc="Play/pause MPD (Alt)"),
    Key(["mod1"], "XF86AudioNext", lazy.spawn("mpc next"), desc="Skip to next song on MPD (Alt)"),
    Key(["mod1"], "XF86AudioPrev", lazy.spawn("mpc prev"), desc="Move to previous song on MPD (Alt)"),
    Key([mod, "shift"], "p", lazy.function(bars.mpd_play_playlist),
        desc="Activate MPD playlist prompt"),

    # Spotify keybinds
    Key([], "XF86AudioPlay", lazy.spawn("/home/sammy/.config/spotify-dbus.sh -t"),
        desc="Play/pause Spotify"),
    Key([], "XF86AudioNext", lazy.spawn("/home/sammy/.config/spotify-dbus.sh -n"),
        desc="Skip to the next song on Spotify"),
    Key([], "XF86AudioPrev", lazy.spawn("/home/sammy/.config/spotify-dbus.sh -p"),
        desc="Move to the previous song on Spotify"),
    Key([mod, "shift"], "period", lazy.spawn("/home/sammy/.config/spotify-dbus.sh -n")),
    Key([mod, "shift"], "comma", lazy.spawn("/home/sammy/.config/spotify-dbus.sh -p")),
    Key([mod], "a", lazy.widget["wbox_mpd"].toggle(),
        desc="Show/hide the MPD bar widget"),
    Key([mod], "s", lazy.widget["wbox_spotify"].toggle(),
        desc="Show/hide the Spotify bar widget"),
    Key([], 'F10', lazy.group['music'].dropdown_toggle('ncmpcpp'),
        desc="Toggle a dropdown NCMPCPP window"),

    KeyChord([mod, "shift"], "m", [
            Key([], "s", lazy.widget["wbox_spotify"].toggle(),
                desc="Show/hide the MPD bar widget"),
            Key([], "m", lazy.widget["wbox_mpd"].toggle(),
                desc="Show/hide the Spotify bar widget"),

            Key([mod, "shift"], "m", lazy.ungrab_all_chords(),
                desc="Leave the chord")
        ],
        mode=True,
        name="music",
        desc="A chord to toggle the music app widgets on the top bar"
    ),

    # volume and brightness control
    Key([], 'XF86AudioRaiseVolume', lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%"),
        desc="Raise volume by 5%"),
    Key([], 'XF86AudioLowerVolume', lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%"),
        desc="Lower volume by 5%"),
    Key([], 'XF86AudioMute', lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle"),
        desc="Mute/unmute"),

    Key([], 'XF86MonBrightnessUp', lazy.spawn("brightnessctl set +10%"),
        desc="Raise screen brightness"),
    Key([], 'XF86MonBrightnessDown', lazy.spawn("brightnessctl set 10%-"),
        desc="Lower screen brightness"),

    # screenshot keys
    Key([mod],"Print", lazy.spawn("/home/sammy/.config/scrot/run.sh"),
        desc="Take a screenshot of the full screen"),
    Key([mod, "shift"], "Print", lazy.spawn("/home/sammy/.config/scrot/run.sh -u"),
        desc="Take a screenshot of the active window"),
    Key([mod, "shift"], "f", lazy.spawn("flameshot"),
        desc="Launch flameshot"),    
    
    # Launch mode: keyboard shortcuts to launch a bunch of programs.
    KeyChord([mod],"p", [
        KeyChord([], "f", [
            Key([], "i", lazy.spawn("firefox"), desc="Launch Firefox"),
            Key([], "r", lazy.spawn("freecad"), desc="Launch FreeCAD"),
        ], name="f"),
        KeyChord([], "s", [
            Key([], "p", lazy.spawn("spotify"), desc="Launch Spotify"),
            Key([], "t", lazy.spawn("steam"), desc="Launch Steam"),
        ], name="s"),
        KeyChord([], "t", [
            Key([], "h", lazy.spawn("thunar"), desc="Launch File Explorer"),
            Key([], "e", lazy.spawn("texmaker"), desc="Launch TexMaker"),
        ], name="t"),
        Key([], "a", lazy.spawn("anki"), desc="Launch Anki"),
        Key([], "k", lazy.spawn("kicad"), desc="Launch KiCAD"),
        Key([], "o", lazy.spawn("obsidian"), desc="Launch Obsidian"),
        KeyChord([], "n", [
            Key([], "n", lazy.spawn("notion-app"), desc="Launch Notion"),
            Key([], "c", lazy.spawn("alacritty -e ncmpcpp"), desc="launch ncmpcpp"),
        ], name="n"),
        Key([], "d", lazy.spawn("discord"), desc="Launch Discord"),
        Key([], "c", lazy.spawn("code"), desc="Launch VSCode"),
        Key([], "r", lazy.spawn("alacritty -e ranger"), desc="Launch Ranger"),
        Key([], "m", lazy.spawn("minecraft-launcher"), desc="Launch Minecraft"),
        Key([], "v", lazy.spawn("vmware"), desc="Launch VMWare"),
        Key([], "l", lazy.spawn("logisim-evolution"), desc="Launch Logisim"),

        Key([mod], "p", lazy.ungrab_all_chords(),
            desc="Leave the chord"),
    ], name="launch"),

    # Hackery mode: to launch cysec tools but i use more cli tools lol
    KeyChord([mod], "o", [
        Key([], "c", lazy.spawn("cutter"), desc="Launch Cutter"),
        Key([], "g", lazy.spawn("gdbgui"), desc="Launch GDBGUI"),
        Key([], "d", lazy.spawn("ghidra"), desc="Ghidra"),
        Key([], "w", lazy.spawn("wireshark"), desc="Launch Wireshark"),
        Key([], "v", lazy.spawn("vmware"), desc="Launch VMWare"),
        Key([], "q", lazy.spawn("qFlipper"), desc="Launch qFlipper"),

        Key([mod], "o", lazy.ungrab_all_chords(),
            desc="Leave the chord"),
    ], name="hackery"),

    # Design mode: to launch design tools
    KeyChord([mod], "i", [
        Key([], "f", lazy.spawn("freecad"), desc="Launch FreeCAD"),
        Key([], "k", lazy.spawn("kicad"), desc="KiCAD"),
        Key([], "l", lazy.spawn("logisim-evolution"), desc="Launch Logisim"),

        Key([mod], "i", lazy.ungrab_all_chords(),
            desc="Leave the chord"),
    ], name="design"),

    Key([mod], "g", lazy.spawn("/home/sammy/.config/i3/i3lock"),
        desc="Lock the system"),
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
        [mod], "Button4", lazy.layout.next(),
    ),
    Click(
        [mod], "Button5", lazy.layout.prev(),
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

# all groups with associated Keybinds
groups_with_kbs = [
    # main
    Group('HOME', layout="max", spawn=["firefox"], matches=[Match(wm_class="firefox")], label=' '), 
    # dev
    Group('DEV', layout="max", spawn=["code"], matches=[Match(wm_class="code")], label=' '), 
    # terminals
    Group('TERMINAL', layout="equal", spawn = ["alacritty", "alacritty"], label=' '),
    # files
    Group('FILES', spawn=["thunar"], label=' '), 
    # social
    Group('SOCIAL', spawn=["discord"], matches=[Match(wm_class="discord")],label=' '),
    # music
    Group('MUSIC', layout="equal", spawn=["spotify", "alacritty -e ncmpcpp"], label=' '),
    # misc
    Group('MISC', layout="equal", label=' '),
    # note taking
    Group('NOTES', layout="max", spawn=["obsidian"], label='󰠮 '),
    # reading
    Group('READING', layout="tabbed", 
        matches=[
            Match(wm_class="com.github.johnfactotum.Foliate"),
            Match(wm_class="evince"),
        ],
        label=' '
    ),
]

groups = groups_with_kbs + [
    ScratchPad("music",[
        DropDown("ncmpcpp", "alacritty -e ncmpcpp",
            height=0.7,
            width=0.4,
            x=0,
            on_focus_lost_hide=False,
        )
    ], single=True),
    # dropdowns
    ScratchPad("dropdowns", [
        DropDown("term", "alacritty", 
            opacity=0.9,
            height=0.5,
            width=0.4,
            x=0.6,
            on_focus_lost_hide=False,
        ),
        DropDown("qshell", "alacritty -e qtile shell",
            opacity=0.9,
            height=0.5,
            width=0.4,
            x=0.6, y=0.5,
            on_focus_lost_hide=False,
        )
    ]),
]

# Bind group to its index in the group list and define mappings for window management.
for i in range(1, len(groups_with_kbs) + 1):
    group = groups_with_kbs[i - 1]
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
        name = "tile"
    ),
    layout.Tile(
        add_after_last = True,
        add_on_top = False,
        border_focus = "#efefef",
        border_normal = "#5f676a",
        margin = 4,
        ratio = 0.5,
        ratio_increment = 0.05,
        name = "equal"
    ),
    layout.MonadTall(
        border_focus = "#efefef",
        border_normal = "#5f676a",
        margin = 4,
        ratio = 0.55,
        name = "monadt"
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
        name = "tabbed"
    ),
    layout.Max(
        name = "max"
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
def should_float(window):
    # floating check
    dialog = window.window.get_wm_type() == 'dialog'
    transient = window.window.get_wm_transient_for()
    bubble = window.window.get_wm_window_role() == 'bubble'

    return dialog or bubble or transient is not None

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
        Match(func=should_float),
        float=True,
        break_on_match=True,
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
        Match(wm_class="blueman-manager"), # blueman 
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
    startup_script = "~/.config/qtile/autostart_wl.sh"

@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser(startup_script)
    subprocess.call([home])

    # if window.window.get_wm_class()[0] == "evince":
    #     window.togroup('READING')

@hook.subscribe.client_new
def on_new_client(window):
    if should_float(window):
        window.enable_floating()

# @hook.subscribe.client_mouse_enter
# def on_focus_change(window):
#     if window.info()['floating']:
#         window.bring_to_front()


# Needed by some Java programs
wmname = "LG3D"
