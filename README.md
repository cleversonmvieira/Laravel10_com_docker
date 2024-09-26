# Laravel 11 com Docker, PHP 8.3, MySQL e phpMyAdmin

Este repositório contém um exemplo de configuração de um ambiente de desenvolvimento com Laravel 11 utilizando Docker, PHP 8.3, MySQL e phpMyAdmin. Abaixo está o passo a passo detalhado para criar e configurar o projeto.

## Pré-requisitos

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [DBeaver](https://dbeaver.io/) (opcional, para acessar o banco de dados MySQL)

## Estrutura do Projeto

```plaintext
project-root/
│
├── docker-compose.yml
├── Dockerfile
├── .env
├── laravel/
│   └── (código do Laravel será instalado aqui)
└── phpmyadmin/
    └── Dockerfile (opcional para customização do phpMyAdmin)
```

## Passo 1: Criar o arquivo docker-compose.yml
O arquivo docker-compose.yml define os serviços Docker que serão utilizados no projeto. No caso, iremos configurar três containers: um para o aplicativo Laravel, um para o banco de dados MySQL e um para o phpMyAdmin (interface gráfica para o MySQL).

Crie o arquivo docker-compose.yml na raiz do seu projeto.
Adicione o seguinte conteúdo:

```yaml

version: '3.8' # Define a versão do docker-compose a ser utilizada

services:
  # Serviço do PHP com Laravel
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: laravel_app
    volumes:
      - ./laravel:/var/www/html  # Mapeia o diretório local para o container
    ports:
      - "8000:80"  # Porta exposta para acessar o Laravel localmente
    networks:
      - laravel_network
    depends_on:
      - mysql

  # Serviço do MySQL
  mysql:
    image: mysql:8.0 # Usando a imagem oficial do MySQL
    container_name: laravel_mysql
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword  # Define a senha do root do MySQL
      MYSQL_DATABASE: laravel_db         # Cria um banco de dados ao iniciar o container
      MYSQL_USER: laravel_user           # Define o usuário do MySQL
      MYSQL_PASSWORD: laravel_password   # Define a senha do usuário
    volumes:
      - mysql_data:/var/lib/mysql  # Volume persistente para os dados do MySQL
    ports:
      - "3306:3306"  # Porta exposta para acesso ao MySQL
    networks:
      - laravel_network

  # Serviço do phpMyAdmin
  phpmyadmin:
    image: phpmyadmin/phpmyadmin # Usando a imagem oficial do phpMyAdmin
    container_name: laravel_phpmyadmin
    environment:
      PMA_HOST: mysql # Conecta ao serviço MySQL pelo nome do container
      MYSQL_ROOT_PASSWORD: rootpassword
    ports:
      - "8080:80"  # Porta exposta para acessar o phpMyAdmin
    depends_on:
      - mysql
    networks:
      - laravel_network

# Definindo volumes persistentes
volumes:
  mysql_data:

# Definindo uma rede personalizada para os containers
networks:
  laravel_network:

```

Explicações:

- `app`: Define o container do Laravel, mapeando a porta 8000 do host para a porta 80 no container (onde o Apache servirá a aplicação).
- `mysql`: Define o container do banco de dados MySQL, expondo a porta 3306 para conexão externa e configurando variáveis de ambiente com as credenciais do banco.
- `phpmyadmin`: Configura o phpMyAdmin para gerenciar o MySQL via interface web, disponível na porta 8080.
- `volumes`: Define volumes persistentes para que os dados do MySQL não sejam perdidos ao reiniciar os containers.
- `networks`: Cria uma rede Docker onde todos os serviços podem se comunicar entre si.


## Passo 2: Criar o arquivo Dockerfile para PHP e Laravel
O Dockerfile define a configuração do ambiente PHP 8.3 que será usado para rodar o Laravel.

Crie um arquivo chamado Dockerfile na raiz do projeto.
Adicione o seguinte conteúdo:
```php
# Usando a imagem base oficial do PHP 8.3 com Apache
FROM php:8.3-apache

# Instalando extensões necessárias para o Laravel
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    git \
    && docker-php-ext-install zip pdo pdo_mysql

# Instalando Composer globalmente
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Configurando o diretório de trabalho
WORKDIR /var/www/html

# Habilitando mod_rewrite no Apache para que o Laravel funcione corretamente
RUN a2enmod rewrite
```

Explicações:

php:8.3-apache: Imagem base com PHP 8.3 e Apache pré-instalados.
RUN apt-get update ...: Instala as bibliotecas necessárias, como libzip (para ZIP), pdo_mysql (para MySQL) e Git.
COPY --from=composer:2: Copia o Composer diretamente da imagem oficial do Composer, facilitando a instalação de dependências do Laravel.
WORKDIR: Define o diretório /var/www/html como o local de trabalho no container.
a2enmod rewrite: Habilita o módulo mod_rewrite do Apache, necessário para o Laravel funcionar corretamente.

## Passo 3: Instalar o Laravel
Agora que o ambiente Docker está configurado, você precisa instalar o Laravel no diretório laravel dentro do projeto.

Inicie os containers com o Docker Compose:
```bash
docker-compose up -d
```
Entre no container app:
```bash
docker-compose exec app bash
```
Dentro do container, instale o Laravel utilizando o Composer:
```bash
composer create-project --prefer-dist laravel/laravel nomedoprojeto
```
Saia do container:
```bash
exit
```

Explicações:

O comando docker-compose up -d inicia os serviços em segundo plano.
O composer create-project instala o Laravel na versão mais recente dentro do diretório /var/www/html, que está mapeado para o diretório ./laravel no seu sistema local.

## Passo 4: Configurar o arquivo .env do Laravel
Após instalar o Laravel (veja o Passo 4), você precisa configurar o arquivo .env para conectar ao banco de dados MySQL.

Abra o arquivo .env dentro do diretório Laravel (será gerado no próximo passo).
Modifique as seguintes linhas para ajustar as credenciais do MySQL:

```env
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=laravel_db
DB_USERNAME=laravel_user
DB_PASSWORD=laravel_password
```
