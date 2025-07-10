import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: tripDetailPage
    property var tripData: ({});

    signal backClicked()

    background: Rectangle {
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#6298de" }
            GradientStop { position: 0.7; color: "#6298de" }
            GradientStop { position: 1.0; color: "#3C64B1" }
        }
    }

    Flickable {
        anchors.fill: parent
        anchors.bottomMargin: backButton.height + editNotesButton.height + 30 // Adjusted for two buttons
        contentHeight: gridLayout.implicitHeight
        flickableDirection: Flickable.VerticalFlick

        GridLayout {
            id: gridLayout
            columns: 2
            width: parent.width
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            columnSpacing: 10

            // --- Trip Information ---
            Rectangle {
                Layout.columnSpan: 2
                Layout.fillWidth: true
                height: 30
                color: "#20ffffff"
                radius: 6
                Label {
                    text: "Trip Information"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    font.bold: true
                    color: "white"
                }
            }

            Label { text: "<b>Driver:</b>"; textFormat: Text.RichText; color: "white" }
            Label { text: tripData.name; wrapMode: Label.WordWrap; Layout.fillWidth: true; color: "white" }

            Label { text: "<b>Vehicle:</b>"; textFormat: Text.RichText; color: "white" }
            Label { text: tripData.vehicle; wrapMode: Label.WordWrap; Layout.fillWidth: true; color: "white" }

            Label { text: "<b>Location:</b>"; textFormat: Text.RichText; color: "white" }
            Label { text: tripData.location; wrapMode: Label.WordWrap; Layout.fillWidth: true; color: "white" }

            Label { text: "<b>Date:</b>"; textFormat: Text.RichText; color: "white" }
            Label { text: tripData.startDate; wrapMode: Label.WordWrap; Layout.fillWidth: true; color: "white" }

            Label { text: "<b>Start Time:</b>"; textFormat: Text.RichText; color: "white" }
            Label { text: tripData.startTime; wrapMode: Label.WordWrap; Layout.fillWidth: true; color: "white" }

            Label { text: "<b>End Time:</b>"; textFormat: Text.RichText; color: "white" }
            Label { text: tripData.endTime; wrapMode: Label.WordWrap; Layout.fillWidth: true; color: "white" }

            Label { text: "<b>Duration:</b>"; textFormat: Text.RichText; color: "white" }
            Label { text: tripData.duration + " minutes"; wrapMode: Label.WordWrap; Layout.fillWidth: true; color: "white" }

            // --- Energy & Performance ---
            Rectangle {
                Layout.columnSpan: 2
                Layout.fillWidth: true
                height: 30
                color: "#20ffffff"
                radius: 6
                Label {
                    text: "Energy & Performance"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    font.bold: true
                    color: "white"
                }
            }

            Label { text: "<b>Start Battery:</b>"; textFormat: Text.RichText; color: "white" }
            Label { text: tripData.startOdometer.toFixed(1) + "%"; wrapMode: Label.WordWrap; Layout.fillWidth: true; color: "white" }

            Label { text: "<b>End Battery:</b>"; textFormat: Text.RichText; color: "white" }
            Label { text: tripData.endOdometer.toFixed(1) + "%"; wrapMode: Label.WordWrap; Layout.fillWidth: true; color: "white" }



            Label { text: "<b>Energy Used:</b>"; textFormat: Text.RichText; color: "white" }
            Label { text: tripData.energyUsed.toFixed(2) + " kWh"; wrapMode: Label.WordWrap; Layout.fillWidth: true; color: "white" }

            Label { text: "<b>Distance:</b>"; textFormat: Text.RichText; color: "white" }
            Label { text: tripData.distance + " m"; wrapMode: Label.WordWrap; Layout.fillWidth: true; color: "white" }

            Label { text: "<b>Average Speed:</b>"; textFormat: Text.RichText; color: "white" }
            Label { text: tripData.averageSpeed.toFixed(1) + " m/s"; wrapMode: Label.WordWrap; Layout.fillWidth: true; color: "white" }

            Label { text: "<b>Favorite:</b>"; textFormat: Text.RichText; color: "white" }
            Text {
                id: favoriteStar
                text: tripData.favorite ? "★" : "☆"
                font.pixelSize: 24
                color: tripData.favorite ? "gold" : "gray"

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var newStatus = !tripDetailPage.tripData.favorite;
                        tripDetailPage.tripData.favorite = newStatus;

                        // Manually update the star's appearance for immediate feedback
                        favoriteStar.text = newStatus ? "★" : "☆";
                        favoriteStar.color = newStatus ? "gold" : "gray";

                        // Call the C++ backend to save the change
                        dbHandler.updateTripFavoriteStatus(tripDetailPage.tripData.id, newStatus);
                    }
                }
            }

            Label { text: "<b>Notes:</b>"; textFormat: Text.RichText; color: "white" }
            Label {
                id: notesLabel
                text: tripData.notes ? tripData.notes : "No notes for this trip."
                wrapMode: Label.WordWrap
                Layout.fillWidth: true
                color: "white"
            }
        }
    }

    RowLayout {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10
        spacing: 20

        Button {
            id: backButton
            text: "Back"
            onClicked: backClicked()
            Accessible.name: "Back to trips list"
            Accessible.description: "Returns to the list of all trips."
            background: Rectangle {
                color: "#20ffffff"
                radius: 6
                border.color: "#60ffffff"
            }
            contentItem: Label {
                text: parent.text
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Button {
            id: editNotesButton
            text: "Edit"
            onClicked: notesPopup.open()
            Accessible.name: "Edit notes"
            Accessible.description: "Opens a dialog to edit the trip notes."
            background: Rectangle {
                color: "#20ffffff"
                radius: 6
                border.color: "#60ffffff"
            }
            contentItem: Label {
                text: parent.text
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    Popup {
        id: notesPopup
        width: parent.width * 0.9
        height: parent.height * 0.6
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: Rectangle {
            color: "#3C64B1"
            border.color: "#60ffffff"
            radius: 12
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10

            Label {
                text: "Edit Notes"
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
                color: "white"
            }

            TextArea {
                id: notesTextArea
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: tripDetailPage.tripData.notes
                wrapMode: TextArea.Wrap
                color: "white"
                leftPadding: 8
                rightPadding: 8
                topPadding: 8
                bottomPadding: 8

                background: Rectangle {
                    color: "#20ffffff"
                    radius: 6
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10

                Button {
                    text: "Cancel"
                    onClicked: notesPopup.close()
                    Accessible.name: "Cancel notes edit"
                    Accessible.description: "Closes the dialog without saving changes to the notes."
                    background: Rectangle {
                        color: "#20ffffff"
                        radius: 6
                        border.color: "#60ffffff"
                    }
                    contentItem: Label {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    text: "Save"
                    highlighted: true
                    onClicked: {
                        var newNotes = notesTextArea.text;
                        tripDetailPage.tripData.notes = newNotes;
                        notesLabel.text = newNotes ? newNotes : "No notes for this trip.";
                        dbHandler.updateTripNotes(tripDetailPage.tripData.id, newNotes);
                        notesPopup.close();
                    }
                    Accessible.name: "Save notes"
                    Accessible.description: "Saves the changes to the trip notes and closes the dialog."
                    background: Rectangle {
                        color: parent.highlighted ? "#40ffffff" : "#20ffffff"
                        radius: 6
                        border.color: "#60ffffff"
                    }
                    contentItem: Label {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
}
