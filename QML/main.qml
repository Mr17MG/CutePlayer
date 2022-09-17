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
            player.addNMediaToPlayList(["/home/mohammad/Downloads/01. HANDEL- THE ARRIVAL OF THE QUEEN OF SHEBA (Solomon).mp3",
                                        "/home/mohammad/Downloads/01 - Beethoven - Symphony No.5 In C Minor, Op.67.mp3",
                                        "/home/mohammad/Downloads/02. VIVALDI- LE QUATTRO STAGIONI- i. Allegro (Concerto No. 1 in E 'La primavera').mp3",
                                        "/home/mohammad/Downloads/03. J.S. BACH- TOCCATA IN D MINOR BWV565.mp3",
                                        "/home/mohammad/Downloads/04. MOZART- HORN CONCERTO NO.4 IN E FLAT K495- iii. Rondo (Allegro vivace).mp3",
                                        "/home/mohammad/Downloads/05. BEETHOVEN- SYMPHONY NO.5 IN C MINOR OP.67- i. Allegro con brio.mp3",
                                        "/home/mohammad/Downloads/06. TCHAIKOVSKY- 1812 OVERTURE (conclusion).mp3",
                                        "/home/mohammad/Downloads/07. BEETHOVEN- ODE TO JOY (Symphony No.9 in D minor 'Choral', Op.125).mp3",
                                        "/home/mohammad/Downloads/08. GRIEG- PIANO CONCERTO IN A MINOR OP.16- i. Allegro molto moderato.mp3",
                                        "/home/mohammad/Downloads/09. SIBELIUS- ALLA MARCIA  (Karelia Suite, Op.11-3).mp3",
                                        "/home/mohammad/Downloads/14. PROKOFIEV- MONTAGUES AND CAPULETS (Dance of the Knights) (Romeo and Juliet).mp3",
                                        "/home/mohammad/Downloads/15. J. STRAUSS I- RADETZKY MARCH.mp3",
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
