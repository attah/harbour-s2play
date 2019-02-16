import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    allowedOrientations: Orientation.Portrait

    SilicaFlickable {
        width: parent.width

        PageHeader {
            id: header
            title: qsTr("Inställningar")
        }

        Column {
            id: settingsColumn
            anchors.top: header.bottom
            width: parent.width

            Row {
                width: parent.width
                Label {
                    width: parent.width
                    padding: Theme.paddingLarge
                    wrapMode: Text.WordWrap
                    text: "Standard är dynamisk bitrate 240Kb/s - 3Mb/s, " +
                          "här kan du begränsa vilken/vilka som används"
                }
            }

            Row {
                width: parent.width
                Label {
                    width: parent.width
                    padding: Theme.paddingLarge
                    wrapMode: Text.WordWrap
                    text: "Vanliga bitrates:\n" +
                          "288p: 240~750 Kb/s\n" +
                          "432p: 900~1100Kb/s\n" +
                          "720p: 1.6Mb/s+"
                }
            }

            Row {
                width: parent.width
                Label {
                    width: parent.width
                    padding: Theme.paddingLarge
                    wrapMode: Text.WordWrap
                    text: "SVTplay föreslår en initial-bitrate beroende på innehåll, " +
                          "den verkar resultera i 432p för program med högre produktionsvärde, och 288p ~700Kb/s för t.ex. nyheter"
                }
            }

            Row {
                id: defaultRow
                width: parent.width
                Switch {
                    id: defaultSwitch
                    checked: settings.getValue("use_default_rate", 0)
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: {
                        console.log("set",  checked)
                        settings.setValue("use_default_rate", checked ? 1 : 0)
                    }
                }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Använd föreslagen bitrate")
                }
            }

            Row {
                id: minRow
                visible: !defaultSwitch.checked
                width: parent.width
                Label {
                    padding: Theme.paddingLarge
                    text: qsTr("Lägsta bitrate:")
                }
                Label {
                    color: Theme.highlightColor
                    padding: Theme.paddingLarge
                    text: minSlider.value === minSlider.minimumValue ? "-" : minSlider.value
                }
            }

            Row {
                id: minSliderRow
                visible: !defaultSwitch.checked
                width: parent.width
                Slider {
                    id: minSlider

                    enabled: !defaultSwitch.checked
                    minimumValue: 240
                    maximumValue: 4000
                    value: settings.getValue("min_rate", minimumValue)
                    property bool sync: false
                    width: parent.width
                    handleVisible: true
                    stepSize: 1

                    onValueChanged: {
                        if(value === minimumValue) {
                            settings.deleteValue("min_rate")
                        }
                        else {
                            settings.setValue("min_rate", value)
                        }
                    }
                }
            }

            Row {
                id: maxRow
                visible: !defaultSwitch.checked
                width: parent.width
                Label {
                    padding: Theme.paddingLarge
                    text: qsTr("Högsta bitrate:")
                }
                Label {
                    color: Theme.highlightColor
                    padding: Theme.paddingLarge
                    text: maxSlider.value === maxSlider.maximumValue ? "-" : maxSlider.value
                }
            }

            Row {
                id: maxSliderRow
                visible: !defaultSwitch.checked
                width: parent.width
                Slider {
                    id: maxSlider

                    enabled: !defaultSwitch.checked
                    minimumValue: 240
                    maximumValue: 4000
                    value: settings.getValue("max_rate", maximumValue)
                    property bool sync: false
                    width: parent.width
                    handleVisible: true
                    stepSize: 1

                    onValueChanged: {
                        if(value === maximumValue) {
                            settings.deleteValue("max_rate")
                        }
                        else {
                            settings.setValue("max_rate", value)
                        }
                    }
                }
            }

        }
    }
}
