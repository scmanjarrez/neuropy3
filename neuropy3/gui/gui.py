#!/usr/bin/env python3

# SPDX-License-Identifier: GPL-3.0-or-later

# gui - Graphical User Interface module.

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

from PySide6.QtQml import QQmlApplicationEngine  # , QQmlDebuggingEnabler
from PySide6.QtWidgets import QApplication
from neuropy3.neuropy3 import MindWave
from threading import Thread, Event
from neuropy3.gui import resources  # noqa
from PySide6.QtGui import QIcon

import neuropy3.utils as ut
import json
import math
import sys


EEG = {label: idx for label, idx in
       zip(ut.NAMES[6:], range(len(ut.NAMES[6:])))}


class BackendThread(Thread):
    def __init__(self, root, flag, address):
        Thread.__init__(self)
        self.root = root
        self.flag = flag
        self.address = address

    def run(self):
        self.mindwave = MindWave(address=self.address, autostart=False,
                                 verbose=2)
        ut.set_logger(self.root.newLineConsole)
        self.mindwave.update_callback('eeg', self.send_eeg)
        # self.mindwave.update_callback('raw', self.send_raw)
        self.mindwave.update_callback('attention', self.send_attention)
        self.mindwave.update_callback('meditation', self.send_meditation)
        try:
            self.mindwave.start()
        except SystemExit:
            self.root.enableStartButton.emit()
            sys.exit()
        self.flag.wait()
        self.mindwave.stop()

    def send_eeg(self, eeg):
        if 0 in eeg.values():
            return
        try:
            log = {EEG[k]: math.log(v) for k, v in eeg.items()}
            self.root.eegUpdate.emit(json.dumps(log), max(log, key=log.get))
        except ValueError:
            pass

    def send_raw(self, raw):
        self.root.rawUpdate.emit(raw)

    def send_attention(self, att):
        self.root.attUpdate.emit(att)

    def send_meditation(self, med):
        self.root.medUpdate.emit(med)


def main(address=None):
    thread_flag = None
    thread = None

    def thread_start():
        nonlocal thread_flag, thread
        thread_flag = Event()
        thread = BackendThread(main, thread_flag, address)
        thread.start()

    def thread_quit():
        thread_flag.set()
        thread.join()

    app = QApplication(sys.argv)
    # QQmlDebuggingEnabler()
    # app = QGuiApplication([sys.argv[0], '-qmljsdebugger=port:8080,block'])
    app.setWindowIcon(QIcon(":/icon"))
    engine = QQmlApplicationEngine()
    engine.quit.connect(app.quit)
    engine.load('neuropy3/gui/gui.qml')
    main = engine.rootObjects()[0]
    main.startThread.connect(thread_start)
    main.closing.connect(thread_quit)

    sys.exit(app.exec())
