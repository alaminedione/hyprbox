import QtQuick 2.15
import QtGraphicalEffects 1.0
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080

    // === CATPPUCCIN MOCHA PALETTE ===
    property color base: "#1e1e2e"
    property color mantle: "#181825"
    property color crust: "#11111b"
    property color surface0: "#313244"
    property color surface1: "#45475a"
    property color surface2: "#585b70"
    property color text_color: "#cdd6f4"
    property color subtext0: "#a6adc8"
    property color lavender: "#b4befe"
    property color blue: "#89b4fa"
    property color mauve: "#cba6f7"
    property color green: "#a6e3a1"
    property color red: "#f38ba8"
    property color peach: "#fab387"

    property int currentSession: sessionModel.lastIndex
    property int currentUser: userModel.lastIndex
    property string currentUsername: userModel.lastUser

    TextConstants { id: textConstants }

    // Background
    Image {
        id: backgroundImage
        source: "backgrounds/wallpaper.png"
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        clip: true
    }

    // Blur overlay
    FastBlur {
        anchors.fill: backgroundImage
        source: backgroundImage
        radius: 50
    }

    // Dark overlay
    Rectangle {
        anchors.fill: parent
        color: root.base
        opacity: 0.7
    }

    // === MAIN CONTAINER ===
    Column {
        anchors.centerIn: parent
        spacing: 20

        // Clock
        Text {
            id: timeLabel
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 72
            font.bold: true
            color: root.text_color

            function updateTime() {
                text = Qt.formatTime(new Date(), "HH:mm")
            }

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: timeLabel.updateTime()
            }

            Component.onCompleted: updateTime()
        }

        // Date
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 18
            color: root.subtext0
            text: Qt.formatDate(new Date(), "dddd, d MMMM yyyy")
        }

        Item { width: 1; height: 30 }

        // === USER AVATAR + SELECTOR ===
        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 200
            height: 150

            // Left arrow
            Rectangle {
                id: leftArrow
                anchors.left: parent.left
                anchors.verticalCenter: avatarContainer.verticalCenter
                width: 30
                height: 30
                radius: 15
                color: leftArrowArea.containsMouse ? root.surface1 : "transparent"
                visible: userModel.count > 1

                Text {
                    anchors.centerIn: parent
                    text: "󰅁"
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 18
                    color: root.subtext0
                }

                MouseArea {
                    id: leftArrowArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.currentUser = (root.currentUser - 1 + userModel.count) % userModel.count
                        root.currentUsername = userModel.data(userModel.index(root.currentUser, 0), Qt.UserRole + 1)
                        passwordField.text = ""
                        passwordField.focus = true
                    }
                }
            }

            // Avatar
            Rectangle {
                id: avatarContainer
                anchors.horizontalCenter: parent.horizontalCenter
                width: 120
                height: 120
                radius: 60
                color: root.surface0
                border.color: root.mauve
                border.width: 3

                Image {
                    id: avatar
                    source: "/var/lib/AccountsService/icons/" + root.currentUsername
                    anchors.fill: parent
                    anchors.margins: 3
                    fillMode: Image.PreserveAspectCrop
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: avatar.width
                            height: avatar.height
                            radius: width / 2
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰀄"
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 48
                    color: root.mauve
                    visible: avatar.status !== Image.Ready
                }
            }

            // Right arrow
            Rectangle {
                id: rightArrow
                anchors.right: parent.right
                anchors.verticalCenter: avatarContainer.verticalCenter
                width: 30
                height: 30
                radius: 15
                color: rightArrowArea.containsMouse ? root.surface1 : "transparent"
                visible: userModel.count > 1

                Text {
                    anchors.centerIn: parent
                    text: "󰅂"
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 18
                    color: root.subtext0
                }

                MouseArea {
                    id: rightArrowArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.currentUser = (root.currentUser + 1) % userModel.count
                        root.currentUsername = userModel.data(userModel.index(root.currentUser, 0), Qt.UserRole + 1)
                        passwordField.text = ""
                        passwordField.focus = true
                    }
                }
            }

            // Username
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: avatarContainer.bottom
                anchors.topMargin: 10
                text: root.currentUsername
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 24
                font.bold: true
                color: root.text_color
            }
        }

        Item { width: 1; height: 10 }

        // === LOGIN BOX ===
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 350
            height: 230
            radius: 16
            color: root.mantle
            border.color: root.surface1
            border.width: 2

            Column {
                anchors.centerIn: parent
                spacing: 15

                // Username field (manual input option)
                Rectangle {
                    width: 280
                    height: 45
                    radius: 10
                    color: root.surface0
                    border.color: usernameField.activeFocus ? root.blue : root.surface1
                    border.width: 2

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Text {
                            text: "󰀄"
                            font.family: "JetBrains Mono Nerd Font"
                            font.pixelSize: 18
                            color: root.blue
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        TextInput {
                            id: usernameField
                            width: parent.width - 40
                            height: parent.height
                            verticalAlignment: TextInput.AlignVCenter
                            font.family: "JetBrains Mono Nerd Font"
                            font.pixelSize: 14
                            color: root.text_color
                            selectionColor: root.blue
                            clip: true
                            text: root.currentUsername

                            onTextChanged: {
                                root.currentUsername = text
                            }

                            Text {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                text: "Nom d'utilisateur..."
                                color: root.subtext0
                                font: usernameField.font
                                visible: !usernameField.text && !usernameField.activeFocus
                            }

                            Keys.onTabPressed: passwordField.focus = true
                        }
                    }
                }

                // Password field
                Rectangle {
                    width: 280
                    height: 45
                    radius: 10
                    color: root.surface0
                    border.color: passwordField.activeFocus ? root.mauve : root.surface1
                    border.width: 2

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Text {
                            text: "󰌾"
                            font.family: "JetBrains Mono Nerd Font"
                            font.pixelSize: 18
                            color: root.mauve
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        TextInput {
                            id: passwordField
                            width: parent.width - 40
                            height: parent.height
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Password
                            font.family: "JetBrains Mono Nerd Font"
                            font.pixelSize: 14
                            color: root.text_color
                            selectionColor: root.mauve
                            clip: true

                            Text {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                text: "Mot de passe..."
                                color: root.subtext0
                                font: passwordField.font
                                visible: !passwordField.text && !passwordField.activeFocus
                            }

                            onAccepted: sddm.login(root.currentUsername, passwordField.text, root.currentSession)
                            
                            Keys.onTabPressed: usernameField.focus = true
                        }
                    }
                }

                // Login button
                Rectangle {
                    width: 280
                    height: 45
                    radius: 10
                    color: loginArea.containsMouse ? root.mauve : root.surface1

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰍂  Se connecter"
                        font.family: "JetBrains Mono Nerd Font"
                        font.pixelSize: 14
                        font.bold: true
                        color: loginArea.containsMouse ? root.crust : root.text_color
                    }

                    MouseArea {
                        id: loginArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sddm.login(root.currentUsername, passwordField.text, root.currentSession)
                    }
                }

                // Error message
                Text {
                    id: errorMessage
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 12
                    color: root.red
                    visible: text !== ""
                }
            }
        }
    }

    // === BOTTOM BAR ===
    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 30
        spacing: 20

        // Session selector
        Rectangle {
            width: 200
            height: 40
            radius: 8
            color: root.surface0
            border.color: sessionArea.containsMouse ? root.mauve : root.surface1
            border.width: 1

            Row {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    text: "󰍹"
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 16
                    color: root.blue
                }

                Text {
                    text: sessionModel.data(sessionModel.index(root.currentSession, 0), Qt.DisplayRole) || "Session"
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 12
                    color: root.text_color
                }

                Text {
                    text: sessionPopup.visible ? "󰅀" : "󰅂"
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 12
                    color: root.subtext0
                }
            }

            MouseArea {
                id: sessionArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sessionPopup.visible = !sessionPopup.visible
            }

            // Session dropdown
            Rectangle {
                id: sessionPopup
                visible: false
                width: parent.width
                height: sessionModel.rowCount() * 35
                anchors.bottom: parent.top
                anchors.bottomMargin: 5
                radius: 8
                color: root.mantle
                border.color: root.surface1
                border.width: 1
                clip: true

                Column {
                    anchors.fill: parent

                    Repeater {
                        model: sessionModel

                        Rectangle {
                            width: sessionPopup.width
                            height: 35
                            radius: 4
                            color: sessionItemArea.containsMouse ? root.surface1 : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: name
                                font.family: "JetBrains Mono Nerd Font"
                                font.pixelSize: 12
                                color: index === root.currentSession ? root.mauve : root.text_color
                            }

                            MouseArea {
                                id: sessionItemArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.currentSession = index
                                    sessionPopup.visible = false
                                }
                            }
                        }
                    }
                }
            }
        }

        // Power button
        Rectangle {
            width: 40
            height: 40
            radius: 8
            color: powerArea.containsMouse ? root.red : root.surface0

            Behavior on color {
                ColorAnimation { duration: 200 }
            }

            Text {
                anchors.centerIn: parent
                text: "󰐥"
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 18
                color: powerArea.containsMouse ? root.crust : root.red
            }

            MouseArea {
                id: powerArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.powerOff()
            }
        }

        // Reboot button
        Rectangle {
            width: 40
            height: 40
            radius: 8
            color: rebootArea.containsMouse ? root.peach : root.surface0

            Behavior on color {
                ColorAnimation { duration: 200 }
            }

            Text {
                anchors.centerIn: parent
                text: "󰜉"
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 18
                color: rebootArea.containsMouse ? root.crust : root.peach
            }

            MouseArea {
                id: rebootArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.reboot()
            }
        }
    }

    // Connections
    Connections {
        target: sddm
        function onLoginFailed() {
            errorMessage.text = "󰀦 Mot de passe incorrect!"
            passwordField.text = ""
            passwordField.focus = true
        }
        function onLoginSucceeded() {
            errorMessage.text = ""
        }
    }

    Component.onCompleted: passwordField.focus = true
}
