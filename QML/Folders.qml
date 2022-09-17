import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import Qt5Compat.GraphicalEffects // Require For OpacityMask
import QtCore

Item {
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

                font {
                    pixelSize: 14
                    bold: true
                }

                anchors {
                    top: parent.top
                    left:songCoverRectangle.right
                    leftMargin: 10
                    right: parent.right
                    rightMargin: 10
                }
            }

            Label {
                text: qsTr("%1 tracks").arg(model.numberOfTracks)
                height: parent.height/2
                verticalAlignment: Text.AlignTop

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
        }

        model: ListModel {
            id: flodersListModel
            ListElement {
                name: "Downloads"
                numberOfTracks: 5
            }
        }
    }

    FolderDialog {
        id: flieDialog

        currentFolder: StandardPaths.standardLocations(StandardPaths.MusicLocation)[0]
        onAccepted: {
            let currentFolderName = String(currentFolder).split("/").pop().toString()
            flodersListModel.append({name:currentFolderName})
            console.log(currentFolder)
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

        anchors {
            bottom: parent.bottom
            bottomMargin: 10

            right: parent.right
            rightMargin: 10
        }

        onHoveredChanged: {
            if(hovered)
                display = RoundButton.TextBesideIcon
            else
                display = RoundButton.IconOnly
        }
        Behavior on display {
            NumberAnimation{
                duration: 200
            }
        }
        onClicked: {
            flieDialog.open()
        }
    }
}
