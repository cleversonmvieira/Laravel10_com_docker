<h2>Tutorial: Configuração do Projeto Laravel com Docker e WSL 2</h2>

Este tutorial fornece instruções detalhadas sobre como configurar um projeto Laravel com Docker, incluindo Nginx e MySQL, utilizando o Windows Subsystem for Linux (WSL) 2. <br>

<h4>Pré-requisitos</h4><br>
1 - Docker e Docker Compose instalados no sistema.<br>
2 - Windows Subsystem for Linux (WSL) instalado (versão 2 recomendada).<br>
3 - Composer instalado no WSL.<br>

<h3>Habilitando WSL 2 no Windows</h3>

1) Execute o Windows PowerShell como administrador e habilite o WSL com os comandos abaixo: <br>
```sh
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

2) Ainda no Windows PowerShell, habilite o WSL para a versão 2 com o comando abaixo:
```sh
wsl --set-default-version 2
```

3) Acesse a Microsoft Store e instale o Ubuntu. <br>

4) Ainda na Microsoft Store, instale o Windows Terminal (recomendação). <br>

5) Crie um arquivo denominado .wslconfig em "C:\Users\<seu_usuario>". Este arquivo tem as configurações relacionadas à alocação de recursos para o ambiente WSL 2.  
```sh
[wsl2]
memory=4GB
processors=4
swap=2GB
```

6) Realize a instalação do docker.


<h3>Criando um projeto Laravel com Docker</h3>

<h4>Modo 1</h4>

1) Criar um novo projeto Laravel <br>

```sh
# Substitua "nomedoseuprojeto" pelo nome desejado
composer create-project --prefer-dist laravel/laravel nomedoseuprojeto
cd nomedoseuprojeto
```

2) Clonar os arquivos deste diretório (com o setup docker laravel) <br>

```sh
git clone https://github.com/cleversonmvieira/setup-docker-laravel.git
cd /setup-docker-laravel
```   

3) Copiar os arquivos do setup-docker-laravel para a raiz do projeto Laravel criado:
```sh
cp docker /nomedoseuprojeto
cp config /nomedoseuprojeto
cp site /nomedoseuprojeto
cp Dockerfile /nomedoseuprojeto
cp docker-compose.yml /nomedoseuprojeto
```

4) Construir e Iniciar os Contêineres Docker <br>
No terminal, execute os seguintes comandos na raiz do seu projeto: <br>

```sh
docker-compose build
docker-compose up
```

Este comando irá construir as imagens Docker e iniciar os contêineres em segundo plano.

5) Configurar o ambiente Laravel <br>
No terminal WSL, acesse o contêiner do aplicativo Laravel: <br>
```sh
docker-compose exec app bash
```

6) Dentro do contêiner, execute os seguintes comandos para configurar o ambiente Laravel: <br>
```sh
composer install
cp .env.example .env
php artisan key:generate
php artisan config:cache
php artisan migrate
exit
```

7) Acessar a aplicação Laravel</h3><br>
Abra seu navegador e acesse <a href="http://localhost" tarjet="_blank">http://localhost</a>. Você deverá ver a página inicial do seu projeto Laravel. <br>
