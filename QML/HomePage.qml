import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

Page {

    header: TabBar{
        id: tabbar
        width: parent.width
        height: 50
        Material.accent: Material.primary
        Material.foreground: Material.Grey

        background: Rectangle {
            width: parent.width

            color: Material.color(Material.Grey,Material.Shade200)
        }

        TabButton {
            text: qsTr("Playlists")
            width: 130

            font {
                capitalization: Font.MixedCase
                pixelSize: tabbar.currentIndex === 0 ? 16: 11
            }
        }

        TabButton {
            text: qsTr("Folders")
            width: 130
            font {
                capitalization: Font.MixedCase
                pixelSize: tabbar.currentIndex === 1 ? 16: 11
            }
        }

    }

    SwipeView {
        id: view

        anchors.fill: parent
        clip: true

        Playlists {

        }

        Folders {

        }
    }

    Binding {
        view.currentIndex: tabbar.currentIndex
    }

    Binding {
        tabbar.currentIndex: view.currentIndex
    }
}
