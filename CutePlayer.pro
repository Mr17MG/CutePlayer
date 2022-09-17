QT += quick
QT += svg # for android
QT += quickcontrols2 # for QQuickStyle
QT += multimedia # for mediaPlayer

SOURCES += \
        main.cpp \
        player.cpp

RESOURCES += \
    QML/qml.qrc \
    SVG/svg.qrc

TRANSLATIONS += \
    CutePlayer_fa_IR.ts
CONFIG += lrelease
CONFIG += embed_translations

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    player.h
