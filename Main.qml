import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15


ApplicationWindow {
    id: window
    width: 400
    height: 700
    visible: true

    function navigateBack() {
        if (stackView.depth > 1) {
            // Explicitly move focus to a safe, persistent item (the StackView itself)
            // before popping and destroying the current page. This prevents the
            // "stale focus object" crash.
            stackView.forceActiveFocus();
            stackView.pop();
        }
    }

    header: ToolBar {
        height: 50
        background: Rectangle {
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#438fe6" }
                GradientStop { position: 0.8; color: "#357ABD" }
            }

            // Bottom border
            Rectangle {
                width: parent.width
                height: 1
                color: "#40ffffff"
                anchors.bottom: parent.bottom
            }
        }

        RowLayout {
            anchors.fill: parent
            spacing: 10

            ToolButton {
                id: backButton
                text: "‹"
                font.pixelSize: 30
                font.bold: false
                visible: stackView.depth > 1
                onClicked: window.navigateBack()
                contentItem: Text {
                    text: backButton.text
                    font: backButton.font
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: "transparent"
                }
            }

            Item { Layout.fillWidth: true }

            Label {
                text: qsTr("Digital Trip Book")
                font.pixelSize: 20
                font.bold: true
                color: "white"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Item {
                Layout.fillWidth: true
                width: backButton.implicitWidth
            }
        }
    }

    // App state: list of trips
    property var trips: []

    // Show/hide Add Trip dialog
    property bool showAddTrip: false

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: homePageComponent
    }

    // Define the pages as components. This is a more robust way to handle
    // navigation and avoids potential issues with object creation and focus.
    Component {
        id: homePageComponent
        HomePage {
            onJourneysClicked: stackView.push(journeysPageComponent)
            onStatisticsClicked: stackView.push(statisticsPageComponent)
            onMediaClicked: stackView.push(mediaPageComponent)
        }
    }

    Component {
        id: journeysPageComponent
        JourneysPage {
            onAddTripClicked: showAddTrip = true
            onTripSelected: function(tripId) {
                var tripDetails = databaseHandler.getTripDetails(tripId);
                stackView.push(tripDetailComponent, {
                    "tripData": tripDetails,
                    "databaseHandler": databaseHandler
                });
            }
        }
    }

    Component {
        id: statisticsPageComponent
        StatisticsPage {}
    }

    Component {
        id: mediaPageComponent
        MediaPage {}
    }

    Component {
        id: tripDetailComponent
        TripDetailPage {
            // The main window's back button will handle popping the view.
            // This simplifies the logic and ensures consistent behavior.
            onBackClicked: window.navigateBack()
        }
    }

    // Add Trip Dialog
    Dialog {
        id: addTripDialog
        modal: true
        visible: showAddTrip
        x: (window.width - width) / 2
        y: (window.height - height) / 3
        width: 320
        height: 370
        title: qsTr("Add Trip")
        standardButtons: Dialog.Ok | Dialog.Cancel

        property string tripName: ""
        property string tripDate: ""
        property string tripVehicle: ""

        contentItem: ColumnLayout {
            spacing: 12

            TextField {
                id: tripNameField
                placeholderText: qsTr("Trip Name")
                text: addTripDialog.tripName
                onTextChanged: addTripDialog.tripName = text
            }
            TextField {
                id: tripDateField
                placeholderText: qsTr("Start Date (e.g. 2025-07-09)")
                text: addTripDialog.tripDate
                onTextChanged: addTripDialog.tripDate = text
            }
            TextField {
                id: tripVehicleField
                placeholderText: qsTr("Vehicle")
                text: addTripDialog.tripVehicle
                onTextChanged: addTripDialog.tripVehicle = text
            }
        }

        onAccepted: {
            if (tripName && tripDate && tripVehicle) {
                // Add trip to the list
                trips = trips.concat([{ name: tripName, startDate: tripDate, vehicle: tripVehicle }]);
                tripName = ""; tripDate = ""; tripVehicle = "";
                showAddTrip = false;
            }
        }
        onRejected: {
            showAddTrip = false;
        }
    }
}
