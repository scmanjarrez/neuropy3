#!/usr/bin/env python3

# SPDX-License-Identifier: GPL-3.0-or-later

# neuropy3 - Backend module.

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

from threading import Thread, Event
from neuropy3 import utils as ut

import bluetooth
import struct
import sys


class MindWaveReader(Thread):
    """Thread class running in background. It reads every packet
    sent by NeuroSky MindWave Mobile 2 and updated MindWave class
    data.
    :param data: Shared data with MindWave class, updated on packet received
    :type data: dict
    :param callbacks: Shared callbacks with MindWave class,
                      called on packet type received (if present)
    :type callbacks: dict
    :param flag: Event flag to stop thread on demand
    :type flag: threading.Event
    :param socket: Bluetooth socket
    :type socket: bluetooth.BluetoothSocket
    :param verbose: Verbose level
    :type verbose: int. Allowed values: 0-4
    """
    def __init__(self, data, callbacks, flag, socket, verbose):
        Thread.__init__(self)
        self.data = data
        self.callbacks = callbacks
        self.flag = flag
        self.socket = socket
        self.verbose = verbose
        self.step = 0
        self.new = []

    def run(self):
        """Starts the read thread loop"""
        while not self.flag.is_set():
            self._read_packet()

    def _read(self, n_bytes=1):
        """Reads bytes from bluetooth socket
        :param n_bytes: Number of bytes to read
        :type n_bytes: int, optional. Default: 1
        :return: A bytearray read from bluetooth socket
        :rtype: bytearray"""
        self.socket.settimeout(5)
        try:
            return self.socket.recv(n_bytes)
        except bluetooth.btcommon.BluetoothError:
            ut.log('error', "Bluetooth timed out. Check headset is on.",
                   self.verbose)
            sys.exit(1)

    def _b2i(self, value, n_bytes=1):
        """Converts bytes to integer
        Depending of the size of the bytes, integer can be signed
        or unsigned. More info in thinkgear communications protocol
        :param value: Value to be converted
        :type value: bytearray
        :param n_bytes: Number of bytes to be converted
        :type n_bytes: int, optional. Allowed: 1, 2, 4. Default: 1
        :return: Value after converting bytearray
        :rtype: int"""
        vtype = '>B'
        if n_bytes == 2:
            vtype = '>h'
        elif n_bytes == 4:
            vtype = '>I'
        return struct.unpack(vtype, value)[0]

    def _read_eeg(self, values):
        """Parses ASIC_EEG_POWER payload to eeg bands
        :param values: Packets to be parsed
        :type values: bytearray"""
        for idx, band in enumerate(ut.NAMES[6:]):
            self.data['values']['eeg'][band] = self._b2i(
                b'\x00' + b''.join(values[idx*3:idx*3+3]), 4)
        if 'eeg' in self.callbacks:
            self.callbacks['eeg'](self.data['values']['eeg'])

    def _valid_payload(self):
        """Checks payload length and checksum"""
        valid = (False, None, 0)
        plength = self._b2i(self._read())
        if plength >= ut.PLENGTH_MAX:
            ut.log('warn', "Packet length too large. Packet discarded.",
                   self.verbose)
        else:
            payload = []
            chksum = 0
            for idx in range(plength):
                packet = self._read()
                payload.append(packet)
                chksum += self._b2i(packet)
            checksum = self._b2i(self._read())
            chksum = ~chksum & 0xFF
            if chksum != checksum:
                ut.log('warn', "Checksum failed. Packet discarded.",
                       self.verbose)
            else:
                valid = (True, payload, plength)
        return valid

    def _read_packet(self):
        """Reads packets and stores in shared data dict"""
        # Synchronize on SYNC bytes
        if self._read() != ut.BYTE['sync']:
            return
        if self._read() != ut.BYTE['sync']:
            return
        valid, payload, plength = self._valid_payload()
        if valid:
            self.data['packets'] += 1
            idx = 0
            while idx < plength:
                known = True
                code = payload[idx]
                ut.log('succ', f"Reading packet: {code}", self.verbose)
                if code in (ut.BYTE['step1'], ut.BYTE['step2']):
                    self.step += 1
                    if self.step == 2:
                        ut.log('info',
                               "MindWave connection established.",
                               self.verbose)
                    return
                elif code < ut.BYTE['_max']:
                    idx += 1
                    value = payload[idx]
                    if ut.CODE[code] in ut.NAMES[:5]:
                        value = self._b2i(value)
                        self._update(ut.CODE[code], value)
                        if code == ut.BYTE['signal']:
                            if value == ut.NO_CONTACT:
                                ut.log('warn',
                                       "MindWave electrodes are not in "
                                       "contact with your skin.",
                                       self.verbose)
                            elif value:
                                ut.log('warn',
                                       "MindWave poor signal detected. "
                                       "Check electrodes or "
                                       "interferences.",
                                       self.verbose)
                    else:
                        known = False
                else:
                    idx += 1
                    vlength = self._b2i(payload[idx])
                    if code == ut.BYTE['raw']:
                        if vlength != ut.PKT_RAW_MAX:
                            ut.log('warn',
                                   f"RAW wrong number of bytes: "
                                   f"{vlength}. Expected: {ut.PKT_RAW_MAX}. "
                                   f"Packet discarded.",
                                   self.verbose)
                        else:
                            value = self._b2i(
                                b''.join(payload[idx+1:idx+1+vlength]), 2)
                            self._update('raw', value)
                    elif code == ut.BYTE['eeg']:
                        if vlength != ut.PKT_EEG_MAX:
                            ut.log('warn',
                                   f"EEG wrong number of bytes: "
                                   f"{vlength}. Expected: {ut.PKT_EEG_MAX}. "
                                   f"Packet discarded.",
                                   self.verbose)
                        else:
                            self._read_eeg(payload[idx+1:idx+1+vlength])
                    else:
                        known = False
                    idx += vlength
                if not known:
                    ut.log('warn',
                           f"Code not recognized: {code}. "
                           f"Packet discarded.",
                           self.verbose)
                idx += 1

    def _update(self, name, value):
        """Updates shared data value and executes callback if present
        :param name: Name of variable to be updated
        :type name: str
        :param value: New value
        :type value: int"""
        self.data['values'][name] = value
        if name in self.callbacks:
            self.callbacks[name](value)


class MindWave:
    """Main class. Interface to interact with read data from NeuroSky
    MindWave Mobile 2
    :param address: Bluetooth address of NeuroSky MindWave Mobile 2
    :type address: str, optional
    :param autostart: Starts automatically MindWaveReader
    :type autostart: bool, optional. Default: True
    :param verbose: Verbose level
    :type verbose: int, optional. Allowed values: 0-4. Default: 1
    """
    def __init__(self, address=None, autostart=True, verbose=1):
        self.address = address
        self.verbose = verbose
        self._data = {
            'packets': 0,
            'values': {
                'signal': 0, 'attention': 0, 'meditation': 0, 'raw': 0,
                'eeg': {
                    'delta': 0, 'theta': 0,
                    'alpha_l': 0, 'alpha_h': 0,
                    'beta_l': 0, 'beta_h': 0,
                    'gamma_l': 0, 'gamma_m': 0
                }
            }
        }
        self.callbacks = {}
        self.thread = None
        self.socket = None
        self.flag = Event()
        if autostart:
            self.start()

    def scan(self):
        """Scans bluetooth devices for MindWave Mobile address"""
        if self.address is None:
            ut.log('info', "Scanning bluetooth devices...", self.verbose)
            try:
                devices = {v: k for k, v in
                           bluetooth.discover_devices(lookup_names=True)}
            except OSError:
                ut.log('error',
                       "Could not use bluetooth. Check bluetooth is on.",
                       self.verbose)
                sys.exit(1)
            else:
                if 'MindWave Mobile' not in devices:
                    ut.log('error',
                           "Could not find MindWave Mobile device. "
                           "Check that headset is on.", self.verbose)
                    sys.exit(1)
                else:
                    self.address = devices['MindWave Mobile']

    def connect(self):
        """Establishes connection with MindWave Mobile"""
        if self.socket is None:
            try:
                ut.log('info',
                       f"Connecting to MindWave Mobile "
                       f"({self.address})...",
                       self.verbose)
                self.socket = bluetooth.BluetoothSocket()
                self.socket.connect((self.address, 1))
            except bluetooth.btcommon.BluetoothError as e:
                ut.log('error',
                       f"Could not connect to MindWave Mobile: "
                       f"{e.strerror}", self.verbose)
                sys.exit(1)

    def start_reader(self):
        """Starts reader thread"""
        if self.thread is not None and self.thread.is_alive():
            ut.log('warn', "Background thread already started.", self.verbose)
        else:
            self.flag.clear()
            self.thread = MindWaveReader(self._data, self.callbacks,
                                         self.flag, self.socket,
                                         self.verbose)
            self.thread.start()

    def start(self):
        """Run 3 steps connection: scan, connect and start_reader
        This function simplifies the execution, not required"""
        self.scan()
        self.connect()
        self.start_reader()

    def stop(self):
        """Stops the reader thread"""
        if self.thread is not None and self.thread.is_alive():
            self.flag.set()
            self.thread.join()
            self.thread = None
            self.socket.close()
            self.socket = None

    def set_callback(self, target, callback):
        """Define callback function for a given target
        Executes a function when a value is updated

        :param target: The value to be tracked
        :type target: str
        :param callback: A function handle of the form ``callback(data)``,
                         where data is an `int` containing the updated value.
        :type callback: function"""
        self.callbacks[target] = callback

    def unset_callback(self, target):
        """Remove callback for a given target

        :param target: The value to be untracked
        :type target: str"""
        if target in self.callbacks:
            del self.callbacks[target]

    def received(self):
        """Total packets received (and valid)"""
        return self.data['packets']

    def data(self, name):
        """Current value of variable
        :param name: Name of variable to request.
        :type name: str. Allowed values: signal, attention, meditation,
                         raw, eeg
        :return: Value of requested variable
        :rtype: int
        """
        if name in self._data['values']:
            return self._data['values'][name]
        else:
            ut.log('error', f"Name must be: {ut.NAMES}", self.verbose)
            return None
