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
cp Dockerfile /nomedoseuprojeto
cp docker-compose.yml /nomedoseuprojeto
```

<h4>Modo 2</h4>

1) Criar um novo projeto Laravel <br>

```sh
# Substitua "nomedoseuprojeto" pelo nome desejado
composer create-project --prefer-dist laravel/laravel nomedoseuprojeto
cd nomedoseuprojeto
```

2) Criar os arquivos Docker <br>
Crie um arquivo chamado "Dockerfile" na raiz do seu projeto Laravel com o seguinte conteúdo: <br>

```sh
FROM php:8.1-fpm

# set your user name, ex: user=carlos
ARG user=yourusername
ARG uid=1000

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd sockets

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Install redis
RUN pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis

# Set working directory
WORKDIR /var/www

# Copy custom configurations PHP
COPY docker/php/custom.ini /usr/local/etc/php/conf.d/custom.ini

USER $user
```


3) Configurar o Docker Compose <br>
Crie um arquivo chamado "docker-compose.yml" na raiz do seu projeto Laravel: <br>
```sh
version: "3.7"

services:
    # image project
    app:
        build:
            context: .
            dockerfile: Dockerfile
        restart: unless-stopped
        working_dir: /var/www/
        volumes:
            - ./:/var/www
        depends_on:
            - redis
        networks:
            - laravel

    # nginx
    nginx:
        image: nginx:alpine
        restart: unless-stopped
        ports:
            - "8989:80"
        volumes:
            - ./:/var/www
            - ./docker/nginx/:/etc/nginx/conf.d/
        networks:
            - laravel

    # db mysql
    db:
        image: mysql:5.7.22
        restart: unless-stopped
        environment:
            MYSQL_DATABASE: ${DB_DATABASE:-laravel}
            MYSQL_ROOT_PASSWORD: ${DB_PASSWORD:-root}
            MYSQL_PASSWORD: ${DB_PASSWORD:-userpass}
            MYSQL_USER: ${DB_USERNAME:-username}
        volumes:
            - ./.docker/mysql/dbdata:/var/lib/mysql
        ports:
            - "3388:3306"
        networks:
            - laravel

    # redis
    redis:
        image: redis:latest
        networks:
            - laravel

networks:
    laravel:
        driver: bridge
```

4) Construir e Iniciar os Contêineres Docker <br>
No terminal, execute os seguintes comandos na raiz do seu projeto: <br>

```sh
docker-compose up -d --build
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
