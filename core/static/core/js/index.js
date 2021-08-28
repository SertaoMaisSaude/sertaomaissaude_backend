    function mudarView(estado){
       var boletim = document.getElementById('rowBoletim');
       var historico = document.getElementById('rowHistorico');
       var mobile = document.getElementById('aplicacaoMobile');
      removeActive();
       if(estado=='boletim'){
         mobile.style.display = 'none';
         boletim.style.display = 'block';
         historico.style.display = 'block';
         document.getElementById('btnBoletim').classList.add('active');
       }
       else if(estado='mobile'){
        mobile.style.display = 'block';
        boletim.style.display = 'none';
        historico.style.display = 'none';
        document.getElementById('btnMobile').classList.add('active');
       }
    }

    function removeActive(){
      document.getElementById('btnMobile').classList.remove('active');
      document.getElementById('btnBoletim').classList.remove('active');
    }