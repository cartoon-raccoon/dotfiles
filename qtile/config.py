# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

from typing import List  # noqa: F401

from libqtile import bar, layout, widget
from libqtile.config import Click, Drag, Group, Key, KeyChord, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile import hook

import os
import subprocess

mod = "mod4"
terminal = guess_terminal()

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
    Key([mod, "control"], "h", lazy.layout.grow_left(),
        desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(),
        desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(),
        desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "shift"], "Return", lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack"),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),

    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    
    # Toggle fullscreen and floating
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen."),
    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating,"),

    # Basic QTile commands
    Key([mod, "control"], "r", lazy.restart(), desc="Restart Qtile"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawncmd(),
        desc="Spawn a command using a prompt widget"),

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

groups = [Group(' '), Group(' '), Group(' '), Group(' '), Group('ﳁ ')]

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

layouts = [
    layout.Tile(
        border_focus = "#efefef",
        border_normal = "#5f676a",
        margin = 4,
        name = " tile  "
    ),
    layout.Columns(
        border_focus_stack='#efefef',
        border_focus='#efefef',
        border_normal='#5f676a',
        margin = 4,
        name = "columns"
    ),
    layout.Max(
        name = "  max  "
    ),
    layout.Stack(
        border_focus = "#efefef",
        border_normal = "#5f676a",
        num_stacks=2,
        margin = 4,
        name = " stack "
    ),
    layout.Bsp(
        border_focus = "#efefef",
        border_normal = "#5f676a",
        margin = 4,
        name = "  bsp  "
    ),
    # layout.Matrix(),
    # layout.MonadTall(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

widget_defaults = dict(
    font='FiraCode Nerd Font',
    fontsize=14,
    padding=3,
)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        bottom=bar.Bar(
            [
                widget.CurrentLayout(),
                widget.GroupBox(
                    highlight_method = 'line',
                    highlight_color = ['202020', '343434'],
                    this_current_screen_border = 'fabd2f',
                    this_screen_border = 'fabd2f',
                ),
                widget.Spacer(length = 10),
                widget.Prompt(),
                widget.WindowName(),
                widget.Chord(
                    chords_colors={
                        'launch': ("#ff0000", "#ffffff"),
                    },
                    name_transform=lambda name: name.upper(),
                ),
                widget.Systray(),
                widget.Spacer(length = 8),
                widget.Clock(format='%Y-%m-%d %a %I:%M %p'),
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
        ),
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front())
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
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

@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser('~/.config/qtile/autostart.sh')
    subprocess.call([home])


# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
