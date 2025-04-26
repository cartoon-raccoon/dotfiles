#!/usr/bin/env python3

import subprocess
import sys
#from gi.repository import Notify, GdkPixbuf

def show_zenity_dialog(type, errmsg):
    subprocess.run(["zenity", f"--{type}", f"--text={errmsg}"])

def get_taildrop_devices():
    res = subprocess.run(["tailscale", "file", "cp", "--targets"],capture_output=True)
    if res.returncode != 0:
        show_zenity_dialog("error", "Could not get devices")
        sys.exit(1)
    lines = [l.split()[:2] for l in res.stdout.decode().splitlines()]
    
    return lines

def ask_device(devices):
    args = ["zenity", "--list", "--title=Select Device",
            "--column=IP", "--column=Device"]
    
    if len(devices) == 0:
        show_zenity_dialog("warning", "No devices found with username.")
        sys.exit(0)
    
    for d in devices:
        args.extend(d)
        
    res = subprocess.run(args, capture_output=True)
    if res.returncode != 0:
        sys.exit(0)
    
    return res.stdout.decode().strip()
    
def send_on_taildrop(dev, files):
    args = ["tailscale", "file", "cp"]
    args.extend(files)
    args.append(dev + ":")

    res = subprocess.run(args, capture_output=True)
    
    return res

def main():
    if len(sys.argv) <= 1:
        show_zenity_dialog("error", "No files selected")
        sys.exit(1)
    
    files = sys.argv[1:]
    devs = get_taildrop_devices()
    send_on = ask_device(devs)
    if send_on is None:
        sys.exit(0)
    
    res = send_on_taildrop(send_on, files)
    if res.returncode > 0:
        show_zenity_dialog("error", res.stderr.decode())
    else:
        show_zenity_dialog("info", "All files sent successfully.")
        
if __name__ == "__main__":
    main()