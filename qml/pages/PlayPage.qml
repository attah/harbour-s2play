import QtQuick 2.0
import QtMultimedia 5.6
import Sailfish.Silica 1.0
import Nemo.KeepAlive 1.2
import "SrtParser.js" as SrtParser

Page {
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.LandscapeMask

    showNavigationIndicator: false
    navigationStyle: PageNavigation.Vertical
    property string video_id
    property string source
    property string title
    property string subtitleurl

    onStatusChanged: {
        if(status == PageStatus.Deactivating)
        {
            player.maybeSaveProgress()
        }
    }

    onSubtitleurlChanged: {
        if(subtitleurl)
            getSubs(subtitleurl)
    }

    onSourceChanged: player.source = source

    Component.onCompleted: {
        console.log("playing", source)
    }

    DisplayBlanking {
        id: displayBlanking
        preventBlanking: player.playbackState === MediaPlayer.PlayingState
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
                subContainer.reset()
                seek(position - 10000 > 0 ? position - 10000 : 0)
            }
            Component.onCompleted:
            {
                player.seek(settings.getProgress(video_id))
                player.play()
            }

            readonly property string humanDuration: duration >= 60*60*1000 ? Qt.formatTime(new Date(0, 0, 0, 0, 0, 0, duration), "hh:mm:ss")
                                                                    : Qt.formatTime(new Date(0, 0, 0, 0, 0, 0, duration), "mm:ss")


            readonly property string humanPosition: duration >= 60*60*1000 ? Qt.formatTime(new Date(0, 0, 0, 0, 0, 0, position), "hh:mm:ss")
                                                                    : Qt.formatTime(new Date(0, 0, 0, 0, 0, 0, position), "mm:ss")

            onPlaybackStateChanged: {
                if (playbackState !== MediaPlayer.PlayingState)
                {
                    maybeSaveProgress()
                }
            }


            function maybeSaveProgress() {
                console.log("playbackstate", playbackState);
                console.log("sp", position, duration);
                //           Invalid           Live             For good measure
                if(duration !== -1 && duration !== 0 && position !== 0) {
                    if (position > 5000) {
                        settings.setProgress(video_id, position)
                    }
                    if (position > (duration-5000) || position <= 5000) {
                        console.log("rp",position);
                        settings.removeProgress(video_id)
                    }
                }
            }
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

        Rectangle {
            id: subContainer
            visible: false

            color: "black"
            opacity: 0.7
            height: subLabel.implicitHeight
            width: subLabel.text == "" ? 0 : subLabel.implicitWidth + Theme.paddingMedium //Don't pad empty string
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: controlsRect.visible ? controlsRect.top : parent.bottom
            anchors.bottomMargin: Theme.paddingLarge

            property var subs
            property int subIdx: 0
            property int position: player.position

            onSubsChanged: {
                console.log(JSON.stringify(subs));
            }

            onPositionChanged: {
                if(!visible)
                    return

                var my_pos = position
                while(subIdx <= subs.length) /* in case of logic accidents*/ {
                    if (my_pos < subs[subIdx].end*1000  && my_pos >= subs[subIdx].start*1000) {
                        subLabel.text = subs[subIdx].text
                    }
                    else if (my_pos >= subs[subIdx].end*1000) {
                        subLabel.text = ""
                        subIdx++
                        my_pos = position
                        continue //looking
                    }
                    break
                }
            }

            function reset() {
                subIdx = 0;
            }

            function toggleVisible() {
                visible = !visible
            }

            Label {
                id: subLabel
                anchors.centerIn: parent
                text: ""
            }
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
            id: controlsRect
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

                    minimumValue: 0
                    maximumValue: player.duration
                    width: parent.width
                    handleVisible: true

                    value: player.position

                    onSliderValueChanged: {
                        if(down) {
                            player.seek(sliderValue)
                            subContainer.reset()
                        }
                    }
                }

                Row {
                    width: parent.width
                    height: play.height + 2*Theme.paddingLarge

                    IconButton {
                        width: parent.width / 5

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

                    IconButton {
                        id: subButton
                        width: parent.width / 5
                        anchors.verticalCenter: parent.verticalCenter
                        icon.source: "image://theme/icon-m-font-size"
                        onClicked: subContainer.toggleVisible()
                        highlighted: subContainer.visible
                    }
                }
            }
            Label {
                anchors.top: parent.top
                anchors.topMargin: progressSlider.implicitHeight*0.8
                anchors.horizontalCenter: parent.left
                anchors.horizontalCenterOffset: parent.width/10
                text: player.humanPosition
            }
            Label {
                anchors.top: parent.top
                anchors.topMargin: progressSlider.implicitHeight*0.8
                anchors.horizontalCenter: parent.right
                anchors.horizontalCenterOffset: -parent.width/10
                text: player.humanDuration
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

    function getSubs(url) {
        console.log(url)

        var xhr = new XMLHttpRequest;
        xhr.open("GET", url);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE)
                subContainer.subs = SrtParser.parse(xhr.responseText);
        }
        xhr.send();
    }
}
