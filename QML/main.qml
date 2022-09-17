import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import Player

ApplicationWindow {
    id: rootWindow
    width: 640
    height: 480

    minimumHeight: 500
    minimumWidth: 350
    visible: true
    title: qsTr("Cute Player")

//    Material.theme: Material.Dark
    Material.primary: Material.Teal

    Player {
        id:player
        Component.onCompleted: {
            player.addNMediaToPlayList([ // PUT YOUR MUSIC HERE FOR TEST
                                        "/home/mohammad/Downloads/Ehsan Khaje Amiri - Naborde Ranj.mp3",
                                        "/home/mohammad/Downloads/Jooni Joonom Bia.mp3",
                                        "/home/mohammad/Downloads/Mehdi Ahmadvand - Keili Doost Daram Ye Rooz.mp3",
                                        "/home/mohammad/Downloads/Soheil Mehrzadegan - Havas.mp3"])
        }
    }

    Page {
        id: mainPage
        anchors.fill: parent

        header: Rectangle {
            height: 50
            width: parent.width

            color: Material.color(Material.Grey,Material.Shade200)

            Text {
                text: "Cute Player"
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter

                width: 100
                height: 50
                font {
                    pixelSize: 20
                    bold: true
                    italic: true
                }

                anchors {
                    left: parent.left
                    leftMargin: 15
                }
            }

            RoundButton {
                id: searchBtn

                flat: true

                icon {
                    source: "qrc:/search.svg"
                }

                anchors {
                    right: menueBtn.left
                    rightMargin: 5
                }
            }
            RoundButton {
                id: menueBtn

                flat: true

                icon {
                    source: "qrc:/menu.svg"
                }
                anchors {
                    right: parent.right
                    rightMargin: 15
                }
            }
        }

        StackView {
             id: mainStackView

             anchors.fill: parent

             initialItem: "qrc:/HomePage.qml"
        }

        Shortcut {
            sequences: [StandardKey.Cancel, "Back"]
            enabled: mainStackView.depth > 1
            context: Qt.ApplicationShortcut

            onActivated: {
                mainStackView.pop()
            }
        }
        footer: Item {
            height: 60
            width: parent.width
        }

        PlayerDrawer {
            minimumHeight:mainPage.footer.height ?? 60
            maximumHeight: mainPage.height

            width: mainPage.width

            player: player
        }
    }
}
