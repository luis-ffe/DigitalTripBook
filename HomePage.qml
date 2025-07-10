import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 // Needed for Label in some setups

Rectangle {
    // Signal to notify the main window to navigate to the journeys page
    signal journeysClicked
    // Signals for the new banners
    signal statisticsClicked
    signal mediaClicked

    gradient: Gradient {
        GradientStop { position: 0.0; color: "#5D9CEC" }
        GradientStop { position: 1.0; color: "#3C64B1" }
    }

    // Add some subtle transparency overlay
    Rectangle {
        anchors.fill: parent
        color: "white"
        opacity: 0.05
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 18

        // Journeys banner
        Rectangle {
            Layout.fillWidth: true
            height: 80
            color: "#20ffffff"
            radius: 12
            border.color: "#60ffffff"

            MouseArea {
                anchors.fill: parent
                // When clicked, emit the signal
                onClicked: journeysClicked()
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                Label {
                    text: "Journeys"
                    font.pixelSize: 22
                    color: "white"
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }

        // Statistics banner
        Rectangle {
            Layout.fillWidth: true
            height: 80
            color: "#20ffffff"
            radius: 12
            border.color: "#60ffffff"

            MouseArea {
                anchors.fill: parent
                onClicked: statisticsClicked()
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                Label {
                    text: "Statistics"
                    font.pixelSize: 22
                    color: "white"
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }

        // Media banner
        Rectangle {
            Layout.fillWidth: true
            height: 80
            color: "#20ffffff"
            radius: 12
            border.color: "#60ffffff"

            MouseArea {
                anchors.fill: parent
                onClicked: mediaClicked()
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                Label {
                    text: "Media"
                    font.pixelSize: 22
                    color: "white"
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }

        // Spacer to push banners to the top
        Item { Layout.fillHeight: true }
    }
}
