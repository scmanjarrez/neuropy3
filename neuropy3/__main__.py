

# SPDX-License-Identifier: GPL-3.0-or-later

# neuropy3 - neuropy3 backend.

# Copyright (C) 2022-2023 Sergio Chica Manjarrez @ pervasive.it.uc3m.es.
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
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


from neuropy3.neuropy3 import MindWave
from neuropy3.gui import gui

import argparse


def main():
    files = {
        'raw': None,
        'att': None,
        'med': None,
        'eeg': None
    }

    def log_raw(data):
        # Approx. one packet every 2ms
        files['raw'].write(f'{data}\n')
        files['raw'].flush()

    def log_att(data):
        # Approx. one packet every 1s
        files['att'].write(f'{data}\n')
        files['att'].flush()

    def log_med(data):
        # Approx. one packet every 1s
        files['med'].write(f'{data}\n')
        files['med'].flush()

    def log_eeg(data):
        # Approx. one packet every 1s
        files['eeg'].write(f'{",".join(map(str, data.values()))}\n')
        files['eeg'].flush()

    parser = argparse.ArgumentParser(
        prog='python -m neuropy3',
        description=("NeuroSky MindWave Mobile 2 reader."))
    parser.add_argument('-v', '--verbose',
                        choices=range(5), default=2, type=int,
                        help="Maximum verbose level.")
    parser.add_argument('-r', '--raw', metavar='RAW_FILE',
                        nargs='?',  const='raw.csv',
                        help="Stores raw data in RAW_FILE. Default: raw.csv")
    parser.add_argument('-a', '--att', metavar='ATT_FILE',
                        nargs='?',  const='att.csv',
                        help=("Stores attention data in ATT_FILE. "
                              "Default: raw.csv)"))
    parser.add_argument('-m', '--med', metavar='MED_FILE',
                        nargs='?',  const='med.csv',
                        help=("Stores meditation data in MED_FILE. "
                              "Default: raw.csv)"))
    parser.add_argument('-e', '--eeg', metavar='EEG_FILE',
                        nargs='?',  const='eeg.csv',
                        help="Stores eeg data in EEG_FILE. Default: eeg.csv")
    parser.add_argument('-g', '--gui',
                        action='store_true',
                        help="Graphical interface to represent headset data.")
    parser.add_argument('-d', '--address',
                        metavar='bd_address',
                        help="MindWave Mobile bluetooth device address (MAC).")
    args = parser.parse_args()

    if not args.gui:
        mw = MindWave(args.address, autostart=False, verbose=args.verbose)
        if args.raw is not None:
            files['raw'] = open(args.raw, 'w')
            mw.update_callback('raw', log_raw)
        if args.att is not None:
            files['att'] = open(args.att, 'w')
            mw.update_callback('attention', log_att)
        if args.med is not None:
            files['med'] = open(args.med, 'w')
            mw.update_callback('meditation', log_med)
        if args.eeg is not None:
            files['eeg'] = open(args.eeg, 'w')
            mw.update_callback('eeg', log_eeg)
        mw.start()
        if mw.thread is not None:
            try:
                mw.thread.join()
            except KeyboardInterrupt:
                mw.stop()
                for file in files.values():
                    if file is not None:
                        file.close()
    else:
        gui.main(args.address)


if __name__ == '__main__':
    main()
