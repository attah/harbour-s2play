import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

    Image {
        id: coverImage
        source: "tv-screen.svg"
        y: parent.width*0.2
        height: parent.width
        width: parent.width
        opacity: 0.2
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Label {
        id: label
        anchors.centerIn: parent
        text: qsTr("S''Play")
    }

//    CoverActionList {
//        id: coverAction

//        CoverAction {
//            iconSource: "image://theme/icon-cover-next"
//        }

//        CoverAction {
//            iconSource: "image://theme/icon-cover-pause"
//        }
//    }
}
