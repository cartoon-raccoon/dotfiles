#!/usr/bin/env python3

# a mildly-overengineered script to generate a background for i3lock
# that can adapt to multihead setups.

# symlinked to ~/.i3lock-bkgd.

# todo: support for different backgrounds per output

import re
import os
import sys
import shutil
import subprocess
import pickle
import hashlib

MISSING_CMD_CODE = 1
MISSING_ENV_CODE = 2

HASH_SCHEME = "md5"

# consts
BKGD_ENV_VAR = "LOCKSCREEN_BKGD"
DEFAULT_FFORMAT = "png"

try:
    HOME_DIR = os.environ["HOME"]
except KeyError as e:
    print(f"ERROR: {e}")
    sys.exit(MISSING_ENV_CODE)

OUTPUT_DIR = f"{HOME_DIR}/.local/share/i3lock-bkgd"
CACHE_DIR = f"{HOME_DIR}/.cache/i3lock-bkgd"

# check current layout against this hash everytime the script runs
# if the hash is the same, we don't need to generate the layout
LAYOUT_HASH_PATH = f"{OUTPUT_DIR}/layout.{HASH_SCHEME}"


class Config(object):
    """
    Object containing all configuration for this script to work.
    """
    def __init__(self):
        """
        Ensures that the environment contains all the needed
        commands and environment variables, and constructs the config.
        """
        
        try:
            self.bkgd_path = os.environ[BKGD_ENV_VAR]
        except KeyError as e:
            print(f"ERROR: missing {BKGD_ENV_VAR} environment variable")
            sys.exit(MISSING_ENV_CODE)
        
        self.output_path = f"{OUTPUT_DIR}/multihead.{DEFAULT_FFORMAT}"


class Geometry(object):
    """
    A geometry of a window (its dimensions and position).
    """
    def __str__(self):
        return f"{self.width}x{self.height}+{self.x}+{self.y}"

    def __repr__(self):
        return f"Geometry({self.width}, {self.height}, {self.x}, {self.y})"


    def __init__(self, w, h, x, y):
        self.width = w
        self.height = h
        self.x = x
        self.y = y


class Output(object):
    """
    A physical screen with an associated name and geometry.
    """

    def __repr__(self):
        return f"Output('{self.name}', {self.geom})"


    def __init__(self, name: str, geom: Geometry):
        self.name = name
        self.geom = geom


class XRandR(object):
    """
    Runs `xrandr`, reads in its output, and parses display data when queried.

    All queries are lazily executed, so the parsing happens only when its
    corresponding method is called.
    """

    # regex to match on the total dimensions of the virtual display.
    CURRENT_SCREEN_RE = r"current ([0-9]+) x ([0-9]+)"
    # regex to match on the dimensions and position of the physical output.
    OUTPUT_RE = r"^([a-zA-Z]+-[0-9]+) [ a-zA-Z0-9]* ([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)"

    def __init__(self):
        xrandr = shutil.which("xrandr")
        if not xrandr:
            print("ERROR: could not find command `xrandr`")
            sys.exit(MISSING_CMD_CODE)
        
        self.screen_re = re.compile(self.CURRENT_SCREEN_RE)
        self.output_re = re.compile(self.OUTPUT_RE)

        self.xrandr_output = subprocess.run(
            ["xrandr", "-q"], 
            capture_output=True, 
            encoding="UTF-8"
        ).stdout


    def get_virt_display(self) -> Geometry:
        """
        Parses `xrandr` output for the screen geometry.
        """

        for line in self.xrandr_output.split("\n"):
            check = self.screen_re.search(line)
            if check:
                break

        width = int(check.group(1))
        height = int(check.group(2))

        return Geometry(width, height, 0, 0)


    def get_outputs(self) -> list[Output]:
        """
        Parses `xrandr` output to get all the outputs currently connected.
        """

        outputs = []

        for line in self.xrandr_output.split("\n"):
            check = self.output_re.search(line)
            if check:
                outputs.append(Output(
                    check.group(1),
                    Geometry(
                        int(check.group(2)),
                        int(check.group(3)),
                        int(check.group(4)),
                        int(check.group(5))
                    )
                ))

        return outputs


class ConvertError(Exception):
    """
    Exception raised if a convert command fails.
    """

    def __init__(self, errorcode: int, errmsg: str):
        self.errorcode = errorcode
        self.errmsg = errmsg


class Layout(object):
    """
    An object which lays out all the items on the virtual canvas,
    and generates the image that is needed.
    """

    # the command that should be run. defaults to imagemagick convert.
    MAIN_CMD = "convert"
    # base args for the final invocation.
    ARGS = [MAIN_CMD, "-colorspace", "sRGB"]

    def __init__(self, screen: Geometry, outputs: list[Output]):
        self.canvas = screen
        self.outputs = outputs
        # arguments to be run in the final command.
        self.args = []

    
    def generate(self, input_file: str, output_file: str):
        """
        Lays out the geometries on the virtual canvas,
        and runs `convert` to generate the image.
        """
        convert = shutil.which(self.MAIN_CMD)
        if not convert:
            print("ERROR: could not find command `convert`")
            sys.exit(MISSING_CMD_CODE)

        file_ext = input_file.split(".")[1]


        for output in self.outputs:
            fingerprint = int.from_bytes(hash_obj(output), byteorder='little')
            cache_path = f"{CACHE_DIR}/{output.name}-{fingerprint}.{file_ext}"

            geom = output.geom
            # create a resized image for each output
            if not os.path.exists(cache_path):
                args = [
                    self.MAIN_CMD, 
                    input_file,
                    "-resize", f"{geom.width}x{geom.height}^",
                    "-gravity", "Center",
                    "-crop", f"{geom.width}x{geom.height}+0+0",
                    "+repage",
                    cache_path
                ]
                result = subprocess.run(args, capture_output=True)
                if result.returncode != 0:
                    raise ConvertError(result.returncode, result.stderr.decode())

            self.args.extend([
                "-type", "TrueColor", # preserve color
                cache_path, # cached image path
                "-geometry", f"+{geom.x}+{geom.y}", # give it the required offset
                "-composite" # composite it into the main image
            ])

        # create the background image
        result = subprocess.run([
            self.MAIN_CMD,
            "-size", f"{self.canvas.width}x{self.canvas.height}",
            "xc:black", output_file],
            capture_output=True
        )
        if result.returncode != 0:
            raise ConvertError(result.returncode, result.stderr.decode())

        # combine all the arguments together
        self.args = self.ARGS + [output_file] + self.args + [output_file]
        # print(" ".join(self.args))

        # composite the images onto it
        result = subprocess.run(self.args, capture_output=True)
        if result.returncode != 0:
            raise ConvertError(result.returncode, result.stderr.decode())


def hash_obj(obj) -> bytes:
    return hashlib.md5(pickle.dumps(obj)).digest()


def params_changed(layout: Layout, bkgd_path: str) -> bool:
    """
    Checks if the layout has changed since the script was last run.
    """
    fingerprint = hash_obj((layout, bkgd_path))
    missing_dirs = False
    
    if not os.path.exists(OUTPUT_DIR):
        os.mkdir(OUTPUT_DIR)
        missing_dirs = True
    
    if not os.path.exists(CACHE_DIR):
        print("cache does not exist")
        os.mkdir(CACHE_DIR)
        missing_dirs = True
    
    if not os.path.exists(LAYOUT_HASH_PATH):
        missing_dirs = True
        with open(LAYOUT_HASH_PATH, "wb") as f:
            f.write(fingerprint)

    if missing_dirs:
        return True
    
    with open(LAYOUT_HASH_PATH, "r+b") as f:
        current_f = f.read()
        f.seek(0)
        f.write(fingerprint)
    
    return fingerprint != current_f


if __name__ == "__main__":
    print("===== DESKTOP BACKGROUND GENERATOR =====")
    
    print("[*] Getting outputs...")
    xrandr = XRandR()
    screen = xrandr.get_virt_display()
    outputs = xrandr.get_outputs()

    print("[*] Getting config")
    config = Config()

    layout = Layout(screen, outputs)
    if not params_changed(layout, config.bkgd_path):
        print("[*] Layout has not changed, no action needed")
        sys.exit(0)
    else:
        print("[*] Layout change detected, proceeding")
    
    print(f"\nSCREEN: {screen}")
    for output in outputs:
        print(f"OUTPUT {output.name}: {output.geom}")


    print(f"\nBACKGROUND FILE: {config.bkgd_path}")
    print(f"OUTPUT PATH: {config.output_path}")

    print("\n[*] Generating background with layout...")
    try:
        layout.generate(config.bkgd_path, config.output_path)
    except ConvertError as e:
        print(f"[!] Image conversion failed with errorcode {e.errorcode}:")
        print(f"{e.errmsg}")
        sys.exit(e.errorcode + 2 if e.errorcode > 0 else e.errorcode)

    print("[*] Done! ^_^")
    sys.exit(0)