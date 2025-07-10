import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#5D9CEC" }
        GradientStop { position: 1.0; color: "#3C64B1" }
    }

    Label {
        text: "Statistics Page"
        anchors.centerIn: parent
        color: "white"
        font.pixelSize: 24
    }
}
