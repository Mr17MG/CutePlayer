import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Player
import QtMultimedia

import Qt5Compat.GraphicalEffects // Require For OpacityMask

Drawer {
    id: root

    required property real minimumHeight
    required property real maximumHeight
    required property Player player

    function msToHMS( ms ) {
        // 1- Convert to seconds:
        let seconds = ms / 1000;

        // 2- Extract hours:
        let hours = parseInt( seconds / 3600 ); // 3,600 seconds in 1 hour
        seconds = seconds % 3600; // seconds remaining after extracting hours

        // 3- Extract minutes:
        let minutes = parseInt( seconds / 60 ); // 60 seconds in 1 minute

        // 4- Keep only seconds not extracted to minutes:
        seconds = seconds % 60;

        seconds = ("0" + seconds.toFixed(0)).slice(-2)
        minutes = ("0" + minutes).slice(-2)
        hours = ("0" + hours).slice(-2)

        return ( hours+":"+minutes+":"+seconds);
    }

    modal: false
    visible: true
    edge: Qt.BottomEdge
    interactive: false
    closePolicy: Popup.NoAutoClose
    dragMargin: 0
    clip: true

    Shortcut {
        sequences: [StandardKey.Cancel, "Back"]
        enabled: drawerState.state !== "collapse"
        context: Qt.ApplicationShortcut

        onActivated: {
            drawerState.state = "collapse"
        }
    }

    background: Rectangle {
        id: backgroundRectangle
        property color backgroundColor: Material.color(Material.Teal,Material.ShadeA100)
        radius: 30

        gradient: Gradient {
            GradientStop {
                position: drawerState.state === "collapse" ?0:0.3;
                color: drawerState.state === "collapse" ? Material.color(Material.Teal,Material.Shade100)
                                                        : Material.dialogColor
            }
            GradientStop {
                position: 1.0;
                color: backgroundRectangle.backgroundColor
            }
        }
    }

    Component.onCompleted:  {
        drawerState.state = "collapse"
    }

    MouseArea {
        anchors.fill: parent
        enabled: drawerState.state === "collapse"

        onClicked: {
            drawerState.state = 'expand'
        }
    }

    RoundButton {
        id: collapseBtn

        flat: true

        icon {
            source: "qrc:/Player/arrow-down.svg"
        }

        onClicked: {
            drawerState.state = "collapse"

        }
    }

    RoundButton {
        id: volumeBtn

        flat: true

        anchors {
            right: parent.right
        }

        icon {
            source: "qrc:/Player/volume-level-2.svg"
        }

        onClicked: {
            volumePopup.open()
        }

        onPressAndHold: {
            console.log(player.muted())
            player.setMuted(!player.muted())
        }
    }

    Popup {
        id: volumePopup
        x: volumeBtn.x - volumePopup.width + volumeBtn.width
        y: volumeBtn.y + volumeBtn.height
        width: 250
        //        height: 75
        onWidthChanged: console.log(width,height )
        RowLayout {
            anchors.fill: parent
            Slider {
                id: volumeSlider

                stepSize: 0.01
                from: 0
                to: 1
                value: player.volume()
                Layout.alignment: Qt.AlignCenter
                Material.accent: Material.Teal
                height: parent.height
                onValueChanged: {
                    player.setVolume(value)
                }
            }
            Text {
                text: volumeSlider.value === 1? 100
                                              : ("00"+(volumeSlider.value * 100).toFixed(0)).slice(-2)
            }
        }
    }

    Rectangle {
        id: songCoverRectangle

        color: Material.color(Material.Grey,Material.Shade300)

        anchors {
            top: parent.top
            left: parent.left
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
        id: trackTitleLbl

        text: qsTr("Track title")
        height: 20
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        elide: Qt.ElideRight

        font {
            bold: true
        }

        anchors {
            top: songCoverRectangle.top
            right: parent.right
            rightMargin: 5
            left: parent.left
            leftMargin: 10
        }
    }

    Label {
        id: artistNameLbl

        text: qsTr("Artist")
        height: 20
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        elide: Qt.ElideRight

        anchors {
            top: trackTitleLbl.bottom
            right: trackTitleLbl.right
            left: trackTitleLbl.left
        }
    }

    GridLayout {
        id: playlistsLayout

        opacity: 0
        columns: 3
        height: 60

        anchors{
            right: parent.right
            rightMargin: 15
            left: parent.left
            leftMargin: 15
            bottom: sliderItem.top
            bottomMargin: -10
        }


        RoundButton {
            id: playlistBtn

            Layout.alignment: Qt.AlignLeft
            flat: true
            width: 50
            height: 50
            icon {
                source:"qrc:/Player/playlist.svg"
            }

            onClicked: {
                // TODO: Open play list ListView
            }
        }

        RoundButton {
            id: favoriteBtn

            Layout.alignment: Qt.AlignHCenter
            flat: true
            width: 50
            height: 50

            icon {
                source:"qrc:/Player/heart.svg"
            }

            onClicked: {
                // TODO: Add song to favorite songs
            }
        }

        RoundButton {
            id: addToPlayListBtn

            Layout.alignment: Qt.AlignRight
            flat: true
            width: 50
            height: 50

            icon {
                source:"qrc:/Player/plus.svg"
            }

            onClicked: {
                // TODO: Add song to playlist
            }
        }
    }

    Item{

        id: sliderItem

        height: 50
        opacity: 0

        anchors {
            right: parent.right
            rightMargin: 15
            left: parent.left
            leftMargin: 15
            bottom: controlsFlow.top
            bottomMargin: -10
        }

        Slider {
            id: slider

            from: 0
            to: 0
            value: 0
            stepSize: 10000
            width: parent.width
            height: 30
            enabled: player.isSeekable()
            Material.accent: Material.Teal

            anchors {
                top: parent.top
            }

            onMoved: {
                player.setPosition(value)
            }
        }

        Text {
            text: msToHMS(slider.value)

            anchors {
                bottom: parent.bottom
                left: parent.left
            }
        }

        Text {
            text: msToHMS(slider.to)

            anchors {
                bottom: parent.bottom
                right:parent.right
            }
        }
    }

    GridLayout {
        id: controlsFlow

        columns: 3
        height: 60

        anchors {
            right: parent.right
            left: parent.left
            leftMargin: parent.width/2
            bottom: parent.bottom
        }

        RoundButton {
            id: shuffleBtn

            Layout.alignment: Qt.AlignHCenter
            flat: true
            visible: drawerState.state === "expand"
            width: 50
            height: 50

            icon {
                source:if (player.shuffle() === Player.ShuffleOn) {
                           return "qrc:/Player/shuffle.svg"
                       }
                       else {
                           return "qrc:/Player/shuffle-off.svg"
                       }
            }

            onClicked: {
                if (player.shuffle() === Player.ShuffleOn) {
                    player.setShuffle(Player.ShuffleOff)
                }
                else {
                    player.setShuffle(Player.ShuffleOn)
                }
            }
        }

        RoundButton {
            id: previousBtn

            Layout.alignment: Qt.AlignHCenter
            flat: true
            width: 50
            height: 50

            icon {
                source:"qrc:/Player/previous.svg"
            }

            onClicked: {
                player.previous()
            }
        }


        RoundButton {
            id: playPauseBtn

            Layout.alignment: Qt.AlignHCenter
            flat: true
            width: 50
            height: 50
            icon {
                source:"qrc:/Player/play.svg"
            }

            onClicked: {
                if (player.playbackState() === MediaPlayer.PausedState ||
                        player.playbackState() === MediaPlayer.StoppedState )
                {

                    player.play()
                }
                else {
                    player.pause()
                }

            }
        }

        RoundButton {
            id: nextBtn

            Layout.alignment: Qt.AlignHCenter
            flat: true
            width: 50
            height: 50

            icon {
                source:"qrc:/Player/next.svg"
            }

            onClicked: {
                player.next()
            }
        }

        RoundButton {
            id: repeatBtn


            Layout.alignment: Qt.AlignHCenter
            flat: true
            visible: drawerState.state === "expand"
            width: 50
            height: 50

            icon {
                source:if (player.loop() === Player.LoopOnce) {
                           return "qrc:/Player/repeat-one.svg"
                       }
                       else if (player.loop() === Player.LoopAll) {
                           return "qrc:/Player/repeat-all.svg"
                       }
                       else {
                           return "qrc:/Player/repeat-off.svg"
                       }
            }

            onClicked: {
                if (player.loop() === Player.LoopOnce) {
                    player.setLoop(Player.LoopAll)
                }
                else if (player.loop() === Player.LoopAll) {
                    player.setLoop(Player.LoopOff)
                }
                else {
                    player.setLoop(Player.LoopOne)
                }
            }
        }
    }

    StateGroup {
        id: drawerState

        states: [
            State {
                name: "collapse"

                PropertyChanges {
                    target: root
                    height: minimumHeight
                }

                PropertyChanges {
                    target: collapseBtn
                    opacity: 0
                }

                PropertyChanges {
                    target: volumeBtn
                    opacity: 0
                }

                PropertyChanges {
                    target: root.background
                    radius: 30
                }

                PropertyChanges {
                    target: songCoverRectangle
                    width: 45
                    height: width
                    radius: 10
                    anchors.topMargin: (parent.height - songCoverRectangle.height)/2
                    anchors.leftMargin: 15
                }

                PropertyChanges {
                    target: trackTitleLbl

                    horizontalAlignment: Text.AlignLeft

                    font {
                        pixelSize: 11
                    }

                    anchors {
                        rightMargin: controlsFlow.anchors.rightMargin + controlsFlow.width + 5
                        leftMargin: songCoverRectangle.anchors.leftMargin + songCoverRectangle.width + 15
                    }
                }

                PropertyChanges {
                    target: artistNameLbl

                    horizontalAlignment: Text.AlignLeft

                    font {
                        pixelSize: 11
                    }
                }

                PropertyChanges {
                    target: controlsFlow

                    columns:3

                    anchors.leftMargin: parent.width/2
                    anchors.rightMargin: 10
                }

                PropertyChanges {
                    target: sliderItem

                    opacity: 0
                }

                PropertyChanges {
                    target: playlistsLayout

                    opacity: 0
                }


            },
            State {
                name: "expand"

                PropertyChanges {
                    target: root
                    height: maximumHeight
                }

                PropertyChanges {
                    target: collapseBtn
                    opacity: 1
                }

                PropertyChanges {
                    target: volumeBtn
                    opacity: 1
                }

                PropertyChanges {
                    target: root.background
                    radius: 0
                }

                PropertyChanges {
                    target: songCoverRectangle
                    width: 200
                    height: width
                    radius: 20
                    anchors.topMargin: 50
                    anchors.leftMargin: (parent.width - songCoverRectangle.width)/2
                }

                PropertyChanges {
                    target: trackTitleLbl

                    horizontalAlignment: Text.AlignHCenter

                    font {
                        pixelSize: 18
                    }
                    anchors {
                        topMargin: songCoverRectangle.height + 25

                        leftMargin: 15
                        rightMargin: 15
                    }

                }

                PropertyChanges {
                    target: artistNameLbl

                    horizontalAlignment: Text.AlignHCenter

                    font {
                        pixelSize: 18
                    }

                    anchors {
                        topMargin: 15
                    }
                }

                PropertyChanges {
                    target: controlsFlow

                    columns:5

                    anchors.leftMargin: 0
                    anchors.rightMargin: 0
                }

                PropertyChanges {
                    target: sliderItem

                    opacity: 1
                }

                PropertyChanges {
                    target: playlistsLayout

                    opacity: 1
                }


            }
        ]

        transitions: Transition{
            PropertyAnimation {
                target: collapseBtn
                property: "opacity"
                duration: 200
            }

            PropertyAnimation {
                target: volumeBtn
                property: "opacity"
                duration: 200
            }

            PropertyAnimation {
                target: root
                property: "height"
                duration: 200
            }

            PropertyAnimation {
                target: root.background
                property: "radius"
                duration: 200
            }

            PropertyAnimation {
                target: songCoverRectangle
                properties: "radius,height,width,anchors.leftMargin,anchors.topMargin"
                duration: 200
            }

            PropertyAnimation {
                target: trackTitleLbl
                properties: "horizontalAlignment,anchors.topMargin,anchors.leftMargin,anchors.rightMargin,font.pixelSize"
                duration: 200
            }

            PropertyAnimation {
                target: artistNameLbl
                properties: "horizontalAlignment,anchors.topMargin,anchors.leftMargin,anchors.rightMargin,font.pixelSize"
                duration: 200
            }

            PropertyAnimation {
                target: controlsFlow
                properties: "anchors.leftMargin,anchors.rightMargin"
                duration: 200
            }

            PropertyAnimation {
                target: sliderItem
                property: "opacity"
                duration: 200
            }

            PropertyAnimation {
                target: playlistsLayout
                property: "opacity"
                duration: 200
            }
        }
    }

    Connections {
        target: player

        function onDurationChanged(duration) {
            slider.to = duration
        }

        function onPositionChanged(position) {
            slider.value = position
        }

        function onPlaybackStateChanged(newState){
            if (newState === MediaPlayer.PausedState || newState === MediaPlayer.StoppedState )
            {
                playPauseBtn.icon.source= "qrc:/Player/play.svg"
            }
            else {
                playPauseBtn.icon.source="qrc:/Player/pause.svg"
            }
        }

        function onArtistChanged(artist) {
            artistNameLbl.text = (artist  !== "" ?artist: "Unkown")
        }

        function onTrackTitleChanged(trackTitle) {
            trackTitleLbl.text = (trackTitle !== "" ?trackTitle: "Unkown")
        }

        function onVolumeChanged (newVolume) {

            volumeSlider.value = newVolume
            if(newVolume > 0)
                player.setMuted(false)

            setVolumeBtnIconByVolume(newVolume)

        }

        function onMutedChanged(muted) {
            if(muted === true)
            {
                setVolumeBtnIconByVolume(0)
            }
            else {
                setVolumeBtnIconByVolume(player.volume())
            }
        }

        function onSeekableChanged(seekable) {
            slider.enabled = seekable
        }

        function onThumbnailChanged(source) {
            if(source === "")
            {
                songCoverImage.source = "qrc:/track.svg"
            }
            else {
                songCoverImage.source = "file://"+source
            }
        }

        function onShuffleChanged(newShuffle) {
            if (newShuffle === Player.ShuffleOn) {
                shuffleBtn.icon.source = "qrc:/Player/shuffle.svg"
            }
            else {
                shuffleBtn.icon.source = "qrc:/Player/shuffle-off.svg"
            }
        }

        function onLoopChanged(newLoop) {
            if (newLoop=== Player.LoopOnce) {
                repeatBtn.icon.source = "qrc:/Player/repeat-one.svg"
            }
            else if (newLoop === Player.LoopAll) {
                repeatBtn.icon.source = "qrc:/Player/repeat-all.svg"
            }
            else {
                repeatBtn.icon.source = "qrc:/Player/repeat-off.svg"
            }
        }
    } // END of Connections

    function setVolumeBtnIconByVolume(newVolume)
    {
        let iconSource = "qrc:/Player/volume-level-2.svg"

        if(newVolume === 0 )
        {
            player.setMuted(true)
            iconSource = "qrc:/Player/muted.svg"
        }
        else if(newVolume < 1/3) {
            iconSource = "qrc:/Player/volume-level-0.svg"
        }
        else if (newVolume < 2/3)
        {
            iconSource = "qrc:/Player/volume-level-1.svg"
        }
        else {
            iconSource = "qrc:/Player/volume-level-2.svg"
        }

        volumeBtn.icon.source = iconSource
    }

}
