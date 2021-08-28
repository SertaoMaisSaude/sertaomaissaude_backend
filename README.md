Executando Projeto DJANGO

Dependencies:

    - python 3.7+
    - virtualenv

Create a virtual environment:

    - virtualenv virtual -p python3.7

Active your virtual environment:

    - source virtual/bin/activate

Clone Project: outside ot the folder virtual

    - git clone git@github.com:marcostark/COVID-19-ST-Backend.git

Install requeriments in folder project:

    - pip install -r requeriments.txt
 
Run:

    - python manage.py runserver   
    or specify IP:port
    - python manage.py runserver 0.0.0.0:8080

 


#### Documentação do template utlizado para Dashboard

Você pode obter detalhes acerca do SB Admin, tema utilizado para criação do dashboard através da documentação oficial, [clique aqui](https://startbootstrap.com/themes/sb-admin-2/) para mais informações.


##HAUSRA

O Hasura é um framework de conexão com Banco de dados Postgres que utiliza o Docker como ferramenta para instalação e 
utilização.

1. [Instale o Docker](https://www.digitalocean.com/community/tutorials/como-instalar-e-usar-o-docker-no-ubuntu-18-04-pt)
1. [Instale o Docker-compsoe](https://www.digitalocean.com/community/tutorials/how-to-install-docker-compose-on-ubuntu-18-04-pt)
2. [Documentação do Hasura](https://hasura.io/docs/1.0/graphql/manual/index.html)

####Executando o Hasura

1. Faça uma cópia do arquivo .env.example e edite com as informações do banco de dados e a senha para o painel do hasura.
2. Execute o comando `docker-compose up -d` para executa-lo em segundo plano na porta 9008.


######Dicas de comandos

1. Comandos Docker
    -  `docker-compose up -d` executa o projeto no modo daemon
    -  `docker-compose up` executa o projeto em foreground
    -  `docker-compose down` derruba o servidor
    -  `docekr-compose down -v` derruba o servidor e apaga os dados salvos
    -  `docker system prune -a` apaga todas as imagens e arquivos do computador
