#!/usr/bin/env python3

# a script to display current bindings

import subprocess
from collections import namedtuple

Keybind = namedtuple('Keybind', ["modmask", "key", "desc", "dispatcher"])

SUPER_MOD_MASK = 0b1000000
SHIFT_MOD_MASK = 0b0000001
CTRL_MOD_MASK  = 0b0000100
