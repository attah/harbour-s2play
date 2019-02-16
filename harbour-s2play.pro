# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-s2play

CONFIG += sailfishapp_qml

DISTFILES += qml/harbour-s2play.qml \
    qml/cover/CoverPage.qml \
    qml/pages/*.qml \
    rpm/harbour-s2play.changes.in \
    rpm/harbour-s2play.changes.run.in \
    rpm/harbour-s2play.spec \
    rpm/harbour-s2play.yaml \
    translations/*.ts \
    harbour-s2play.desktop \
    qml/pages/*.js \
    qml/pages/*.css \
    qml/pages/*.png \

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-s2play-de.ts
