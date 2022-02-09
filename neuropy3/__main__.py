#!/usr/bin/env python3

# SPDX-License-Identifier: GPL-3.0-or-later

# neuropy3 - neuropy3 backend.

# Copyright (C) 2022 Sergio Chica Manjarrez @ pervasive.it.uc3m.es.
# Universidad Carlos III de Madrid.

# This file is part of neuropy3.

# neuropy3 is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# neuropy3 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.


from neuropy3.neuropy3 import MindWave
from neuropy3.gui import gui

import argparse


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        prog='python -m neuropy3',
        description=("NeuroSky MindWave Mobile 2 reader."))
    parser.add_argument('--verbose',
                        choices=range(5), default=2, type=int,
                        help="Maximum verbose level.")
    parser.add_argument('--gui',
                        action='store_true',
                        help="Graphical interface to represent headset data.")
    parser.add_argument('-a', '--address',
                        metavar='bd_address',
                        help="MindWave Mobile bluetooth device address (MAC).")
    args = parser.parse_args()
    if not args.gui:
        mw = MindWave(args.address, verbose=args.verbose)
        if mw.thread is not None:
            try:
                mw.thread.join()
            except KeyboardInterrupt:
                mw.stop()
    else:
        gui.main(args.address)
