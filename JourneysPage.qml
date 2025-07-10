import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

Rectangle {
    id: journeysRoot
    // The dbHandler is accessed globally from the C++ context, so no local property is needed.

    signal tripSelected(int tripId)
    signal addTripClicked

    // Store the current page number
    property int currentPage: 0
    property int tripsPerPage: 10 // Or any other number

    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        running: false // Initially not running
    }

    gradient: Gradient {
        GradientStop { position: 0.0; color: "#4A90E2" }
        GradientStop { position: 1.0; color: "#3C64B1" }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        ListView {
            id: tripList
            Layout.fillWidth: true
            Layout.fillHeight: true
            // The model is now a simple list model that we will populate
            model: ListModel {}
            delegate: Rectangle {
                width: parent.width
                height: 80
                color: "transparent"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // When a trip is clicked, emit a signal with its ID
                        // The key from C++ is "id", so we use model.id
                        journeysRoot.tripSelected(model.id);
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10

                    Rectangle {
                        width: parent.width
                        height: 70
                        radius: 8
                        color: "#ffffff"
                        border.color: "#e0e0e0"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 15
                            anchors.rightMargin: 15
                            spacing: 10

                            ColumnLayout {
                                spacing: 2
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter

                                Text {
                                    text: "Driver: " + model.name
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: "#333"
                                }
                                Text {
                                    text: "Date: " + model.startDate
                                    font.pixelSize: 14
                                    color: "#666"
                                }
                            }
                        }
                    }
                }
            }

            // When the component is ready, load the first page of trips
            Component.onCompleted: {
                // Load the first page of trips when the component is ready
                loadMoreTrips();
            }

            function loadMoreTrips() {
                // Call the C++ backend to get the next page of trips
                var newTrips = databaseHandler.getTrips(currentPage, tripsPerPage);

                if (newTrips.length > 0) {
                    for (var i = 0; i < newTrips.length; i++) {
                        tripList.model.append(newTrips[i]);
                    }
                    currentPage++;
                } else {
                    console.log("No more trips to load.");
                    // Optionally, disable the "Next" button here
                }
            }
        }
    }

    // Function to load trips for a given page
    function loadTrips(page) {
        busyIndicator.running = true;
        // Call the C++ method to get trips
        var trips = dbHandler.getTrips(page, tripsPerPage);
        busyIndicator.running = false;

        if (trips.length > 0) {
            currentPage = page;
            tripList.model.clear();
            for (var i = 0; i < trips.length; i++) {
                tripList.model.append(trips[i]);
            }
        } else {
            // Handle case where there are no more trips
            console.log("No more trips to load.");
            // Optionally, disable the "Next" button here
        }
    }
}
