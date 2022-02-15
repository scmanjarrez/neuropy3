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
/* along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>. */

import QtQuick.Controls 6.2
import QtQuick.Layouts 6.2
import QtQuick.Window 6.2
import QtQuick 6.2
import QtCharts 6.2

ApplicationWindow {
    id: rawWindow
    title: "neuropy3 - raw data"
    minimumWidth: 700
    minimumHeight: 920
    Material.theme: cTheme.checked ? Material.Light : Material.Dark

    property real bandSize: 0.166
    property alias rawx: rawAxis
    property alias deltax: deltaAxis
    property alias thetax: thetaAxis
    property alias alphax: alphaAxis
    property alias betax: betaAxis
    property alias gammax: gammaAxis
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
                    objectName: "testest"
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
                            min: 0
                            max: 1
                            gridVisible: false
                        }
                        axisY: ValueAxis {
                            id: rawAxis
                            min: -2
                            max: 2
                            gridVisible: false
                            labelsColor: Material.foreground
                        }
                    }
                    Component.onCompleted: backend.newChart('raw', rawLine, rawAxis)
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
                    legend.font.pixelSize: 15
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
                            id: deltaAAxis
                            min: 0
                            max: 1
                            gridVisible: false
                        }
                        axisY: ValueAxis {
                            id: deltaAxis
                            gridVisible: false
                            labelsColor: Material.foreground
                        }
                    }
                    Component.onCompleted: backend.newChart('delta', deltaLine, deltaAxis)
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
                    legend.font.pixelSize: 15
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
                            min: 0
                            max: 1
                            gridVisible: false
                        }
                        axisY: ValueAxis {
                            id: thetaAxis
                            gridVisible: false
                            labelsColor: Material.foreground
                        }
                    }
                    Component.onCompleted: backend.newChart('theta', thetaLine, thetaAxis)
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
                    legend.font.pixelSize: 15
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
                            min: 0
                            max: 1
                            gridVisible: false
                        }
                        axisY: ValueAxis {
                            id: alphaAxis
                            gridVisible: false
                            labelsColor: Material.foreground
                        }
                    }
                    Component.onCompleted: backend.newChart('alpha', alphaLine, alphaAxis)
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
                    legend.font.pixelSize: 15
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
                            min: 0
                            max: 1
                            gridVisible: false
                        }
                        axisY: ValueAxis {
                            id: betaAxis
                            gridVisible: false
                            labelsColor: Material.foreground
                        }
                    }
                    Component.onCompleted: backend.newChart('beta', betaLine, betaAxis)
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
                    legend.font.pixelSize: 15
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
                            min: 0
                            max: 1
                            gridVisible: false
                        }
                        axisY: ValueAxis {
                            id: gammaAxis
                            gridVisible: false
                            labelsColor: Material.foreground
                        }
                    }
                    Component.onCompleted: backend.newChart('gamma', gammaLine, gammaAxis)
                }
            }
            Item { implicitHeight: sPad }
        }
        Item { implicitWidth: mPad }
    }
}
