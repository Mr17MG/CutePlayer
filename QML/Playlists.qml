import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material


Item {

    ListView {
        id: gridView
        height: 200
        width: parent.width
        clip: true

        orientation: Qt.Horizontal
        onContentYChanged: {
            if(contentY<0 || contentHeight < gridView.height)
                contentY = 0
            else if(contentY > (contentHeight - gridView.height))
                contentY = (contentHeight - gridView.height)
        }
        onContentXChanged: {
            if(contentX<0 || contentWidth < gridView.width)
                contentX = 0
            else if(contentX > (contentWidth-gridView.width))
                contentX = (contentWidth-gridView.width)

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
                    source: model?.lastSongCover !== "" ? model.lastSongCover
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

                text: qsTr("%1 tracks").arg(model.numberOfTracks)
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
        }

        model: ListModel {
            ListElement {
                name: "Recently added"
                lastSongCover: ""
                numberOfTracks: 2 // MAX: 100
            }
            ListElement {
                name: "Most played"
                lastSongCover: ""
                numberOfTracks: 2 // MAX: 100
            }
            ListElement {
                name: "Recently played"
                lastSongCover: ""
                numberOfTracks: 2
            }
            ListElement {
                name: "Favorites tracks"
                lastSongCover: ""
                numberOfTracks: 2
            }
        }

    }
}
