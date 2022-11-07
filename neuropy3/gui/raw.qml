/* SPDX-License-Identifier: GPL-3.0-or-later */

/* raw - Graphical User Interface (Raw data) QML. */

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
/* along with this program.  If not, see <https://www.gnu.org/licenses/>. */

import QtQuick.Controls 6.2
import QtQuick.Layouts 6.2
import QtQuick.Window 6.2
import QtQuick 6.2
import QtCharts 6.2

ApplicationWindow {
    id: rawWindow
    title: "neuropy3 - raw"
    minimumWidth: 700
    minimumHeight: 920
    Material.theme: cTheme.checked ? Material.Light : Material.Dark

    property real bandSize: 0.166
    property var axisMap: ({
        'rawx': rawXAxis, 'rawy': rawYAxis,
        'deltax': deltaXAxis, 'deltay': deltaYAxis,
        'thetax': thetaXAxis, 'thetay': thetaYAxis,
        'alphax': alphaXAxis, 'alphay': alphaYAxis,
        'betax': betaXAxis, 'betay': betaYAxis,
        'gammax': gammaXAxis, 'gammay': gammaYAxis
    })
    RowLayout {
        id: boxWLRPadding
        anchors.fill: parent
        Item { implicitWidth: mPad }
        ColumnLayout {
            id: boxWTBPadding
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 0
            Item { implicitHeight: sPad }
            Rectangle {
                Layout.preferredHeight: (rawWindow.height - sPad * 2) * bandSize
                Layout.fillWidth: true
                color: Material.dialogColor
                clip: true
                ChartView {
                    id: rawSignal
                    title: "Raw Signal"
                    anchors.fill: parent
                    legend.visible: false
                    antialiasing: true
                    animationOptions: ChartView.SeriesAnimations
                    backgroundColor: Material.dialogColor
                    backgroundRoundness: 0
                    titleColor: Material.foreground
                    margins {
                        left: 0
                        top: 0
                        right: 0
                        bottom: 0
                    }
                    LineSeries {
                        id: rawLine
                        axisX: ValueAxis {
                            id: rawXAxis
                            min: 0
                            max: 1
                            gridVisible: false
                            labelsColor: Material.foreground
                        }
                        axisY: ValueAxis {
                            id: rawYAxis
                            min: -200
                            max: 200
                            gridVisible: false
                            labelsColor: Material.foreground
                        }
                    }
                    Component.onCompleted: backend.newChart('raw', rawLine, rawYAxis)
                }
            }
            Rectangle {
                Layout.preferredHeight: (rawWindow.height - sPad * 2) * bandSize
                Layout.fillWidth: true
                color: Material.dialogColor
                clip: true
                ChartView {
                    id: deltaSignal
                    title: "Delta Signal"
                    anchors.fill: parent
                    legend.visible: false
                    antialiasing: true
                    animationOptions: ChartView.SeriesAnimations
                    backgroundColor: Material.dialogColor
                    backgroundRoundness: 0
                    titleColor: Material.foreground
                    margins {
                        left: 0
                        top: 0
                        right: 0
                        bottom: 0
                    }
                    LineSeries {
                        id: deltaLine
                        objectName: 'deltaLine'
                        axisX: ValueAxis {
                            id: deltaXAxis
                            min: 0
                            max: 1
                            gridVisible: false
                            labelsColor: Material.foreground
                        }
                        axisY: ValueAxis {
                            id: deltaYAxis
                            min: -200
                            max: 200
                            gridVisible: false
                            labelsColor: Material.foreground
                        }
                    }
                    Component.onCompleted: backend.newChart('delta', deltaLine, deltaYAxis)
                }
            }
            Rectangle {
                Layout.preferredHeight: (rawWindow.height - sPad * 2) * bandSize
                Layout.fillWidth: true
                color: Material.dialogColor
                clip: true
                ChartView {
                    id: thetaSignal
                    title: "Theta Signal"
                    anchors.fill: parent
                    legend.visible: false
                    antialiasing: true
                    animationOptions: ChartView.SeriesAnimations
                    backgroundColor: Material.dialogColor
                    backgroundRoundness: 0
                    titleColor: Material.foreground
                    margins {
                        left: 0
                        top: 0
                        right: 0
                        bottom: 0
                    }
                    LineSeries {
                        id: thetaLine
                        axisX: ValueAxis {
                            id: thetaXAxis
                            min: 0
                            max: 1
                            gridVisible: false
                            labelsColor: Material.foreground
                        }
                        axisY: ValueAxis {
                            id: thetaYAxis
                            min: -200
                            max: 200
                            gridVisible: false
                            labelsColor: Material.foreground
                        }
                    }
                    Component.onCompleted: backend.newChart('theta', thetaLine, thetaYAxis)
                }
            }
            Rectangle {
                Layout.preferredHeight: (rawWindow.height - sPad * 2) * bandSize
                Layout.fillWidth: true
                color: Material.dialogColor
                clip: true
                ChartView {
                    id: alphaSignal
                    title: "Alpha Signal"
                    anchors.fill: parent
                    legend.visible: false
                    antialiasing: true
                    animationOptions: ChartView.SeriesAnimations
                    backgroundColor: Material.dialogColor
                    backgroundRoundness: 0
                    titleColor: Material.foreground
                    margins {
                        left: 0
                        top: 0
                        right: 0
                        bottom: 0
                    }
                    LineSeries {
                        id: alphaLine
                        axisX: ValueAxis {
                            id: alphaXAxis
                            min: 0
                            max: 1
                            gridVisible: false
                            labelsColor: Material.foreground
                        }
                        axisY: ValueAxis {
                            id: alphaYAxis
                            min: -200
                            max: 200
                            gridVisible: false
                            labelsColor: Material.foreground
                        }
                    }
                    Component.onCompleted: backend.newChart('alpha', alphaLine, alphaYAxis)
                }
            }
            Rectangle {
                Layout.preferredHeight: (rawWindow.height - sPad * 2) * bandSize
                Layout.fillWidth: true
                color: Material.dialogColor
                clip: true
                ChartView {
                    id: betaSignal
                    title: "Beta Signal"
                    anchors.fill: parent
                    legend.visible: false
                    antialiasing: true
                    animationOptions: ChartView.SeriesAnimations
                    backgroundColor: Material.dialogColor
                    backgroundRoundness: 0
                    titleColor: Material.foreground
                    margins {
                        left: 0
                        top: 0
                        right: 0
                        bottom: 0
                    }
                    LineSeries {
                        id: betaLine
                        axisX: ValueAxis {
                            id: betaXAxis
                            min: 0
                            max: 1
                            gridVisible: false
                            labelsColor: Material.foreground
                        }
                        axisY: ValueAxis {
                            id: betaYAxis
                            min: -200
                            max: 200
                            gridVisible: false
                            labelsColor: Material.foreground
                        }
                    }
                    Component.onCompleted: backend.newChart('beta', betaLine, betaYAxis)
                }
            }
            Rectangle {
                Layout.preferredHeight: rawWindow.height * bandSize
                Layout.fillWidth: true
                color: Material.dialogColor
                clip: true
                ChartView {
                    id: gammaSignal
                    title: "Gamma Signal"
                    anchors.fill: parent
                    legend.visible: false
                    antialiasing: true
                    animationOptions: ChartView.SeriesAnimations
                    backgroundColor: Material.dialogColor
                    backgroundRoundness: 0
                    titleColor: Material.foreground
                    margins {
                        left: 0
                        top: 0
                        right: 0
                        bottom: 0
                    }
                    LineSeries {
                        id: gammaLine
                        axisX: ValueAxis {
                            id: gammaXAxis
                            min: 0
                            max: 1
                            gridVisible: false
                            labelsColor: Material.foreground
                        }
                        axisY: ValueAxis {
                            id: gammaYAxis
                            min: -200
                            max: 200
                            gridVisible: false
                            labelsColor: Material.foreground
                        }
                    }
                    Component.onCompleted: backend.newChart('gamma', gammaLine, gammaYAxis)
                }
            }
            Item { implicitHeight: sPad }
        }
        Item { implicitWidth: mPad }
    }
}
