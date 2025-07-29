#!/usr/bin/python3

import subprocess
import sys
import os
import psutil
import signal
import json
import argparse

SAVEFILE_PREFIX = ".ddc_brightness"
WAYBAR_PROC_NAME = "waybar"
WAYBAR_DEFAULT_SIGNAL = 5
# the default monitor to query or set if the -m argument is not set.
DEFAULT_MON_IDX = 1
# the VCP brightness feature ID.
VCP_FEATURE_VALUE = 10
HELP_MSG = """
ddc-brightness.py: A script to control and query external monitor brightness using ddcutil,
with Waybar integration.

Usage:

ddc-brightness.py [-srj] [OPTIONS] [VALUE]

If called without VALUE, the script simply queries the brightness of the given monitor.
If VALUE is provided, the monitor brightness is set to VALUE.

You can specify VALUE to indicate a relative or absolute brightness change, by appending the value with
a `+` or `-`, to increase or decrease the brightness respectively. For example, `10+` will increase the
brightness by 10%, while `20-` will decrease the brightness by 20%, and `80` will set the brightness
to 80%.

# Flags

`-s/--save`: Save the new brightness to a file, which can be specified using the `--save-file` option.
             If VALUE is provided, the queried brightness is saved.

`-r/--restore`: Restore the brightness from a file using the above default file. This ignores VALUE, if provided.

`-j/--json`: Output the brightness formatted as JSON compatible with the format expected by Waybar custom modules.

# Options

`-m/--monitor MONITOR`: The index of the monitor to query. You can see which monitors use which indexes by
                         running `ddcutil detect`. If not specified, the default monitor index is 1.

`-w/--waybar-signal [NUM]`: Signal the running instance of Waybar to update the displayed brightness.
                            NUM is the SIGRT number to use (calculated using SIGRTMIN + NUM) to signal Waybar.
                            If it is not provided, it defaults to 5 
                            (i.e. the signal sent to Waybar will be SIGRTMIN + 5).

# Examples

To query the brightness of monitor 1:
$ ddc-brightness.py

The same operation as above, but formatted in JSON for Waybar:
$ ddc-brightness.py -j

To set the brightness of monitor 2 to 80%, and save it:
$ ddc-brightness.py -m 2 -s 80

To decrease the brightness of monitor 3 by 10%, and signal Waybar with the default signal:
$ ddc-brightness.py -m 3 -w 10-
"""

parser = argparse.ArgumentParser(add_help=True)
parser.add_argument(
    '-s', '--save', action='store_true',
    help="save the queried or set brightness to a file"
)
parser.add_argument(
    '-r', '--restore', action='store_true',
    help="restore the brightness from a previously saved file"
)
parser.add_argument(
    '-j', '--json', action='store_true',
    help="format the query into JSON compatible with Waybar custom modules"
)
parser.add_argument(
    '-m', '--monitor', default=DEFAULT_MON_IDX, metavar="MONITOR",
    help="specify the monitor to use"
)
parser.add_argument(
    '-w', '--waybar-signal', nargs='?', metavar="SIGNAL", const=WAYBAR_DEFAULT_SIGNAL,
    help="signal Waybar with the given signal number (defaults to 5)"
)
parser.add_argument(
    '--no-verify-savefile', action='store_true',
    help="if the --save flag is present and VALUE is a delta, assume the value stored in the savefile is consistent"
)
parser.add_argument(
    "value", metavar="VALUE", help="the value to set", nargs='?', default=None
)

args = parser.parse_args()


def parse_value(value: str):
    if value.endswith("+") or value.endswith("-"):
        return int(value[:-1]), value[-1]
    else:
        return int(value), None


def run_ddcutil(monitor, value=None, delta=None):
    """
    Runs ddcutil.

    If `value` is provided, `setvcp` (The set operation) is run. Otherwise, `getvcp`
    (The query operation) is run. `delta` is only read if `value` is provided,
    otherwise it is ignored.

    If a query operation is run, the current brightness is returned as an integer.
    If a set operation is run, None is returned.

    If either operation fails, an exception that contains the error string returned
    by ddcutil is raised.
    """
    
    cmd_base = ["ddcutil", "-d", str(monitor)]
    ret = None

    if value is not None:
        # run setvcp
        # todo: parse value
        cmd = cmd_base.extend(["setvcp", str(VCP_FEATURE_VALUE)])
        if delta is not None:
            cmd.append(delta)
        cmd.append()
        res = subprocess.run(cmd, capture_output=True)
        pass
    else:
        # run getvcp
        cmd = cmd_base.extend(["getvcp", str(VCP_FEATURE_VALUE)])
        res = subprocess.run(cmd, capture_output=True)
        # todo: parse output
        pass

    return ret


def resolve_savefile(monitor: int):
    dir = None
    try:
        dir = os.environ["XDG_DATA_HOME"]
    except KeyError:
        dir = os.environ["HOME"]
    
    return f"{dir}/{SAVEFILE_PREFIX}{monitor}"


def get_waybar_proc():
    for proc in psutil.process_iter():
        if proc.name() == WAYBAR_PROC_NAME:
            return proc
    
    return None


def query_brightness(monitor, save_file=None):

    pass


def set_brightness(monitor, value, save_file=None, restore=False, signalnum: int=None):
    """
    Sets the brightness, returning the new brightness if it can be calculated.

    There is a problem when saving to a file on a delta. We cannot
    """
    if restore:
        # restore a previously saved brightness.
        pass # todo

    value, delta = parse_value(value)

    set_brightness(monitor, value)
    
    # signal waybar if a signal number is provided.
    if signalnum is not None:
        proc = get_waybar_proc()
        if proc is not None:
            proc.send_signal(signal.SIGRTMIN + signalnum)
        else:
            print("ERROR: Unable to find waybar process", file=sys.stderr)


def format_json():
    # todo: json
    pass


def main():
    print(args)
    # todo: process parsed args and dispatch accordingly

    # if args.value is None:
    #     query_brightness(args.monitor, args.save_file)
    # else:
    #     set_brightness(args.monitor, args.value, )

    pass


if __name__ == "__main__":
    main()           

