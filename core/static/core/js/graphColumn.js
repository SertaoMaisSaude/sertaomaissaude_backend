function setGraph(first, second, third, fourth) {
    google.charts.load("current", { packages: ['corechart'] });
    google.charts.setOnLoadCallback(drawChart);

    function drawChart() {
        var data = google.visualization.arrayToDataTable([
            ["Idade", "Quantidade", { role: "style" }],
            ["0 ~ 18", first, "#4e73df"],
            ["19 ~ 40 ", second, "#1cc88a"],
            ["41 ~ 60", third, "#f6c23e"],
            ["61 + ", fourth, "color: #e74a3b"]
        ]);

        var view = new google.visualization.DataView(data);
        view.setColumns([0, 1,
            {
                calc: "stringify",
                sourceColumn: 1,
                type: "string",
                role: "annotation"
            },
            2]);

        var options = {

            width: 550,
            height: 300,
            bar: { groupWidth: "95%" },
            legend: { position: 'none' },
        };
        var chart = new google.visualization.ColumnChart(document.getElementById("columnchart_values"));
        chart.draw(view, options);
    }
}

