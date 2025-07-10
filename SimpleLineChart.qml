import QtQuick 2.15
import QtCharts 2.15

ChartView {
    id: simpleLineChart
    property string title: "Line Chart"
    signal updateRequested(var series, var axisX)

    backgroundColor: "transparent"
    
    LineSeries {
        id: internalLineSeries
        axisX: ValueAxis { id: valueAxisX }
        axisY: ValueAxis { min: 0 }
    }

    function updateChart() {
        internalLineSeries.clear();
        updateRequested(internalLineSeries, valueAxisX);
    }
}
