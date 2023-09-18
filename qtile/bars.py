# bar definitions for QTile. imported by the main config.py file.

# symlinked to ~/.config/qtile/bars.py.

# the top bar. not currently in use.
from typing import List  # noqa: F401
import copy

from libqtile import bar, layout, widget

import datetime

# Used in the MPD widget to truncate titles if they get too long
def title_truncate(s):
    if len(s) > 30:
        return f"{s[:30]}..."
    else:
        return s

# Used in the MPD widget to truncate artist lists
def artist_truncate(s):
    splits = s.split(",")
    if len(splits) > 2:
        return ",".join(splits[:2]) + ", Various"
    else:
        return s
    
colors = {
    "blue"  : '#2d728f',
    "green" : '#659157',
}

primary_top = bar.Bar(
    [
        widget.Mpd2(
            status_format = "{play_status} {artist}: {title} ({elapsed}/{duration}) [ {repeat}{random}{single}{consume}]",
            idle_format = " {idle_message} ",
            idle_message = "Rien à jouer",
            format_fns = dict(
                #all=lambda s: cgi.escape(s),
                artist=artist_truncate,
                title=title_truncate,
                elapsed=lambda s: str(datetime.timedelta(seconds=int(float(s))))[2:],
                duration=lambda s: str(datetime.timedelta(seconds=int(float(s))))[2:],
            ),
            padding = 10,
            fontsize = 13,
            play_states = {'play': ' ', 'pause': ' ', 'stop' : ' '},
            prepare_status = {
                'consume': '󰆘 ', 
                'random' : ' ', 
                'repeat' : '󰑖 ',
                'single' : '󰑘 ',
                'updating_db': 'ﮮ ',
            },
            space = '- ',
            update_interval = 0.5,
            markup = False,
        ),
        widget.Volume(
            fmt = '󰕾 {}',
            fontsize = 13,
        ),
        widget.Spacer(length = bar.STRETCH),
        widget.TextBox(text = '',
            foreground = '#2d728f',
            fontsize = 60,
            padding = -9,
        ),
        widget.DF(
            fmt = '/ {}',
            fontsize = 13,
            partition = '/home',
            format = '{uf}{m} ({r:.0f}%)',
            visible_on_warn = False,
            background = '#2d728f',
            padding = 5,
        ),
        widget.TextBox(text = '',
            background = '#2d728f',
            foreground = '#659157',
            fontsize = 60,
            padding = -9,
        ),
        widget.Memory(
            fmt = "  {}",
            format = '{MemUsed: .0f}M ({MemPercent: .1f}%)',
            fontsize = 13,
            background = '#659157',
            padding = 5,

        ),
        widget.TextBox(text = '',
            background = '#659157',
            foreground = '#932546',
            fontsize = 60,
            padding = -9,
        ),
        widget.CPU(
            fmt = " {}",
            format = "{freq_current}GHz ({load_percent}%)",
            fontsize = 13,
            background = '#932546',
            padding = 5,
        ),
        widget.TextBox(text = '',
            background = '#932546',
            foreground = '#4a314d',
            fontsize = 60,
            padding = -9,
        ),
        widget.Net(
            interface = "wlp6s0",
            format = " {down}   {up}  ",
            fontsize = 13,
            background = '#4a314d',
            padding = 5,
        ),
        widget.TextBox(text = '',
            background = '#4a314d',
            foreground = '#d79921',
            fontsize = 60,
            padding = -9,
        ),
        widget.Battery(
            fmt = "{}",
            format = "[{char}] {percent:2.0%} {hour:d}:{min:02d} ",
            charge_char = 'C',
            discharge_char = 'D',
            empty_char = 'E',
            fontsize = 13,
            background = '#d79921',
            padding = 5,
        ),
        widget.TextBox(text = '',
            background = '#d79921',
            foreground = '#d16014',
            fontsize = 60,
            padding = -9,
        ),
        widget.ThermalSensor(
            fmt = ' {}',
            fontsize = 13,
            background = '#d16014',
            padding = 5,
        )
    ],
    30,
    margin = [0, 0, 4, 0],
    background = "#202020",
)

# the bottom bar.
primary_bottom = bar.Bar(
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
        #widget.Mpris2(
        #    fmt = '{title}',
        #    name = 'spotify',
        #    objname = 'org.mpris.MediaPlayer2.spotify',
        #),
        widget.Chord(
            chords_colors={
                'launch': ("#fabd2f", "#282828"),
                'hackery': ("#fabd2f", "#282828"),
                'design': ("#fabd2f", "#282828"),
            },
            name_transform=lambda name: name.upper(),
        ),
        widget.TextBox(text = '|'),
        widget.CapsNumLockIndicator(
            
        ),
        widget.TextBox(text = '|'),
        widget.Systray(),
        widget.Spacer(length = 8),
        widget.Clock(format='%A, %d %b %Y %H:%M'),
        widget.Spacer(length = 8),
        widget.QuickExit(
            padding = 1,
            foreground = 'fb4934',
            default_text = '[ 󰗼 ]',
            countdown_format = '[ {} ]'
        ),
    ],
    30,
    margin = [4, 0, 0, 0],
    background = '#202020',
)

secondary_top = bar.Bar(
    [],
    30,
    margin = [0, 0, 4, 0],
    background = '#202020',
    opacity = 100
)

secondary_bottom = bar.Bar(
    [],
    30,
    margin = [4, 0, 0, 0],
    background = '#202020',
    opacity = 100
)