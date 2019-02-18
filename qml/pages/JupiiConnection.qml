import QtQuick 2.0
import Nemo.DBus 2.0

Item {

    property bool found: false

    onVisibleChanged: ping()

    function ping() {
        found = (jupiiPlayer.getProperty('canControl') === true)
    }

    function addUrlOnceAndPlay(url, title) {
        jupiiPlayer.call('addUrlOnceAndPlay', [url, title])
    }

    DBusInterface {
        id: jupiiPlayer

        service: 'org.jupii'
        iface: 'org.jupii.Player'
        path: '/'

    }

}
