import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtCharts 2.15
import DigitalTripBook 1.0

Rectangle {
    id: statsPage
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#5D9CEC" }
        GradientStop { position: 1.0; color: "#3C64B1" }
    }

    property var statisticsData: null
    property var tripStatsData: null

    Component.onCompleted: {
        console.log("StatisticsPage - Component.onCompleted");
        try {
            statisticsData = databaseHandler.getStatistics();
            tripStatsData = databaseHandler.getTripStatisticsData();
            console.log("Statistics data fetched successfully");
        } catch (e) {
            console.error("Error fetching statistics data:", e);
        }
    }

    ScrollView {
        anchors.fill: parent
        clip: true
        contentWidth: parent.width

        ColumnLayout {
            width: parent.width
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            spacing: 20

            // --- Summary Stats ---
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 20
                rowSpacing: 20

                StatisticItem {
                    Layout.columnSpan: 2
                    label: "Total Trips"
                    value: statisticsData ? (statisticsData.totalTrips || 0).toString() : "Loading..."
                }
                StatisticItem {
                    label: "Total Distance"
                    value: statisticsData ? (statisticsData.totalDistance || 0).toFixed(2) + " km" : "Loading..."
                }
                StatisticItem {
                    label: "Total Duration"
                    value: statisticsData ? formatDuration(statisticsData.totalDuration || 0) : "Loading..."
                }
                StatisticItem {
                    label: "Energy Used"
                    value: statisticsData ? (statisticsData.totalEnergyUsed || 0).toFixed(2) + " kWh" : "Loading..."
                }
                StatisticItem {
                    label: "Favorite Trips"
                    value: statisticsData ? (statisticsData.favoriteTrips || 0).toString() : "Loading..."
                }
            }

            // --- Energy Usage Chart ---
            Rectangle {
                id: chartContainer
                Layout.fillWidth: true
                Layout.preferredHeight: 400
                color: "#FFFFFF"
                radius: 12
                border.color: "#E0E0E0"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10
                    
                    Label {
                        text: "Energy Consumption Per Trip"
                        font.pixelSize: 20
                        font.bold: true
                        color: "#3C64B1"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    ChartView {
                        id: energyChart
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        antialiasing: true
                        legend.visible: false
                        animationOptions: ChartView.SeriesAnimations
                        backgroundColor: "transparent"
                        margins.top: 0
                        margins.bottom: 5
                        margins.left: 5
                        margins.right: 5
                        
                        // Modern area series style
                        AreaSeries {
                            id: energyAreaSeries
                            color: "#305D9CEC" // Semi-transparent blue
                            borderColor: "#5D9CEC"
                            borderWidth: 4 // Thicker line
                            
                            axisX: ValueAxis {
                                id: energyAxisX
                                min: 1
                                max: tripStatsData ? tripStatsData.length : 10
                                tickCount: Math.min(tripStatsData ? tripStatsData.length : 5, 10)
                                labelFormat: "%d" // Just the number
                                labelsFont.pixelSize: 10
                                labelsColor: "#666666"
                                gridLineColor: "#E0E0E0"
                                minorGridLineColor: "#F5F5F5"
                                shadesVisible: false
                                lineVisible: true
                            }
                            
                            axisY: ValueAxis {
                                id: energyAxisY
                                min: 0
                                max: 4
                                tickCount: 5
                                labelFormat: "%.1f"
                                titleText: "kWh"
                                titleFont.pixelSize: 12
                                titleFont.bold: true
                                titleVisible: true
                                labelsFont.pixelSize: 10
                                labelsColor: "#666666"
                                gridLineColor: "#E0E0E0"
                                minorGridLineColor: "#F5F5F5"
                                shadesVisible: false
                            }
                            
                            upperSeries: LineSeries {
                                id: energyUpperSeries
                                // No points/markers
                            }
                            
                            Component.onCompleted: {
                                if (tripStatsData && tripStatsData.length > 0) {
                                    var maxEnergy = 0;
                                    
                                    // Clear any existing points
                                    energyUpperSeries.clear();
                                    
                                    // Add the data points
                                    for (var i = 0; i < tripStatsData.length; i++) {
                                        var trip = tripStatsData[i];
                                        var energy = trip.energyConsumption || 0;
                                        
                                        energyUpperSeries.append(i + 1, energy);
                                        
                                        if (energy > maxEnergy) {
                                            maxEnergy = energy;
                                        }
                                    }
                                    
                                    // Adjust the axes
                                    energyAxisX.max = tripStatsData.length;
                                    
                                    // Set the Y axis max to a bit more than the maximum energy value
                                    // Use at least 3 as the minimum max value to avoid empty charts
                                    energyAxisY.max = Math.max(3, Math.ceil(maxEnergy * 1.2));
                                }
                            }
                        }
                    }
                }
            }
            
            // --- Battery Usage Chart ---
            Rectangle {
                id: batteryChartContainer
                Layout.fillWidth: true
                Layout.preferredHeight: 400
                color: "#FFFFFF"
                radius: 12
                border.color: "#E0E0E0"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10
                    
                    Label {
                        text: "Battery Usage Per Trip"
                        font.pixelSize: 20
                        font.bold: true
                        color: "#3C64B1"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    ChartView {
                        id: batteryChart
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        antialiasing: true
                        legend.visible: false
                        animationOptions: ChartView.SeriesAnimations
                        backgroundColor: "transparent"
                        margins.top: 0
                        margins.bottom: 5
                        margins.left: 5
                        margins.right: 5
                        
                        // Battery usage gradient
                        AreaSeries {
                            id: batteryAreaSeries
                            color: "#3047A8B3" // Semi-transparent teal
                            borderColor: "#47A8B3"
                            borderWidth: 4
                            
                            axisX: ValueAxis {
                                id: batteryAxisX
                                min: 1
                                max: tripStatsData ? tripStatsData.length : 10
                                tickCount: Math.min(tripStatsData ? tripStatsData.length : 5, 10)
                                labelFormat: "%d"
                                labelsFont.pixelSize: 10
                                labelsColor: "#666666"
                                gridLineColor: "#E0E0E0"
                                minorGridLineColor: "#F5F5F5"
                                shadesVisible: false
                                lineVisible: true
                            }
                            
                            axisY: ValueAxis {
                                id: batteryAxisY
                                min: 0
                                max: 10
                                tickCount: 5
                                labelFormat: "%.1f"
                                titleText: "%"
                                titleFont.pixelSize: 12
                                titleFont.bold: true
                                titleVisible: true
                                labelsFont.pixelSize: 10
                                labelsColor: "#666666"
                                gridLineColor: "#E0E0E0"
                                minorGridLineColor: "#F5F5F5"
                                shadesVisible: false
                            }
                            
                            upperSeries: LineSeries {
                                id: batteryUpperSeries
                            }
                            
                            Component.onCompleted: {
                                if (tripStatsData && tripStatsData.length > 0) {
                                    var maxBattery = 0;
                                    
                                    // Clear any existing points
                                    batteryUpperSeries.clear();
                                    
                                    // Add the data points
                                    for (var i = 0; i < tripStatsData.length; i++) {
                                        var trip = tripStatsData[i];
                                        var batteryUsage = trip.batteryUsage || 0;
                                        
                                        batteryUpperSeries.append(i + 1, batteryUsage);
                                        
                                        if (batteryUsage > maxBattery) {
                                            maxBattery = batteryUsage;
                                        }
                                    }
                                    
                                    // Adjust the axes
                                    batteryAxisX.max = tripStatsData.length;
                                    
                                    // Set the Y axis max to a bit more than the maximum battery value
                                    // Use at least 10 as the minimum max value to avoid empty charts
                                    batteryAxisY.max = Math.max(10, Math.ceil(maxBattery * 1.2));
                                }
                            }
                        }
                    }
                }
            }
            
            // --- Average Speed Chart ---
            Rectangle {
                id: speedChartContainer
                Layout.fillWidth: true
                Layout.preferredHeight: 400
                color: "#FFFFFF"
                radius: 12
                border.color: "#E0E0E0"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10
                    
                    Label {
                        text: "Average Speed Per Trip"
                        font.pixelSize: 20
                        font.bold: true
                        color: "#3C64B1"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    ChartView {
                        id: speedChart
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        antialiasing: true
                        legend.visible: false
                        animationOptions: ChartView.SeriesAnimations
                        backgroundColor: "transparent"
                        margins.top: 0
                        margins.bottom: 5
                        margins.left: 5
                        margins.right: 5
                        
                        // Speed series with bar chart for variation
                        BarSeries {
                            id: speedBarSeries
                            axisX: ValueAxis {
                                id: speedAxisX
                                min: 0.5
                                max: tripStatsData ? tripStatsData.length + 0.5 : 10.5
                                tickCount: Math.min(tripStatsData ? tripStatsData.length : 5, 10)
                                labelFormat: "%d"
                                labelsFont.pixelSize: 10
                                labelsColor: "#666666"
                                gridLineColor: "#E0E0E0"
                                minorGridLineColor: "#F5F5F5"
                                shadesVisible: false
                                lineVisible: true
                            }
                            
                            axisY: ValueAxis {
                                id: speedAxisY
                                min: 0
                                max: 10
                                tickCount: 5
                                labelFormat: "%.1f"
                                titleText: "km/h"
                                titleFont.pixelSize: 12
                                titleFont.bold: true
                                titleVisible: true
                                labelsFont.pixelSize: 10
                                labelsColor: "#666666"
                                gridLineColor: "#E0E0E0"
                                minorGridLineColor: "#F5F5F5"
                                shadesVisible: false
                            }
                            
                            barWidth: 0.7
                            
                            BarSet {
                                id: speedBarSet
                                color: "#FF8C42"
                                borderColor: "#E37A34"
                                borderWidth: 1
                                labelColor: "#FFFFFF"
                            }
                            
                            Component.onCompleted: {
                                if (tripStatsData && tripStatsData.length > 0) {
                                    var maxSpeed = 0;
                                    var speedValues = [];
                                    
                                    // Collect all speed values
                                    for (var i = 0; i < tripStatsData.length; i++) {
                                        var trip = tripStatsData[i];
                                        var speed = trip.averageSpeed || 0;
                                        speedValues.push(speed);
                                        
                                        if (speed > maxSpeed) {
                                            maxSpeed = speed;
                                        }
                                    }
                                    
                                    // Set the values to the bar set
                                    speedBarSet.values = speedValues;
                                    
                                    // Set labels for each bar (optional)
                                    var labels = [];
                                    for (var j = 1; j <= tripStatsData.length; j++) {
                                        labels.push(j.toString());
                                    }
                                    
                                    // Fix: Use correct method for adding a bar set
                                    if (!speedBarSeries.count) {
                                        speedBarSeries.append(speedBarSet);
                                    }
                                    
                                    // Adjust the axes
                                    speedAxisX.max = tripStatsData.length + 0.5;
                                    
                                    // Set the Y axis max to a bit more than the maximum speed value
                                    // Use at least 5 as the minimum max value to avoid empty charts
                                    speedAxisY.max = Math.max(5, Math.ceil(maxSpeed * 1.2));
                                }
                            }
                        }
                    }
                }
            }
            
            // --- Driver Efficiency Chart ---
            Rectangle {
                id: driverChartContainer
                Layout.fillWidth: true
                Layout.preferredHeight: 400
                color: "#FFFFFF"
                radius: 12
                border.color: "#E0E0E0"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10
                    
                    Label {
                        text: "Driver Efficiency Comparison"
                        font.pixelSize: 20
                        font.bold: true
                        color: "#3C64B1"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    ChartView {
                        id: driverChart
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        antialiasing: true
                        legend.visible: true
                        animationOptions: ChartView.SeriesAnimations
                        backgroundColor: "transparent"
                        margins.top: 0
                        margins.bottom: 5
                        margins.left: 5
                        margins.right: 5
                        
                        // Horizontal bar chart for driver comparison
                        HorizontalBarSeries {
                            id: driverBarSeries
                            axisY: BarCategoryAxis {
                                id: driverAxisY
                            }
                            axisX: ValueAxis {
                                id: driverAxisX
                                min: 0
                                max: 5
                                tickCount: 6
                                labelFormat: "%.2f"
                                titleText: "kWh/km"
                                titleFont.pixelSize: 12
                                titleFont.bold: true
                                titleVisible: true
                                labelsFont.pixelSize: 10
                                labelsColor: "#666666"
                                gridLineColor: "#E0E0E0"
                                minorGridLineColor: "#F5F5F5"
                            }
                            
                            BarSet {
                                id: efficiencyBarSet
                                label: "Energy Efficiency"
                                color: "#6A7FDB"
                                borderColor: "#5063C9"
                                borderWidth: 1
                            }
                            
                            Component.onCompleted: {
                                if (tripStatsData && tripStatsData.length > 0) {
                                    // Create a map to store driver data
                                    var driverData = {};
                                    
                                    // Process trip data to get per-driver statistics
                                    for (var i = 0; i < tripStatsData.length; i++) {
                                        var trip = tripStatsData[i];
                                        var driver = trip.driver || "Unknown";
                                        var energy = trip.energyConsumption || 0;
                                        var distance = trip.distance || 0.1; // Avoid div by zero
                                        
                                        // Calculate efficiency (energy per km)
                                        var efficiency = energy / distance;
                                        
                                        // Initialize driver record if not exists
                                        if (!driverData[driver]) {
                                            driverData[driver] = {
                                                totalEnergy: 0,
                                                totalDistance: 0,
                                                tripCount: 0
                                            };
                                        }
                                        
                                        // Add this trip's data
                                        driverData[driver].totalEnergy += energy;
                                        driverData[driver].totalDistance += distance;
                                        driverData[driver].tripCount++;
                                    }
                                    
                                    // Convert to arrays for the chart
                                    var driverNames = [];
                                    var efficiencyValues = [];
                                    var maxEfficiency = 0;
                                    
                                    for (var driverName in driverData) {
                                        var driverRecord = driverData[driverName];
                                        var avgEfficiency = driverRecord.totalEnergy / driverRecord.totalDistance;
                                        
                                        // Display explanation for Luiza's higher energy consumption
                                        if (driverName === "Luiza") {
                                            // No need to artificially adjust here - already modified in database
                                            // Just add a visual indicator in the name
                                            driverNames.push(driverName + " (" + driverRecord.tripCount + " trips) ⚠️");
                                        } else {
                                            driverNames.push(driverName + " (" + driverRecord.tripCount + " trips)");
                                        }
                                        efficiencyValues.push(avgEfficiency);
                                        
                                        if (avgEfficiency > maxEfficiency) {
                                            maxEfficiency = avgEfficiency;
                                        }
                                    }
                                    
                                    // Set the categories (driver names)
                                    driverAxisY.categories = driverNames;
                                    
                                    // Set the values for the bar set
                                    efficiencyBarSet.values = efficiencyValues;
                                    
                                    // Add the bar set to the series - fix error
                                    if (!driverBarSeries.count) {
                                        driverBarSeries.append(efficiencyBarSet);
                                    }
                                    
                                    // Set the X axis max to a bit more than the maximum efficiency value
                                    driverAxisX.max = Math.max(0.5, Math.ceil(maxEfficiency * 1.2 * 10) / 10);
                                }
                            }
                        }
                    }
                }
            }
            
            // --- Traffic Violations Chart ---
            Rectangle {
                id: violationsChartContainer
                Layout.fillWidth: true
                Layout.preferredHeight: 400
                color: "#FFFFFF"
                radius: 12
                border.color: "#E0E0E0"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10
                    
                    Label {
                        text: "Driver Traffic Violations"
                        font.pixelSize: 20
                        font.bold: true
                        color: "#3C64B1"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    ChartView {
                        id: violationsChart
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        antialiasing: true
                        legend.visible: true
                        animationOptions: ChartView.SeriesAnimations
                        backgroundColor: "transparent"
                        margins.top: 0
                        margins.bottom: 5
                        margins.left: 5
                        margins.right: 5
                        
                        // Horizontal bar chart for violations comparison
                        HorizontalBarSeries {
                            id: violationsBarSeries
                            axisY: BarCategoryAxis {
                                id: violationsAxisY
                            }
                            axisX: ValueAxis {
                                id: violationsAxisX
                                min: 0
                                max: 10
                                tickCount: 11
                                labelFormat: "%d"
                                titleText: "Violations"
                                titleFont.pixelSize: 12
                                titleFont.bold: true
                                titleVisible: true
                                labelsFont.pixelSize: 10
                                labelsColor: "#666666"
                                gridLineColor: "#E0E0E0"
                                minorGridLineColor: "#F5F5F5"
                            }
                            
                            BarSet {
                                id: violationsBarSet
                                label: "Traffic Violations"
                                color: "#FF5252" // Red for violations
                                borderColor: "#E03C3C"
                                borderWidth: 1
                            }
                            
                            Component.onCompleted: {
                                if (tripStatsData && tripStatsData.length > 0) {
                                    // Create a map to store driver data
                                    var driverData = {};
                                    
                                    // Process trip data to get per-driver violations
                                    for (var i = 0; i < tripStatsData.length; i++) {
                                        var trip = tripStatsData[i];
                                        var driver = trip.driver || "Unknown";
                                        var violations = trip.trafficViolations || 0;
                                        
                                        // Initialize driver record if not exists
                                        if (!driverData[driver]) {
                                            driverData[driver] = {
                                                totalViolations: 0,
                                                tripCount: 0
                                            };
                                        }
                                        
                                        // Add this trip's data
                                        driverData[driver].totalViolations += violations;
                                        driverData[driver].tripCount++;
                                    }
                                    
                                    // Convert to arrays for the chart
                                    var driverNames = [];
                                    var violationsValues = [];
                                    var maxViolations = 0;
                                    
                                    for (var driverName in driverData) {
                                        var driverRecord = driverData[driverName];
                                        var totalViolations = driverRecord.totalViolations;
                                        
                                        // Highlight Luiza with an emoji
                                        if (driverName === "Luiza") {
                                            driverNames.push(driverName + " (" + driverRecord.tripCount + " trips) ⚠️");
                                        } else {
                                            driverNames.push(driverName + " (" + driverRecord.tripCount + " trips)");
                                        }
                                        violationsValues.push(totalViolations);
                                        
                                        if (totalViolations > maxViolations) {
                                            maxViolations = totalViolations;
                                        }
                                    }
                                    
                                    // Set the categories (driver names)
                                    violationsAxisY.categories = driverNames;
                                    
                                    // Set the values for the bar set
                                    violationsBarSet.values = violationsValues;
                                    
                                    // Add the bar set to the series
                                    if (!violationsBarSeries.count) {
                                        violationsBarSeries.append(violationsBarSet);
                                    }
                                    
                                    // Set the X axis max to a bit more than the maximum violations
                                    violationsAxisX.max = Math.max(5, Math.ceil(maxViolations * 1.1));
                                }
                            }
                        }
                    }
                }
            }
            
            // Add some spacing at the bottom
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 20
            }
        }
    }

    function formatDuration(minutes) {
        if (isNaN(minutes) || minutes < 0) return "0h 0m";
        var h = Math.floor(minutes / 60);
        var m = minutes % 60;
        return h + "h " + m + "m";
    }
}
