window.SvtPlay_MessageListenerObject = function() {
    navigator.qt.onmessage = this.onMessage.bind(this);
};

window.SvtPlay_MessageListenerObject.prototype.onMessage = function(message) {
    var obj = JSON.parse(message.data);
    var data = obj.data;

    if(obj.type === "get")
    {
//        navigator.qt.postMessage(JSON.stringify({ "type": "button", "data":document.getElementsByClassName("play_video-area")[0].innerHTML}));

          this.getStream(data.video_id);
    }
};

window.SvtPlay_MessageListenerObject.prototype.getStream = function(id) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = (function(myxhr) {
        return function() {
            if(myxhr.readyState === 4)
                navigator.qt.postMessage(JSON.stringify({ "type": "playable_media", "id": id, "streams": JSON.parse(myxhr.response)}));
        }
    })(xhr);
    xhr.open('GET', "http://api.svt.se/videoplayer-api/video/"+id, true);
    xhr.send('');
}

window.SvtPlay_MessageListener = new window.SvtPlay_MessageListenerObject();
window.onload = function() {
}

window.addEventListener("DOMNodeInserted", function() {
    var videos = document.getElementsByTagName("video");
    for(k in videos) {
        if (videos[k].getAttribute("data-video-id") != null) {
            navigator.qt.postMessage(JSON.stringify({ "type": "video_id", "id": videos[k].getAttribute("data-video-id")}));
        }
    };
    var play_button = document.getElementsByClassName("play_light-button")[0].onclick = function() {navigator.qt.postMessage(JSON.stringify({ "type": "boooom"}));};
    svp_video.play = function() {
        var data = { type: "tagoverrider_play", data: { url: (this.src || this.getAttribute("src")) } };
        navigator.qt.postMessage(JSON.stringify(data));
    }
});

var viewport = document.querySelector("meta[name='viewport']");

if(window.screen.width <= 540) // Jolla devicePixelRatio: 1.5
    viewport.content = "width=device-width/1.5, initial-scale=1.5";
else if(window.screen.width > 540 && screen.width <= 768) // Nexus 4 devicePixelRatio: 2.0
    viewport.content = "width=device-width/2.0, initial-scale=2.0";
else if (window.screen.width > 768) // Nexus 5 devicePixelRatio: 3.0
    viewport.content = "width=device-width/3.0, initial-scale=3.0";

document.createElement("video").constructor.prototype.load = function() {navigator.qt.postMessage(JSON.stringify({ "type": "vonload"}));};
document.createElement("video").constructor.prototype.canPlayType = function(media) {navigator.qt.postMessage(JSON.stringify({ "type": "cpt", "media":media})); return "probably"};
document.createElement("video").constructor.prototype.play = function() {
    var data = { type: "tagoverrider_play", data: { url: (this.src || this.getAttribute("src")) } };
    navigator.qt.postMessage(JSON.stringify(data));
}

//document.createElement("video").constructor.prototype.onclick = function() {navigator.qt.postMessage(JSON.stringify({ "type": "button"}));};

navigator.qt.postMessage(JSON.stringify({ "type": "init_done"}));
