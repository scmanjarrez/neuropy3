#!/usr/bin/env python3

# SPDX-License-Identifier: GPL-3.0-or-later

# gui - Graphical User Interface module.

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

from PySide6.QtCharts import (QBarSet, QCategoryAxis, QLineSeries,
                              QSplineSeries, QValueAxis)
from PySide6.QtCore import QObject, QPointF, Signal, Slot
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtWidgets import QApplication
from neuropy3.neuropy3 import MindWave
from threading import Event, Thread
from neuropy3.gui import resources  # noqa
from PySide6.QtGui import QIcon
from queue import Queue

import neuropy3.utils as ut
import numpy as np
import math
import sys


class BackendThread(Thread):
    def __init__(self, root, backend, flag, address):
        Thread.__init__(self)
        self.root = root
        self.backend = backend
        self.flag = flag
        self.address = address
        self.queue = Queue()

    def run(self):
        self.mindwave = MindWave(address=self.address, autostart=False,
                                 verbose=2)
        ut.set_logger(self.root.newLineConsole)
        self.mindwave.update_callback('eeg', self.send_eeg)
        self.mindwave.update_callback('raw', self.send_raw)
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
            data = {band: math.log(value) for band, value in eeg.items()}
            self.backend.update_asic(data)
        except ValueError:
            pass

    def send_raw(self, raw):
        self.queue.put(raw)
        if self.queue.qsize() > ut.SAMPLE_RATE:
            microvolts = [ut.raw_to_microvolt(self.queue.get())
                          for d in range(ut.SAMPLE_RATE)]
            self.backend.update_raw(microvolts)

    def send_attention(self, att):
        self.root.attUpdate.emit(att)

    def send_meditation(self, med):
        self.root.medUpdate.emit(med)


class Backend(QObject):
    newChart = Signal(str, QLineSeries, QValueAxis)
    newPolar = Signal(QSplineSeries, QCategoryAxis)
    newBars = Signal(QBarSet, QBarSet,
                     QBarSet, QBarSet,
                     QBarSet, QBarSet,
                     QBarSet, QBarSet)

    def __init__(self):
        QObject.__init__(self)
        self.charts = {band: {'serie': None, 'axis': None}
                       for band in ut.EEG}
        self.charts['raw'] = {'serie': None, 'axis': None}
        self.asic = {band: None for band in ut.NAMES[6:]}
        self.polar = {band: idx for idx, band in enumerate(ut.NAMES[6:])}
        self.polar['serie'] = None
        self.time = np.arange(0, 1, 1/ut.SAMPLE_RATE)
        self.idx = 0

    @Slot(str, QLineSeries, QValueAxis)
    def store_new_chart(self, chart, serie, axis):
        self.charts[chart]['serie'] = serie
        self.charts[chart]['axis'] = axis

    @Slot(QSplineSeries, QCategoryAxis)
    def store_new_polar(self, serie, category):
        self.polar['serie'] = serie
        for idx, band in enumerate(self.asic):
            category.append(band.upper(), idx)

    @Slot(QBarSet, QBarSet, QBarSet, QBarSet,
          QBarSet, QBarSet, QBarSet, QBarSet)
    def store_new_bars(self, *bars):
        for band, bar in zip(ut.NAMES[6:], bars):
            self.asic[band] = bar

    def update_raw(self, microvolts):
        bands = ut.microvolts_to_bands(microvolts)
        points = {
            'raw': [QPointF(x, y) for x, y in zip(self.time, microvolts)],
            'delta': [QPointF(x, y) for x, y in zip(self.time, bands[0])],
            'theta': [QPointF(x, y) for x, y in zip(self.time, bands[1])],
            'alpha': [QPointF(x, y) for x, y in zip(self.time, bands[2])],
            'beta': [QPointF(x, y) for x, y in zip(self.time, bands[3])],
            'gamma': [QPointF(x, y) for x, y in zip(self.time, bands[4])]
        }
        minmax = {
            'raw': ut.signal_axes(microvolts),
            'delta': ut.signal_axes(bands[0]),
            'theta': ut.signal_axes(bands[1]),
            'alpha': ut.signal_axes(bands[2]),
            'beta': ut.signal_axes(bands[3]),
            'gamma': ut.signal_axes(bands[4])
        }
        for chart in points:
            self.charts[chart]['axis'].setMin(minmax[chart][0])
            self.charts[chart]['axis'].setMax(minmax[chart][1])
            self.charts[chart]['serie'].replace(points[chart])

    def update_asic(self, data):
        points = [QPointF(self.polar[band], data[band]) for band in data]
        points.append(QPointF(8, data['delta']))
        if self.idx == 0:
            self.polar['serie'].append(points)
        else:
            self.polar['serie'].replace(points)
        self.polar['serie'].setColor(
            self.asic[max(data, key=data.get)].color())
        self.idx += 1
        for band in data:
            self.asic[band].replace(0, data[band])


def main(address=None):
    thread_flag = None
    thread = None

    def thread_start():
        nonlocal thread_flag, thread
        thread_flag = Event()
        thread = BackendThread(main, backend, thread_flag, address)
        thread.start()

    def thread_quit():
        if thread_flag is not None and thread is not None:
            thread_flag.set()
            thread.join()

    app = QApplication(sys.argv)
    app.setWindowIcon(QIcon(":/icon"))
    engine = QQmlApplicationEngine()
    engine.quit.connect(app.quit)
    backend = Backend()
    backend.newChart.connect(backend.store_new_chart)
    backend.newPolar.connect(backend.store_new_polar)
    backend.newBars.connect(backend.store_new_bars)
    engine.rootContext().setContextProperty('backend', backend)
    engine.load('neuropy3/gui/gui.qml')
    main = engine.rootObjects()[0]
    main.startThread.connect(thread_start)
    main.closing.connect(thread_quit)

    sys.exit(app.exec())
