window.SvtPlay_MessageListenerObject = function() {
    navigator.qt.onmessage = this.onMessage.bind(this);
};

window.SvtPlay_MessageListenerObject.prototype.onMessage = function(message) {
    var obj = JSON.parse(message.data);
    var data = obj.data;

};

window.SvtPlay_MessageListener = new window.SvtPlay_MessageListenerObject();
window.onload = function() {
}

window.addEventListener("DOMNodeInserted", function() {
    var episodeId = document.getElementsByClassName("is-selected")[0].getAttribute("data-id").substr("list-element-".length);
    navigator.qt.postMessage(JSON.stringify({ "type": "video_id", "id": episodeId+"A"})); // +A because reasons
});

var viewport = document.querySelector("meta[name='viewport']");

if(window.screen.width <= 540) // Jolla devicePixelRatio: 1.5
    viewport.content = "width=device-width/1.5, initial-scale=1.5";
else if(window.screen.width > 540 && screen.width <= 768) // Nexus 4 devicePixelRatio: 2.0
    viewport.content = "width=device-width/2.0, initial-scale=2.0";
else if (window.screen.width > 768) // Nexus 5 devicePixelRatio: 3.0
    viewport.content = "width=device-width/3.0, initial-scale=3.0";

navigator.qt.postMessage(JSON.stringify({ "type": "init_done"}));
