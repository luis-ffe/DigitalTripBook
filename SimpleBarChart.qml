import QtQuick 2.15
import QtCharts 2.15

ChartView {
    id: simpleBarChart
    property string title: "Bar Chart"
    signal updateRequested(var series, var axisX)

    backgroundColor: "transparent"
    
    BarSeries {
        id: internalBarSeries
        axisX: BarCategoryAxis { id: internalBarAxisX }
        axisY: ValueAxis { min: 0 }
    }

    function updateChart() {
        internalBarSeries.clear();
        updateRequested(internalBarSeries, internalBarAxisX);
    }
}
