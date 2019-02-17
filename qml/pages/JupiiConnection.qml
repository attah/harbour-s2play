import QtQuick 2.0
import Nemo.DBus 2.0

DBusInterface {
    id: jupiiPlayer

    service: 'org.jupii'
    iface: 'org.jupii.Player'
    path: '/'

    property bool found: false

    function ping() {
        found = (getProperty('canControl') === true)
    }

    function addUrlOnceAndPlay(url, title) {
        jupiiPlayer.call('addUrlOnceAndPlay', [url, title])
    }

    signalsEnabled: true

    function canControlPropertyChanged(value) {
        console.log("canControlPropertyChanged: " + value)
        found = value
    }
}

