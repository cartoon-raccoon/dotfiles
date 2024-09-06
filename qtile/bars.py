# bar definitions for QTile. imported by the main config.py file.

# symlinked to ~/.config/qtile/bars.py.

# the top bar. not currently in use.
from typing import List  # noqa: F401
import copy

from libqtile import bar, layout, widget

import datetime

def current_window_textparse(text):
    pass

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
    
mpdprompt = widget.Prompt(
    name="mpdprompt",
    background="#d12a48",
    padding=10,
)
def mpd_play_playlist(qtile):
    def callback(s):
        qtile.spawn("mpc clear")
        qtile.spawn(f"mpc load {s}")
        qtile.spawn("mpc play")
    mpdprompt.start_input("PLAYLIST", callback)
    
colors = {
    "blue"  : '#2d728f',
    "green" : '#659157',
}


primary_top = bar.Bar(
    [
        widget.PulseVolume(
            background="#ffe733",
            foreground="#282828",
            cardid=6,
            fmt='󰕾 {}',
            font="FiraCode Nerd Font Bold Italic",
            step=5,
            padding=15,
        ),
        widget.TextBox(text=" ",
            foreground="#ffe733",
            background="#d12a48",
            fontsize=36,
            padding=-1,
        ),
        widget.WidgetBox(
            widgets=[
                widget.Mpd2(
                    status_format = "{play_status} {artist}: {title} ({elapsed}/{duration}) [ {repeat}{random}{single}{consume}]",
                    idle_format = "{idle_message}",
                    idle_message = "Rien à jouer",
                    background="#d12a48",
                    format_fns = dict(
                        #all=lambda s: cgi.escape(s),
                        artist=artist_truncate,
                        title=title_truncate,
                        elapsed=lambda s: str(datetime.timedelta(seconds=int(float(s))))[2:],
                        duration=lambda s: str(datetime.timedelta(seconds=int(float(s))))[2:],
                    ),
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
            ],
            padding=10,
            text_closed="󰝚  MPD",
            text_open="󰝚 ",
            background="#d12a48",
            font="FiraCode Nerd Font Bold",
            name="wbox_mpd",
        ),
        mpdprompt,
        # widget.Sep(
        #     padding=0,
        #     linewidth=2,
        #     size_percent=100,
        # ),
        widget.TextBox(text=" ",
            foreground="#d12a48",
            background="#1db954",
            fontsize=36,
            padding=-1,
        ),
        widget.WidgetBox(
            widgets=[
                widget.Mpris2(
                    format='{xesam:artist}: {xesam:title}',
                    playing_text='  {track} ',
                    paused_text='  {track} ',
                    max_chars=65,
                    scroll=False,
                    name='spotify',
                    objname='org.mpris.MediaPlayer2.spotify',
                    background="#1db954",
                ),
            ],
            text_closed="󰓇  SPOTIFY",
            text_open="󰓇 ",
            background="#1db954",
            font="FiraCode Nerd Font Bold",
            name="wbox_spotify",
            padding=10,
        ),
        widget.TextBox(text=" ",
            foreground="#1db954",
            fontsize=36,
            padding=-1,
        ),
        widget.Spacer(length=bar.STRETCH),
        widget.TextBox(text='',
            foreground='#2d728f',
            fontsize=36,
            padding= 1,
        ),
        widget.DF(
            fmt = '/  {}',
            partition='/home',
            format='{uf}{m} ({r:.0f}%)',
            visible_on_warn=False,
            background='#2d728f',
            padding=5,
        ),
        widget.TextBox(text = '',
            background = '#2d728f',
            foreground = '#659157',
            fontsize = 36,
            padding = 1,
        ),
        widget.Memory(
            fmt = " {}",
            format = '{MemUsed: .0f}M ({MemPercent: .1f}%) ',
            background = '#659157',
            padding = 5,
        ),
        widget.TextBox(text='',
            background='#659157',
            foreground='#932546',
            fontsize=36,
            padding=1,
        ),
        widget.CPU(
            format="  {freq_current}GHz ({load_percent}%) ",
            background='#932546',
            padding=5,
        ),
        widget.TextBox(text = '',
            background='#932546',
            foreground='#4a314d',
            fontsize=36,
            padding=1,
        ),
        widget.Wlan(
            ethernet_interface="enp197s0f3u1",
            ethernet_message="  Ethernet",
            interface="wlp5s0",
            disconnected_message="Disconnected ",
            format="  {essid}: {percent:2.0%}",
            background='#4a314d',
            use_ethernet=True,
        ),
        widget.WidgetBox(
            widgets=[
                widget.Net(
                    background="#4a314d",
                    format="{down:6.2f}{down_suffix:<2}  {up:6.2f}{up_suffix:<2}  "
                ),
            ],
            text_closed="",
            text_open="",
            background="#4a314d",
            font="FiraCode Nerd Font Bold",
            name="wbox_netusage",
            padding=10,
        ),
        widget.TextBox(text='',
            background='#4a314d',
            foreground='#d79921',
            fontsize= 36,
            padding=1,
        ),
        widget.Battery(
            format="{char} {percent:2.0%} {hour:d}:{min:02d} ",
            charge_char='󰂄',
            discharge_char='󱊢',
            empty_char='󰂎',
            full_char='󱊣',
            unknown_char='󰂑',
            not_charging_char='󰂃',
            background='#d79921',
            padding=5,
            notify_below=0.15,
            show_short_text=False,
        ),
        widget.TextBox(text='',
            background='#d79921',
            foreground='#d16014',
            fontsize=36,
            padding=1,
        ),
        widget.ThermalZone(
            format=' {temp}°C ',
            format_crit=' {temp}°C ',
            background='#d16014',
            high=60,
            crit=80,
            padding=5,
        )
    ],
    35,
    margin = [0, 0, 4, 0],
    background = "#202020",
)

prompt = widget.Prompt(name="spawnprompt")
def spawncmd(qtile):
    def callback(s):
        qtile.spawn(s)
    prompt.start_input("SPAWN", callback, complete="cmd")

# the bottom bar.
primary_bottom = bar.Bar(
    [
        widget.CurrentLayout(
            width=80,
            padding=20,
        ),
        widget.GroupBox(
            highlight_method='line',
            highlight_color=['#202020', '#343434'],
            this_current_screen_border='#fabd2f',
            this_screen_border='#fabd2f',
            visible_groups=[
                "HOME",
                "DEV",
                "TERMINAL",
                "FILES",
                "SOCIAL",
                "MUSIC",
                "MISC",
                "NOTES",
                "READING",
                "GAMING",
            ],
            name="primary-groupbox"
        ),
        widget.Spacer(length=15),
        prompt,
        widget.Spacer(length=15),
        widget.WindowName(
            for_current_screen=True,
        ),
        widget.Chord(
            chords_colors={
                'launch': ("#fabd2f", "#282828"),
                'hackery': ("#d16014", "#282828"),
                'design': ("#2d728f", "#282828"),
                'f': ("#932546", "#eeeeee"),
                't': ("#932546", "#eeeeee"),
                's': ("#932546", "#eeeeee"),
                'music': ("#1db954", "#ffffff"),
            },
            name_transform=lambda name: name.upper(),
            padding=5,
        ),
        widget.TextBox(text=" ",
            foreground="#474a4a",
            fontsize=27,
            padding=-1,
        ),
        widget.Pomodoro(
            fmt="{} ",
            fontsize=20,
            font="FiraCode Nerd Font Bold",
            color_break="#fabd2f",
            color_active="#659157",
            color_inactive="#ec2d01",
            prefix_break="  ",
            prefix_long_break="  ",
            prefix_active="  ",
            prefix_inactive="  START",
            prefix_paused="  PAUSED",
            background="#474a4a",
            padding=0,
        ),
        widget.TextBox(text=" ",
            foreground="#474a4a",
            fontsize=27,
            padding=-1,
        ),
        widget.Sep(padding=5),
        widget.CapsNumLockIndicator(),
        widget.Sep(padding=5),
        widget.Systray(
            padding=5,
            icon_size=25,
        ),
        widget.Spacer(length=4),
        widget.Sep(padding=5),
        widget.Spacer(length=4),
        widget.OpenWeather(
            app_key="2f510c7719431cdcefc151bc394597a4",
            location="Singapore, SG",
            format='{main_temp:.0f} ({main_feels_like:.0f})°{units_temperature} {humidity}% {icon}'
        ),
        widget.Spacer(length=8),
        widget.Clock(format='%a. %d %b %Y %H:%M'),
        widget.Spacer(length=8),
        widget.QuickExit(
            padding=1,
            foreground='#fb4934',
            default_text='[ 󰗼 ]',
            countdown_format='[ {} ]'
        ),
        widget.Spacer(length=8),
    ],
    35,
    margin = [4, 0, 0, 0],
    background = '#202020',
)

secondary_top = bar.Bar(
    [
        widget.Wttr(
            format="%l: %t (%f) [%C]",
            # location={
            #     "Toronto": "Toronto"
            # },
            lang="en",
            fontsize=15
        ),
        widget.Spacer(bar.STRETCH),
        widget.KhalCalendar(

        )
    ],
    35,
    margin = [0, 0, 4, 0],
    background = '#202020',
    opacity = 100
)

secondary_bottom = bar.Bar(
    [
        widget.TaskList(
            highlight_method='block',
            icon_size=14,
            fontsize=15,
            padding=5,
            max_title_width=300,
            txt_floating="🗗 ",
            txt_minimized="🗕 ",
            txt_maximized="🗖 "
        ),
        widget.Spacer(length=bar.STRETCH),
        widget.GroupBox(
            highlight_method='line',
            highlight_color=['#202020', '#343434'],
            this_current_screen_border='#fabd2f',
            this_screen_border='#fabd2f',
            visible_groups=[
                "HOME",
                "DEV",
                "TERMINAL",
                "FILES",
                "SOCIAL",
                "MUSIC",
                "MISC",
                "NOTES",
                "READING",
            ],
            name="secondary-groupbox"
        ),
        widget.CurrentLayout(
            padding=5,
            width=70,
        ),
    ],
    35,
    margin = [4, 0, 0, 0],
    background = '#202020',
    opacity = 100
)
