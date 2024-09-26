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


Passo 1: Criar o arquivo docker-compose.yml
O arquivo docker-compose.yml define os serviços Docker que serão utilizados no projeto. No caso, iremos configurar três containers: um para o aplicativo Laravel, um para o banco de dados MySQL e um para o phpMyAdmin (interface gráfica para o MySQL).

Crie o arquivo docker-compose.yml na raiz do seu projeto.
Adicione o seguinte conteúdo:
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

Explicações:

app: Define o container do Laravel, mapeando a porta 8000 do host para a porta 80 no container (onde o Apache servirá a aplicação).
mysql: Define o container do banco de dados MySQL, expondo a porta 3306 para conexão externa e configurando variáveis de ambiente com as credenciais do banco.
phpmyadmin: Configura o phpMyAdmin para gerenciar o MySQL via interface web, disponível na porta 8080.
volumes: Define volumes persistentes para que os dados do MySQL não sejam perdidos ao reiniciar os containers.
networks: Cria uma rede Docker onde todos os serviços podem se comunicar entre si.
