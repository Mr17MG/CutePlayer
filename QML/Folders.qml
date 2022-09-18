import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs

import QtCore // Require For StandardPaths
import Qt5Compat.GraphicalEffects // Require For OpacityMask

import SQLController
import Player

Item {
    id: root

    required property Player player

    SQLController {
        id: sqlController
    }

    Connections {
        target: sqlController

        function onNewFolderAdded(newFolderID)
        {
            console.log(newFolderID)
            foldersListModel.append(sqlController.getFolderInfoByID(newFolderID))
        }
    }

    Component.onCompleted: {
        foldersListModel.append(sqlController.getAllFolders())
    }

    ListView {
        id: foldersListView

        clip: true
        anchors {
            fill: parent
            margins: 10
        }

        delegate: RoundButton {

            width: parent.width
            height: 75
            radius: 10
            flat: true

            Rectangle {
                id: songCoverRectangle

                color: Material.color(Material.Grey,Material.Shade300)
                width: 50
                height: width
                radius: 10

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 10
                }

                Image {
                    id: songCoverImage
                    anchors.fill: parent
                    source: "qrc:/track.svg"

                    sourceSize: Qt.size(width,height)

                    cache: false
                    asynchronous: true

                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            x: songCoverRectangle.x
                            y: songCoverRectangle.y
                            width: songCoverRectangle.width
                            height: songCoverRectangle.height
                            radius: songCoverRectangle.radius
                        }
                    }
                }
            }

            Label {
                id: directoryName

                text: model.name
                height: parent.height/2
                verticalAlignment: Text.AlignBottom
                elide: Qt.ElideRight

                font {
                    pixelSize: 14
                    bold: true
                }

                anchors {
                    top: parent.top
                    left:songCoverRectangle.right
                    leftMargin: 10
                    right: tracksLbl.left
                    rightMargin: 10
                }
            }

            Label {
                id: tracksLbl
                text: qsTr("%1 tracks").arg(model.number_of_tracks)
                height: parent.height/2
                verticalAlignment: Text.AlignBottom

                font {
                    pixelSize: 12
                }

                anchors {
                    top: parent.top
                    right: parent.right
                    rightMargin: 10
                }
            }

            Label {
                text: model.path
                height: parent.height/2
                verticalAlignment: Text.AlignTop
                elide: Qt.ElideLeft

                font {
                    pixelSize: 12
                }

                anchors {
                    top: directoryName.bottom
                    left:songCoverRectangle.right
                    leftMargin: 10
                    right: parent.right
                    rightMargin: 10
                }
            }

            onClicked: {
                mainStackView.push("qrc:/Musics.qml",{playlistID: model.id, playlistName:model.name, player:root.player})
            }
        }

        model: ListModel {
            id: foldersListModel
        }
    }

    FolderDialog {
        id: flieDialog

        currentFolder: StandardPaths.standardLocations(StandardPaths.MusicLocation)[0]
        onAccepted: {
            let currentFolderPath = String(currentFolder).replace("file://",'')
            sqlController.addNewFolder(currentFolderPath)
        }

    }

    RoundButton {

        text: qsTr("Add Folder")
        Material.background: Material.primary
        Material.foreground: "White"
        display: RoundButton.IconOnly

        icon {
            source: "qrc:/Player/plus.svg"
        }

        font.capitalization: Font.MixedCase

        anchors {
            bottom: parent.bottom
            bottomMargin: 10

            right: parent.right
            rightMargin: 10
        }

        hoverEnabled: true
        onHoveredChanged: {
            if(hovered)
            {
                display = RoundButton.TextBesideIcon
                width = 140
            }
            else {
                display = RoundButton.IconOnly
                width = 50
            }
        }

        Behavior on width {
            NumberAnimation{
                duration: 200
            }
        }

        onClicked: {
            flieDialog.open()
        }
    }

}
