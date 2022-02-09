/* SPDX-License-Identifier: GPL-3.0-or-later */

/* gui - Graphical User Interface QML. */

/* Copyright (C) 2022 Sergio Chica Manjarrez @ pervasive.it.uc3m.es. */
/* Universidad Carlos III de Madrid. */

/* This file is part of neuropy3. */

/* neuropy3 is free software: you can redistribute it and/or modify */
/* it under the terms of the GNU General Public License as published by */
/* the Free Software Foundation, either version 3 of the License, or */
/* (at your option) any later version. */

/* neuropy3 is distributed in the hope that it will be useful, */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the */
/* GNU General Public License for more details. */

/* You should have received a copy of the GNU General Public License */
/* along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>. */

import QtQuick.Controls 6.2
import QtQuick.Layouts 6.2
import QtQuick.Window 6.2
import QtQuick 6.2
import QtCharts 6.2

ApplicationWindow {
    id: mainWindow
    title: "neuropy3"
    minimumWidth: 700
    minimumHeight: 520
    visible: true
    property int iteration: 0
    property int sPad: 10
    property int mPad: 20
    property var idMap: ({
        0: delta,
        1: theta,
        2: lowAlpha,
        3: highAlpha,
        4: lowBeta,
        5: highBeta,
        6: lowGamma,
        7: midGamma
    })
    property var oldEeg
    function debugObj(obj) {
        for (var p in obj)
            console.log(p + ": " + obj[p])
    }
    signal startThread()
    signal enableStartButton()
    onEnableStartButton: bStart.enabled = true
    signal newLineConsole(line: string)
    onNewLineConsole: line => tConsole.text = tConsole.text + line + '\n'
    signal rawUpdate(raw: int)
    onRawUpdate: raw => {
        console.log(raw)
    }
    signal attUpdate(att: int)
    onAttUpdate: att => attention.values = [att]
    signal medUpdate(med: int)
    onMedUpdate: med => meditation.values = [med]
    signal eegUpdate(eeg: var, max: int)
    onEegUpdate: (eeg, max) => {
        var data = JSON.parse(eeg);
        eeg_polar.color = idMap[max].color;
        if (iteration === 0) {
            for (var k in data) {
                eeg_polar.append(k, data[k]);
                idMap[k].values = [data[k]]
            }
            eeg_polar.append(8, data[0])
        } else {
            for (var k in data) {
                eeg_polar.replace(k, oldEeg[k], k, data[k])
                idMap[k].values = [data[k]]
            }
            eeg_polar.replace(8, oldEeg[0], 8, data[0])
        }
        oldEeg = data
        iteration++
    }
    RowLayout {
        id: boxLRPadding
        anchors.fill: parent
        Item { implicitWidth: mPad }
        ColumnLayout {
            id: boxTBPadding
            spacing: 0
            Item { implicitHeight: sPad }
            RowLayout {
                id: boxAllCharts
                PolarChartView {
                    id: polarChart
                    Layout.preferredWidth: mainWindow.width * 0.6 - sPad * 2
                    Layout.fillHeight: true
                    legend.visible: false
                    antialiasing: true
                    animationOptions: ChartView.SeriesAnimations
                    backgroundColor: Material.dialogColor
                    CategoryAxis {
                        id: axisAngular
                        min: 0
                        max: 8
                        labelsPosition: CategoryAxis.AxisLabelsPositionOnValue
                        labelsColor: Material.foreground
                        gridVisible: false
                        Component.onCompleted: {
                            append('DELTA', 0);
                            append('THETA', 1);
                            append('LALPHA', 2);
                            append('HALPHA', 3);
                            append('LBETA', 4);
                            append('HBETA', 5);
                            append('LGAMMA', 6);
                            append('MGAMMA', 7)
                        }
                    }
                    ValueAxis {
                        id: axisRadial
                        min: 0
                        max: 17
                        labelFormat: " "
                        gridVisible: false
                        lineVisible: false
                    }
                    SplineSeries {
                        id: eeg_polar
                        axisAngular: axisAngular
                        axisRadial: axisRadial
                    }
                    Component.onCompleted: {
                        margins.left = 0;
                        margins.right = 0;
                        margins.top = 0;
                        margins.bottom = 0
                    }
                }
                ColumnLayout {
                    id: boxCharts
                    spacing: 0
                    ChartView {
                        id: boxEEG
                        title: "EEG Bands"
                        Layout.preferredHeight: boxAllCharts.height * 0.5
                        Layout.fillWidth: true
                        legend.visible: false
                        antialiasing: true
                        animationOptions: ChartView.SeriesAnimations
                        backgroundColor: Material.dialogColor
                        titleColor: Material.foreground
                        BarSeries {
                            id: eeg_bar
                            barWidth: 1
                            axisX: BarCategoryAxis {
                                visible: false
                            }
                            axisY: ValueAxis {
                                min: 0
                                max: 17
                                visible: false
                            }
                            BarSet {
                                id: delta
                                values: [0]
                            }
                            BarSet {
                                id: theta
                                values: [0]
                            }
                            BarSet {
                                id: lowAlpha
                                values: [0]
                            }
                            BarSet {
                                id: highAlpha
                                values: [0]
                            }
                            BarSet {
                                id: lowBeta
                                values: [0]
                            }
                            BarSet {
                                id: highBeta
                                values: [0]
                            }
                            BarSet {
                                id: lowGamma
                                values: [0]
                            }
                            BarSet {
                                id: midGamma
                                values: [0]
                            }
                        }
                        Component.onCompleted: {
                            margins.left = 10;
                            margins.right = 10;
                            margins.top = 0;
                            margins.bottom = 10
                        }
                    }
                    ChartView {
                        id: boxESense
                        title: "eSense"
                        Layout.fillWidth: true
                        Layout.preferredHeight: boxAllCharts.height * 0.5
                        legend.alignment: Qt.AlignBottom
                        legend.font.pixelSize: 15
                        legend.labelColor: Material.foreground
                        backgroundColor: Material.dialogColor
                        titleColor: Material.foreground
                        BarSeries {
                            id: esense
                            barWidth: 1
                            axisX: BarCategoryAxis {
                                visible: false
                            }
                            axisY: ValueAxis {
                                min: 0
                                max: 100
                                tickCount: 3
                                labelsColor: Material.foreground
                            }
                            BarSet {
                                id: attention
                                label: "Attention"
                                values: [0]
                            }
                            BarSet {
                                id: meditation
                                label: "Meditation"
                                values: [0]
                            }
                        }
                        Component.onCompleted: {
                            margins.left = 6;
                            margins.right = 10;
                            margins.top = 0;
                            margins.bottom = 0;
                        }
                    }
                }
            }
            RowLayout {
                id: boxButtons
                spacing: 100
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Button {
                    id: bStart
                    text: "start"
                    onClicked: {
                        startThread();
                        bStart.enabled = false
                    }
                }
            }
            ColumnLayout {
                spacing: 0
                id: boxConsole
                Layout.preferredHeight: 120
                Label {
                    id: tOutput
                    Layout.alignment: Qt.AlignHCenter
                    text: "Output"
                    font.pixelSize: 18
                }
                ScrollView {
                    id: svConsole
                    Layout.fillWidth: true
                    Layout.preferredHeight: boxConsole.height - tOutput.height
                    TextArea {
                        id: tConsole
                        objectName: 'tConsole'
                        font: Qt.font({
                            family: "Consolas",
                            pixelSize: 15
                        })
                        wrapMode: Text.WordWrap
                        readOnly: true
                        selectByMouse: true
                        background: Rectangle {
                            color: Material.dialogColor
                        }
                    }
                    onContentHeightChanged: if (contentHeight > svConsole.height) {
                        Qt.callLater(() => contentItem.contentY = contentHeight - height)
                    }
                }
            }
            Item { implicitHeight: sPad }
        }
        Item { implicitWidth: mPad }
    }
}
