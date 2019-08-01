import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    allowedOrientations: Orientation.Portrait

    SilicaFlickable {
        anchors.fill: parent
        width: parent.width
        contentHeight: settingsColumn.height

        Column {
            id: settingsColumn
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                id: header
                title: qsTr("Inställningar")
            }

            Row {
                x: Theme.paddingLarge
                width: parent.width - 2*Theme.paddingLarge
                Label {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    text: "Standard är dynamisk bitrate 240Kb/s - 3Mb/s, " +
                          "här kan du begränsa bitraten för att minska dataförbrukningen.\n" +
                          "(gäller både i appen och vid uppspelning över DLNA)"
                }
            }


            Row {
                id: defaultRow
                width: parent.width - 2*Theme.paddingLarge
                Switch {
                    id: defaultSwitch
                    checked: settings.getValue("use_low_rate", 0)
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: {
                        console.log("set",  checked)
                        settings.setValue("use_low_rate", checked ? 1 : 0)
                    }
                }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Begraänsa till max 750Kb/s")
                }
            }
        }
    }
}
