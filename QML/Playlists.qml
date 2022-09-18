import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects // Require For OpacityMask

import SQLController
import Player

Item {
    id: root
    required property Player player

    SQLController {
        id: sqlController
    }

    Component.onCompleted: {
        defaultPlalistModel.append(
                    [
                        {
                            "id": SQLController.RecentlyAdded,
                            "name": qsTr("Recently added"),
                            "last_song_cover": "",
                            "number_of_tracks": 2
                        },
                        {
                            "id": SQLController.RecentlyPlayed,
                            "name": qsTr("Recently played"),
                            "last_song_cover": "",
                            "number_of_tracks": 2
                        },
                        {
                            "id": SQLController.MostPlayed,
                            "name": qsTr("Most played"),
                            "last_song_cover": "",
                            "number_of_tracks": 2
                        },
                        {
                            "id": SQLController.Favourites,
                            "name": qsTr("Favourites tracks"),
                            "last_song_cover": "",
                            "number_of_tracks": 2
                        }
                    ]
                    )

        playlistsListModel.append(sqlController.getAllPlaylists())
    }

    ListView {
        id: defaultListview
        height: 150
        width: parent.width
        clip: true

        orientation: Qt.Horizontal
        onContentYChanged: {
            if(contentY<0 || contentHeight < defaultListview.height)
                contentY = 0
            else if(contentY > (contentHeight - defaultListview.height))
                contentY = (contentHeight - defaultListview.height)
        }
        onContentXChanged: {
            if(contentX<0 || contentWidth < defaultListview.width)
                contentX = 0
            else if(contentX > (contentWidth-defaultListview.width))
                contentX = (contentWidth-defaultListview.width)

        }

        delegate : RoundButton {
            width: 125
            height: 150
            radius: 10
            flat: true

            Rectangle {
                id: playlistCoverRectangle

                radius: 20
                height: width
                color: Material.color(Material.Grey,Material.Shade300)

                anchors {
                    top: parent.top
                    topMargin: 10
                    left: parent.left
                    leftMargin: 15
                    right:parent.right
                    rightMargin: 15
                }

                Image {
                    anchors.fill: parent
                    source: model?.last_song_cover !== "" ? model.last_song_cover
                                                        : "qrc:/track.svg"
                                                          ?? "qrc:/track.svg"
                    sourceSize: Qt.size(width,height)
                    // TODO: Add song cover source
                }
            }

            Label {
                id: playliseNameTxt

                text: model.name
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight

                font {
                    bold: true
                    pixelSize: 13
                }

                anchors {
                    top: playlistCoverRectangle.bottom
                    topMargin: 2
                }

            }

            Label {
                id: nTracksTxt

                text: qsTr("%1 tracks").arg(model.number_of_tracks)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight

                anchors {
                    top: playliseNameTxt.bottom
                }

                font {
                    pixelSize: 12
                }
            }

            onClicked: {
                mainStackView.push("qrc:/Musics.qml",{playlistID: model.id, playlistName:model.name, player:root.player})
            }
        }

        model: ListModel {
            id: defaultPlalistModel
        }

    }


    ListView {
        id: playlistListView

        clip: true
        anchors {
            top: defaultListview.bottom
            bottom: parent.bottom
            margins: 10
            left: parent.left
            right: parent.right
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
            id: playlistsListModel
        }
    }

    RoundButton {

        text: qsTr("Add Playlist")
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

        }
    }
}
