import QtQuick 2.0
import QtMultimedia 5.6
import Sailfish.Silica 1.0

Page {
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.Portrait

    SilicaWebView {
        id: webView
        property string video_id: ""

        onVideo_idChanged: {
            if (video_id !== "") {
                console.log("idc", video_id)
                var xhr = new XMLHttpRequest;
                xhr.onreadystatechange = (function(myxhr) {
                    return function() {
                        if(myxhr.readyState === 4)
                        {
                            console.log("woop", myxhr.responseText)
                            streamData = JSON.parse(myxhr.responseText)
                        }
                    }
                })(xhr);
                xhr.open('GET', "http://api.svt.se/videoplayer-api/video/"+video_id, true);
                xhr.send('');
                jupii.ping()
            }
        }

        quickScroll: false

        PullDownMenu {
            MenuItem {
                text: qsTr("Inställningar")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
        }

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: controlRow.top
        }

//        experimental.preferences.webGLEnabled: true
//        experimental.preferences.notificationsEnabled: true
//        experimental.preferences.dnsPrefetchEnabled: true
        experimental.preferences.javascriptEnabled: true
//        experimental.preferences.localStorageEnabled: true
        experimental.preferences.navigatorQtObjectEnabled: true

        // stolen with pride from hutspot, copied from webcat
        property variant devicePixelRatio: {//1.5
            if (Screen.width <= 540) return 1.5;
            else if (Screen.width > 540 && Screen.width <= 768) return 2.0;
            else if (Screen.width > 768) return 3.0;
        }
        experimental.customLayoutWidth: width / devicePixelRatio
        experimental.deviceWidth: width / devicePixelRatio
        experimental.userAgent: "Mozilla/5.0 (Linux; Android 4.4; Nexus 4 Build/KRT16H) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/30.0.0.0 Mobile Safari/537.36"
        experimental.userStyleSheet: Qt.resolvedUrl("user.css")


        experimental.userScripts: [
            Qt.resolvedUrl("SvtPlayHandler.js"),
        ]

        experimental.onMessageReceived: {
//            console.log(JSON.stringify(message));
            console.log("message:", message.data);
            var data = JSON.parse(message.data);
            if (data.type === "video_id") {
                video_id = data.id;
            }
        }
        onLoadingChanged: {
            console.log(loading, loadProgress, _page, _webPage);
        }
        onUrlChanged: {
            console.log(url,video_id);
            video_id = "";
            console.log(video_id);
            streamData = false;
        }
        Component.onCompleted: {
            url = "http://svtplay.se"
        }

        Timer {
            id: gettimer
            interval: 1000
            running: page.visible
            repeat: true

            onTriggered: webView.experimental.postMessage({"get":"it"})
        }
    }

    property var streamData: false

    function doHls(success) {
        var format = settings.getValue("use_low_rate") === 1 ? "hls-lb" : "hls"

        for(var i in streamData.videoReferences) {
            console.log(streamData.videoReferences[i].format,streamData.videoReferences[i].url )
            if(streamData.videoReferences[i].format === format) {
                console.log("found",streamData.videoReferences[i].url);
                var url = applyRateLimits(streamData.videoReferences[i].url);
                if(url) {
                    var title = streamData.programTitle;
                    if (streamData.episodeTitle) {
                        title = title+" - "+streamData.episodeTitle
                    }
                    break;
                }
                else {
                    notifier.notify("Inställningar hindrar uppspelning");
                    return;
                }
            }
        }
        for(var j in streamData.subtitleReferences) {
            console.log(streamData.subtitleReferences[j].format,streamData.subtitleReferences[j].url )
            if(streamData.subtitleReferences[j].format === "websrt") {
                console.log("found srt",streamData.subtitleReferences[j].url);
                var subs = streamData.subtitleReferences[j].url;
                    break;
            }
            else if(streamData.subtitleReferences[j].format === "webvtt") {
                console.log("found vtt",streamData.subtitleReferences[j].url);
                var subs = streamData.subtitleReferences[j].url;
                    break;
            }
        }
        if(url)
            success(url, title, subs)
    }

    function applyRateLimits(url) {
        var tokens = url.split(",")
        var rates = tokens.slice(1,tokens.length-1)
        var min_rate = settings.getValue("min_rate")
        var max_rate = settings.getValue("max_rate")
        console.log("applying", settings.getValue("use_default_rate"), min_rate, max_rate)
        if (settings.getValue("use_default_rate") !== 0) {
            rates = [rates[0]]
        }
        else if (min_rate !== 0 || max_rate !== 0) {
            if(min_rate !== 0)
                rates = rates.filter(function over_min(rate) {return rate >= min_rate})
            if(max_rate !== 0)
                rates = rates.filter(function under_max(rate) {return rate <= max_rate})
            console.log("filt", rates)
            if(rates.length === 0) {
                return false
            }
        }
        else {
            // No settings applied, don't bork the uri if format changes
            console.log("nosettings")
            return url
        }
        var resultingUrl = tokens[0]+","+rates+","+tokens[tokens.length-1]
        console.log("resulting", resultingUrl)
        return resultingUrl
    }

    JupiiConnection {
        id: jupii
    }

    Row {
        id: controlRow
        anchors.bottom: parent.bottom
        width: parent.width
        height: 200
        IconButton {
            id: previous
            enabled: webView.canGoBack
            icon.source: "image://theme/icon-m-back"
            onClicked: {
                // Often when going back, onUrlChanged doesn't seem to trigger
                streamData = false
                webView.goBack()
            }
            width: parent.width / 3
            anchors.verticalCenter: parent.verticalCenter
        }


        IconButton {
            id: play
            icon.source: "image://theme/icon-l-play"
            enabled: streamData
            onClicked: {
                doHls(function(url, title, subs) {pageStack.push(Qt.resolvedUrl("PlayPage.qml"), {video_id: webView.video_id, source: url, title: title, subtitleurl: subs});})
            }
            width: parent.width / 3
            anchors.verticalCenter: parent.verticalCenter
        }

        IconButton {
            id: cast
            enabled: jupii.found && streamData
            icon.source: "icon-m-device.png"
            onClicked: {
                doHls(function(url, title, _subs) {jupii.addUrlOnceAndPlay(url, title)})
            }
            width: parent.width / 3
            anchors.verticalCenter: parent.verticalCenter
        }

    }

}
