import QtQuick 2.0
import Nemo.DBus 2.0

Item {

    property bool found: false

    function ping() {
        jupiiPing.call('Ping', [], function() {found = true}, function() {found = false});
    }

    onVisibleChanged: {
        if (visible)
            ping()
    }

    DBusInterface {
        id: jupiiPing
        service: 'org.jupii'
        iface: 'org.freedesktop.DBus.Peer'
        path: '/'

    }

    function addUrlOnceAndPlay(url, title) {
        jupiiPlayer.call('addUrlOnceAndPlay', [url, title])
    }


    DBusInterface {
        id: jupiiPlayer

        service: 'org.jupii'
        iface: 'org.jupii.Player'
        path: '/'

        signalsEnabled: true

    }
}
