import QtQuick 2.0
import QtMultimedia 5.6
import Sailfish.Silica 1.0
import Nemo.DBus 2.0

Page {
    id: page
    showNavigationIndicator: false
    navigationStyle: PageNavigation.Vertical
    property string source
    property string title

    onSourceChanged: player.source = source

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.Landscape

    Component.onCompleted: {
        console.log("playing", source)
    }

    Component.onDestruction: {
        console.log("un-keepalive")
        keepalive.call('req_display_cancel_blanking_pause')
    }

    Timer {
        interval: 50000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            console.log("keepalive")
            keepalive.call('req_display_blanking_pause')
        }
    }

    Rectangle {
        id: rect
        anchors.fill: parent
        color: "black"

        MediaPlayer {
            id: player
            property bool controlsVisible: playbackState !== MediaPlayer.PlayingState || controlsVisibleTimer.running
            function goForward() {
                seek(position + 10000 < duration ? position + 10000 : duration)
            }

            function goBackward() {
                seek(position - 10000 > 0 ? position - 10000 : 0)
            }
            autoPlay: true

        }

        VideoOutput {
            id: videoOutput
            source: player
            anchors.fill: parent

        }
        Timer {
            id: controlsVisibleTimer
            interval: 5000
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log("clack");
                console.log("rate", player.metaData.videoBitRate)

                controlsVisibleTimer.running ? controlsVisibleTimer.stop() : controlsVisibleTimer.start();
            }
        }

        Rectangle {
            visible: player.controlsVisible
            width: parent.width
            height: controls.implicitHeight + Theme.paddingLarge
            anchors.bottom: parent.bottom
//            default property alias data: controls.data
            color: "black"
            opacity: 0.7

            Column {
                id: controls
                anchors.bottom: parent.bottom
                width: parent.width
                spacing: Theme.paddingLarge
                anchors.bottomMargin: Theme.paddingLarge


                Slider {
                    id: progressSlider
                    maximumValue: player.duration
                    property bool sync: false
                    width: parent.width
                    handleVisible: true


                    onValueChanged: {
                        if (!sync)
                            player.seek(value)
                    }

                    Connections {
                        target: player
                        onPositionChanged: {
                            progressSlider.sync = true
                            progressSlider.value = player.position
                            progressSlider.sync = false
                        }
                    }
                }
                Row {
                    width: parent.width
                    height: play.height + 2*Theme.paddingLarge

                    IconButton {
                        id: dummy
//                        icon.source:
                        width: parent.width / 5
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    IconButton {
                        id: previous
                        icon.source: "image://theme/icon-m-previous"
                        onClicked: player.goBackward()
                        width: parent.width / 5
                        anchors.verticalCenter: parent.verticalCenter
                    }


                    IconButton {
                        id: play
                        icon.source: player.playbackState === MediaPlayer.PlayingState ? "image://theme/icon-l-pause" : "image://theme/icon-l-play"
                        onClicked: player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
                        width: parent.width / 5
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    IconButton {
                        id: next
                        icon.source: "image://theme/icon-m-next"
                        onClicked: player.goForward()
                        width: parent.width / 5
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
    IconButton {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: Theme.paddingMedium
        anchors.rightMargin: Theme.paddingMedium

       icon.source: "image://theme/icon-m-reset"
       visible: player.controlsVisible
       onClicked: pageStack.pop()
    }

}
