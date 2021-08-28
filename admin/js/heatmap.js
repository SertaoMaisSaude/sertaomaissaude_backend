
//Posição inicial do mapa
var map = L.map('map').setView([-7.987479, -38.291073], 14);

var tiles = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors',
}).addTo(map);

addressPoints = addressPoints.map(function (p) { return [p[0], p[1]]; });

var heat = L.heatLayer(addressPoints).addTo(map);

var marker = L.marker([-7.990701, -38.295015]);
marker.bindPopup("<b>Possível ocorrência!");

var marker2 = L.marker([-7.991816, -38.296410]);
marker2.bindPopup("<b>Possível ocorrência!");

var actionPoint = true;
var actionHeat = false;

function addRemoveHeatPoints(){
    if(actionPoint){
        marker.addTo(map);
        marker2.addTo(map);
        actionPoint = false;
        document.getElementById('addRemovePoint').classList.add('fa-check');
    }
    else{
        map.removeLayer(marker);
        map.removeLayer(marker2);
        actionPoint = true;
        document.getElementById('addRemovePoint').classList.remove('fa-check');
    }
}

function addRemoveHeatMap(){
    if(actionHeat){
        heat.addTo(map);
        actionHeat = false;
        document.getElementById('addRemoveHeat').classList.add('fa-check');
    }
    else{
        map.removeLayer(heat);
        actionHeat = true;
        document.getElementById('addRemoveHeat').classList.remove('fa-check');
    }
}

