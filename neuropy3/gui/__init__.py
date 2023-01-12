#!/usr/bin/env python3

import sys

try:
    import PySide6
except ModuleNotFoundError:
    print("In order to run neuropy3.gui, install extra dependencies with "
          "'pip install neuropy3[gui]'")
    sys.exit(1)
