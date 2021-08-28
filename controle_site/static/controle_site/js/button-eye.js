function clickEye(){
    var input = document.getElementById("senha");

    var eye = document.getElementById("eye");
    

    if (input.type == "text"){
        input.type = "password";
        eye.name = 'eye-off'
    }

    else if (input.type == "password"){
        input.type = "text";
        eye.name = 'eye'
    }
}



function callModal(){
    
}