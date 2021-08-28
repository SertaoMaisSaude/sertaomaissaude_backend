
    //Posição inicial do mapa
    var map = L.map('map').setView([-7.987479, -38.291073], 14);

    var tiles = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors',
    }).addTo(map);

    addressPoints = addressPoints.map(function (p) { return [p[0], p[1]]; });

    var heat = L.heatLayer(addressPoints).addTo(map);