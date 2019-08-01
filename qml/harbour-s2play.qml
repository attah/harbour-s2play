import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import Nemo.Notifications 1.0
import "pages"

ApplicationWindow
{
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    Item {
        id: settings
        property var db_conn

        Component.onCompleted: {
            db_conn = LocalStorage.openDatabaseSync("S2PlayDB", "1.0", "S2Play storage", 100000)
            db_conn.transaction(function (tx) {
//                tx.executeSql('DROP TABLE IF EXISTS RateSettings');
                tx.executeSql('CREATE TABLE IF NOT EXISTS RateSettings (id STRING UNIQUE, value INTEGER)');
            });
        }

        function setValue(id, value) {
            db_conn.transaction(function (tx) {
                tx.executeSql('REPLACE INTO RateSettings VALUES(?, ?)', [id, value] );
            });
        }

        function getValue(id, defaultValue) {
            if (defaultValue === undefined) {
                defaultValue = 0
            }
            var rateVal = defaultValue;
            db_conn.transaction(function (tx) {
                var res = tx.executeSql('SELECT value FROM RateSettings WHERE id=?', [id] );
                if (res.rows.length !== 0) {
                    console.log(res.rows.item(0).value)
                    rateVal = res.rows.item(0).value;
                }
            });
            return rateVal
        }
        function deleteValue(id) {
            db_conn.transaction(function (tx) {
                tx.executeSql('DELETE FROM RateSettings WHERE id=?', [id] );
            });
        }
    }

    Notification {
        id: notifier

        expireTimeout: 4000

        function notify(message) {
            body = message
            previewBody = message
            publish()
        }
    }
}
