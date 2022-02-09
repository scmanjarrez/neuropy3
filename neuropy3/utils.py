#!/usr/bin/env python3

# SPDX-License-Identifier: GPL-3.0-or-later

# neuropy3 - Utilities module.

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

_RED = '\033[91m'
_YELLOW = '\033[93m'
_BLUE = '\033[94m'
_GREEN = '\033[92m'
_CLEANC = '\033[0m'
_NC = ''

LOG = {
    'normal': '[*] ',
    'succ': '[+] ', 'info': '[*] ',
    'warn': '[-] ', 'error': '[!] '
}

BYTE = {
    'sync': b'\xaa',
    'step1': b'\xba',
    'step2': b'\xbc',
    'signal': b'\x02',
    'attention': b'\x04',
    'meditation': b'\x05',
    'raw': b'\x80',
    'eeg': b'\x83',
    '_max': b'\x7f'
}
CODE = {v: k for k, v in BYTE.items()}
NAMES = ['battery', 'signal', 'attention', 'meditation', 'blink',
         'raw', 'delta', 'theta', 'alpha_l', 'alpha_h',
         'beta_l', 'beta_h', 'gamma_l', 'gamma_m']
PLENGTH_MAX = 170
NO_CONTACT = 200
EEG_MAX = 24
RAW_MAX = 2
WINDOW = None


def disable_ansi_colors():
    """Disable ANSI colors in log messages."""
    global _GREEN, _BLUE, _YELLOW, _RED, _CLEANC
    _GREEN = _BLUE = _YELLOW = _RED = _CLEANC = _NC


def set_logger(window):
    global WINDOW
    if WINDOW is None:
        WINDOW = window
        disable_ansi_colors()


def log(ltype, msg, level):
    """Print information, warning or error messages to stdout.
    :param ltype: Type of message. Allowed values: succ, info, warn or error.
    :type ltype: str
    :param msg: Message to print.
    :type msg: str
    :param level: Maximum level to print messages. Allowed values: 0-4
    :type level: int"""
    color = LOG[ltype]
    pmsg = False
    if ltype == 'succ':
        color = f'{_GREEN}{color}{_CLEANC}'
        if level > 3:
            pmsg = True
    elif ltype == 'warn':
        color = f'{_YELLOW}{color}{_CLEANC}'
        if level > 2:
            pmsg = True
    elif ltype == 'info':
        color = f'{_BLUE}{color}{_CLEANC}'
        if level > 1:
            pmsg = True
    elif ltype == 'error':
        color = f'{_RED}{color}{_CLEANC}'
        if level:
            pmsg = True

    if pmsg:
        if WINDOW is not None:
            WINDOW.emit(f"{color}{msg}")
        else:
            print(f"{color}{msg}")
