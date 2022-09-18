import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects // Require For OpacityMask

import SQLController
import Player

Item {

    required property int playlistID
    required property string playlistName
    required property Player player

    SQLController {
        id: sqlController
    }

    Component.onCompleted: {
        switch (playlistID) {
        case SQLController.RecentlyAdded:
            musicsListModel.append(sqlController.getAllMusicsInRecentlyAdded())
            break
        case SQLController.RecentlyPlayed:
            musicsListModel.append(sqlController.getAllMusicsInRecentlyPlayed())
            break
        case SQLController.MostPlayed:
            musicsListModel.append(sqlController.getAllMusicsInMostPlayed())
            break
        case SQLController.Favourites:
            musicsListModel.append(sqlController.getAllMusicsInFavourites())
            break
        default:
            musicsListModel.append(sqlController.getAllMusicsInPlaylist(playlistID))
            break
        }

    }

    Label {
        id: nameLbl
        width: parent.width
        height: 50
        text: playlistName
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        font {
            bold: true
            italic: true
            pixelSize: 18
        }
    }

    ListView {
        id: musicsListView

        clip: true
        anchors {
            top: nameLbl.bottom
            bottom: parent.bottom
            bottomMargin: 10
            left: parent.left
            leftMargin: 10
            right: parent.right
            rightMargin: 10
        }

        delegate: RoundButton {

            width: musicsListView.width
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
                id: titleLbl

                text: model.title
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
                    right: artistNameLbl.left
                    rightMargin: 10
                }
            }

            Label {
                id: artistNameLbl
                text: model.artist
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
                    top: titleLbl.bottom
                    left:songCoverRectangle.right
                    leftMargin: 10
                    right: parent.right
                    rightMargin: 10
                }

            }

            onClicked: {
                player.stop()
                player.resetPlayList()

                var musicsPathList = []
                for ( let i=0;i<musicsListModel.count;i++) {
                    musicsPathList.push(musicsListModel.get(i).path)
                }

                player.addNMediaToPlayList(musicsPathList)
                player.setCurrentIndexInPlaylist(index)
                player.play()
            }
        }

        model: ListModel {
            id: musicsListModel
        }
    }
}
