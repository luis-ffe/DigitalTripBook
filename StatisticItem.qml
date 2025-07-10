import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Rectangle {
    id: wrapper
    property alias label: nameLabel.text
    property alias value: valueLabel.text

    color: "transparent"
    border.color: "#FFFFFF"
    border.width: 1
    radius: 8
    Layout.fillWidth: true
    height: 80

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 5

        Label {
            id: nameLabel
            color: "white"
            font.pixelSize: 16
            Layout.alignment: Qt.AlignHCenter
        }
        Label {
            id: valueLabel
            color: "white"
            font.bold: true
            font.pixelSize: 22
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
