
//Posição inicial do mapa (Serra Talhada)
var map = L.map('map').setView([-7.987479, -38.291073], 14);

var tiles = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors',
}).addTo(map);

var addressPoints = [];
var markersFirst = [];
var markersSecond = [];
var markersThird = [];
var markersFourth = [];
var markersFifth = [];


function preencherHeatmap(lat, lng, sex, age, name, type ) {

    if (sex == 'M') {
        var sexo = "Masculino"
    }
    else if (sex == 'F') {
        var sexo = "Feminino"
    }
    else
        var sexo = "Outro"

    addressPoints.push([lat, lng, '1']);

    var marker = L.marker([lat, lng]);
    marker.bindPopup("NOME:"+ name +" | SEXO: " + sexo + " | IDADE: " + age);
    marker.addTo(map);

    if (type == 'first')
        markersFirst.push(marker);
    else if (type == 'second')
        markersSecond.push(marker);
    else if (type == 'third')
        markersThird.push(marker);
    else if (type == 'fourth')
        markersFourth.push(marker);
    else if (type == 'fifth')
        markersFifth.push(marker);
}

addressPoints = addressPoints.map(function (p) { return [p[0], p[1]]; });

var heat = L.heatLayer(addressPoints).addTo(map);

var actionHeat = true;

function addHeatPoints(type) {
    if (type == 1) {
        markersFirst.forEach((marker) => { marker.addTo(map) });
    }

    else if (type == 2) {
        markersSecond.forEach((marker) => { marker.addTo(map) });
    }

    else if (type == 3) {
        markersThird.forEach((marker) => { marker.addTo(map) });
    }

    else if (type == 4) {
        markersFourth.forEach((marker) => { marker.addTo(map) });
    }

    else if (type == 5) {
        markersFifth.forEach((marker) => { marker.addTo(map) });
    }
}

function removeHeatPoints(type) {
    if (type == 1) {
        markersFirst.forEach((marker) => { map.removeLayer(marker); });
    }

    else if (type == 2) {
        markersSecond.forEach((marker) => { map.removeLayer(marker); });
    }

    else if (type == 3) {
        markersThird.forEach((marker) => { map.removeLayer(marker); });
    }

    else if (type == 4) {
        markersFourth.forEach((marker) => { map.removeLayer(marker); });
    }

    else if (type == 5) {
        markersFifth.forEach((marker) => { map.removeLayer(marker); });
    }
}

function addRemoveHeatMap(){
    if(actionHeat){
        document.getElementById('addRemoveHeat').classList.remove('fa-check')
        map.removeLayer(heat)
        actionHeat = false;
    }
    else{
        document.getElementById('addRemoveHeat').classList.add('fa-check')
        heat.addTo(map);
        actionHeat = true;
    }
}

