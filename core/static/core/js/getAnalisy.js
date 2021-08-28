var latitude = 0
var longitude = 0
var idade = 0
var sexo = ""

function getAnalisy(pk) {
    $.ajax({
        url: 'pages/analisy/get-analisy/',
        data: { "id": pk },
        dataType: 'json',

        success: function (data) {

            var name = document.getElementById("name");
            var age = document.getElementById("age");
            var phoneNumber = document.getElementById("phoneNumber");
            var gender = document.getElementById("gender");
            var faver = document.getElementById("faver");
            var covidContact = document.getElementById("covidContact");
            var ulRiskGroup = document.getElementById("ulRiskGroup");
            var ulSymptoms = document.getElementById("ulSymptoms");

            $("#ulRiskGroup").empty();
            $("#ulSymptoms").empty();
        
            name.innerHTML = data.citizen.name;
            age.innerHTML = data.citizen.age
            phoneNumber.innerHTML = data.citizen.phoneNumber
            gender.innerHTML = data.citizen.sex
            faver.innerHTML = data.faver
            covidContact.innerHTML = data.covidContact

            //Map
            latitude = data.lat;
            longitude = data.lng;
            idade = data.citizen.age;
            sexo = data.citizen.sex



            for (var i = 0 in data.risk_groups) {
                var newLiRiskGroup = document.createElement('li');
                var textoLiRiskGroup = document.createTextNode(data.risk_groups[i]);
                newLiRiskGroup.appendChild(textoLiRiskGroup);

                ulRiskGroup.append(newLiRiskGroup);
            }

            for (var j = 0 in data.symptoms) {
                var newLiSymptoms = document.createElement('li');
                var textoLiSymptoms = document.createTextNode(data.symptoms[j]);
                newLiSymptoms.appendChild(textoLiSymptoms);

                ulSymptoms.append(newLiSymptoms);
            }


        }
    });
    switchCard('profile')
}


function switchCard(card){
    var profile = document.getElementById('profile');
    var location = document.getElementById('location');
    var btnProfile = document.getElementById('btnProfile');
    var btnLocation = document.getElementById('btnLocation');
    if (card == "profile"){
        btnProfile.style.opacity = '100%';
        btnLocation.style.opacity = '50%';

        location.style.display = "none";
        profile.style.display = "block";
    }

    else if (card == "location"){
        btnProfile.style.opacity = '50%';
        btnLocation.style.opacity = '100%';
        profile.style.display = "none";
        location.style.display = "block";
        if(latitude!=null && longitude !=null)
            preencherHeatmap(latitude,longitude, sexo, idade);
    }

}