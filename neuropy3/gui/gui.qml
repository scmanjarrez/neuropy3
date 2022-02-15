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
    Material.theme: cTheme.checked ? Material.Light : Material.Dark

    property int sPad: 10
    property int mPad: 20
    function debugObj(obj) {
        for (var p in obj)
            console.log(p + ": " + obj[p])
    }
    signal startThread()
    signal enableStartButton()
    onEnableStartButton: bStart.enabled = true
    signal newLineConsole(line: string)
    onNewLineConsole: line => tConsole.text = tConsole.text + line + '\n'
    signal attUpdate(att: int)
    onAttUpdate: att => attention.values = [att]
    signal medUpdate(med: int)
    onMedUpdate: med => meditation.values = [med]
    Loader {
        id: rawLoader
        objectName: 'rawLoader'
        source: "raw.qml"
        property alias item: rawLoader.item
    }
    menuBar: MenuBar {
        id: mainMenuBar
        font.pixelSize: 11
        Layout.fillWidth: true
        Menu {
            title: qsTr("&Settings")
            font.pixelSize: 12
            font.weight: Font.Light
            MenuItem {
                id: cRaw
                objectName: 'cRaw'
                text: qsTr("Show &raw data")
                checkable: true
                onToggled: {
                    if (checked) {
                        rawLoader.item.show()
                    } else {
                        rawLoader.item.hide()
                    }
                }
            }
            MenuItem {
                id: cTheme
                objectName: 'cTheme'
                text: qsTr("&Light theme")
                checkable: true
                onToggled: {
                    axisAngular.labelsColor = Material.foreground;
                    eSenseAxis.labelsColor = Material.foreground;
                    boxESense.legend.color = Material.foreground;
                    rawLoader.item.rawx.labelsColor = Material.foreground;
                    rawLoader.item.deltax.labelsColor = Material.foreground;
                    rawLoader.item.thetax.labelsColor = Material.foreground;
                    rawLoader.item.alphax.labelsColor = Material.foreground;
                    rawLoader.item.betax.labelsColor = Material.foreground;
                    rawLoader.item.gammax.labelsColor = Material.foreground;
                }
                Component.onCompleted: checked = Material.theme === Material.Light
            }
        }
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
                spacing: 0
                Rectangle {
                    Layout.preferredWidth: parent.width * 0.6
                    Layout.fillHeight: true
                    color: Material.dialogColor
                    clip: true
                    PolarChartView {
                        id: polarChart
                        anchors.fill: parent
                        legend.visible: false
                        antialiasing: true
                        animationOptions: ChartView.SeriesAnimations
                        backgroundColor: Material.dialogColor
                        backgroundRoundness: 0
                        margins {
                            left: 0
                            top: 0
                            right: 0
                            bottom: 0
                        }
                        CategoryAxis {
                            id: axisAngular
                            min: 0
                            max: 8
                            labelsPosition: CategoryAxis.AxisLabelsPositionOnValue
                            gridVisible: false
                            labelsColor: Material.foreground
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
                            id: eegPolar
                            axisAngular: axisAngular
                            axisRadial: axisRadial
                        }
                        Component.onCompleted: backend.newPolar(eegPolar, axisAngular)
                    }
                }
                ColumnLayout {
                    id: boxCharts
                    spacing: 0
                    Rectangle {
                        Layout.preferredHeight: boxAllCharts.height * 0.5
                        Layout.fillWidth: true
                        color: Material.dialogColor
                        clip: true
                        ChartView {
                            id: boxEEG
                            title: "EEG Bands"
                            anchors.fill: parent
                            legend.visible: false
                            antialiasing: true
                            animationOptions: ChartView.SeriesAnimations
                            backgroundColor: Material.dialogColor
                            backgroundRoundness: 0
                            titleColor: Material.foreground
                            margins {
                                left: 10
                                top: 0
                                right: 10
                                bottom: 10
                            }
                            BarSeries {
                                id: eegBar
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
                                    id: alphaLow
                                    values: [0]
                                }
                                BarSet {
                                    id: alphaHigh
                                    values: [0]
                                }
                                BarSet {
                                    id: betaLow
                                    values: [0]
                                }
                                BarSet {
                                    id: betaHigh
                                    values: [0]
                                }
                                BarSet {
                                    id: gammaLow
                                    values: [0]
                                }
                                BarSet {
                                    id: gammaMid
                                    values: [0]
                                }
                            }
                            Component.onCompleted: backend.newBars(delta, theta,
                                                                   alphaLow, alphaHigh,
                                                                   betaLow, betaHigh,
                                                                   gammaLow, gammaMid)
                        }
                    }
                    Rectangle {
                        Layout.preferredHeight: boxAllCharts.height * 0.5
                        Layout.fillWidth: true
                        color: Material.dialogColor
                        clip: true
                        ChartView {
                            id: boxESense
                            title: "eSense"
                            anchors.fill: parent
                            legend.alignment: Qt.AlignBottom
                            legend.labelColor: Material.foreground
                            legend.font.pixelSize: 15
                            backgroundColor: Material.dialogColor
                            backgroundRoundness: 0
                            titleColor: Material.foreground
                            margins {
                                left: 6
                                top: 0
                                right: 10
                                bottom: 0
                            }
                            BarSeries {
                                id: esense
                                barWidth: 1
                                axisX: BarCategoryAxis {
                                    visible: false
                                }
                                axisY: ValueAxis {
                                    id: eSenseAxis
                                    min: 0
                                    max: 100
                                    tickCount: 3
                                    labelsColor: Material.foreground
                                    gridVisible: false
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
