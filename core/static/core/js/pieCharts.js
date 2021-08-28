// Set new default font family and font color to mimic Bootstrap's default styling
Chart.defaults.global.defaultFontFamily = 'Nunito', '-apple-system,system-ui,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,sans-serif';
Chart.defaults.global.defaultFontColor = '#858796';

function number_format(number, decimals, dec_point, thousands_sep) {
  // *     example: number_format(1234.56, 2, ',', ' ');
  // *     return: '1 234,56'
  number = (number + '').replace(',', '').replace(' ', '');
  var n = !isFinite(+number) ? 0 : +number,
    prec = !isFinite(+decimals) ? 0 : Math.abs(decimals),
    sep = (typeof thousands_sep === 'undefined') ? ',' : thousands_sep,
    dec = (typeof dec_point === 'undefined') ? '.' : dec_point,
    s = '',
    toFixedFix = function (n, prec) {
      var k = Math.pow(10, prec);
      return '' + Math.round(n * k) / k;
    };
  // Fix for IE parseFloat(0.55).toFixed(0) = 0;
  s = (prec ? toFixedFix(n, prec) : '' + Math.round(n)).split('.');
  if (s[0].length > 3) {
    s[0] = s[0].replace(/\B(?=(?:\d{3})+(?!\d))/g, sep);
  }
  if ((s[1] || '').length < prec) {
    s[1] = s[1] || '';
    s[1] += new Array(prec - s[1].length + 1).join('0');
  }
  return s.join(dec);
}


// Pie Chart Example

function preencherPie(valores) {
  var ctx = document.getElementById("myPieChart");
  var myPieChart = new Chart(ctx, {
    type: 'doughnut',
    data: {
      labels: ['Confirmados', 'Óbitos'],
      datasets: [{
        data: valores,
        backgroundColor: ['#4e73df', '#ff0000'],
        hoverBackgroundColor: ['#2e59d9', '#17a673', '#2c9faf'],
        hoverBorderColor: "rgba(234, 236, 244, 1)",
      }],
    },
    options: {
      maintainAspectRatio: false,
      tooltips: {
        backgroundColor: "rgb(255,255,255)",
        bodyFontColor: "#858796",
        borderColor: '#dddfeb',
        borderWidth: 1,
        xPadding: 15,
        yPadding: 15,
        displayColors: false,
        callbacks: {
          label: function (tooltipItem, data) {
            // get the data label and data value to display
            // convert the data value to local string so it uses a comma seperated number
            var dataLabel = data.labels[tooltipItem.index];
            var value = ': ' + data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toLocaleString();

            // make this isn't a multi-line label (e.g. [["label 1 - line 1, "line 2, ], [etc...]])
            if (Chart.helpers.isArray(dataLabel)) {
              // show value on first line of multiline label
              // need to clone because we are changing the value
              dataLabel = dataLabel.slice();
              dataLabel[0] += value;
            } else {
              dataLabel += value;
            }

            // return the text to display on the tooltip
            return dataLabel;
          }
        },
        caretPadding: 10,
      },


      legend: {
        display: true,
        position: 'bottom',
        labels: {
          boxWidth: 20,
          padding: 20
        }
      },
      cutoutPercentage: 80,
    },
  });
}

var myPieChart2;

function preencherPie2(legendas, valores) {
  // Pie Chart 
  var ctx2 = document.getElementById("myPieChart2");
  myPieChart2 = new Chart(ctx2, {
    type: 'pie',
    data: {
      labels: legendas,
      datasets: [{
        data: valores,
        backgroundColor: ['#E9967A', '#FFA500', '#FF0000', '#FF1493', '#B03060', '#EE82EE',
          '#4876FF', '#0000FF', '#63B8FF', '#43CD80', '#00FF00'],
        hoverBackgroundColor: ['#E9967A', '#FFA500', '#FF0000', '#FF1493', '#B03060', '#EE82EE',
        '#4876FF', '#0000FF', '#63B8FF', '#43CD80', '#00FF00'],
        hoverBorderColor: "#e3e6f0",
      }],
    },
    options: {
      pieceLabel: {
        render: 'label',
        arc: true,
        fontColor: '#000',
        position: 'outside'
      },
      maintainAspectRatio: false,
      tooltips: {
        backgroundColor: "rgb(255,255,255)",
        bodyFontColor: "#858796",
        borderColor: '#dddfeb',
        borderWidth: 1,
        xPadding: 15,
        yPadding: 15,
        displayColors: false,
        callbacks: {
          label: function (tooltipItem, data) {
            // get the data label and data value to display
            // convert the data value to local string so it uses a comma seperated number
            var dataLabel = data.labels[tooltipItem.index];
            var value = ': ' + data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].toLocaleString();

            // make this isn't a multi-line label (e.g. [["label 1 - line 1, "line 2, ], [etc...]])
            if (Chart.helpers.isArray(dataLabel)) {
              // show value on first line of multiline label
              // need to clone because we are changing the value
              dataLabel = dataLabel.slice();
              dataLabel[0] += value;
            } else {
              dataLabel += value;
            }

            // return the text to display on the tooltip
            return dataLabel;
          }
        },
        caretPadding: 10,
      },


      legend: {
        display: false,
        position: 'bottom',
        labels: {
          boxWidth: 20,
          padding: 20
        }

      },



      cutoutPercentage: 80,

    },
  });
}

var labels = [];
var values = [];
var first_risk = true;
var second_risk = true;
var third_risk = true;
var fourth_risk = true;
var fifth_risk = true;

function adicionarLabelsPie2(label, value, type) {
  
  // if (labels.length > 0) {
    for (let index = 0; index < labels.length; index++) {
      if (label == labels[index]) {
        values[index] += value;
        return;
      }
      else if (label != labels[index] && index == labels.length-1) {
        labels.push(label);
        values.push(value);
        return;
      }
    }
  
  if(labels.length==0) {
    labels.push(label);
    values.push(value);
  }
}

function removeValuesPie2(label, value){
  for (let index = 0; index < labels.length; index++) {
    if (label == labels[index]) {
      values[index] -= value;
      return;
    }
  }
}

function addValuesPie2(label, value){
  for (let index = 0; index < labels.length; index++) {
    if (label == labels[index]) {
      values[index] += value;
      return;
    }
  }
}