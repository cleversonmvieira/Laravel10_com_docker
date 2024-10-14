# Laravel com Docker, PHP 8.3, MySQL e phpMyAdmin

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
├── nginx/
|    └── default.conf
└── app/
    └── (código do Laravel será instalado aqui)
```

## Passo 1: Criar o arquivo docker-compose.yml
O arquivo docker-compose.yml define os serviços Docker que serão utilizados no projeto. No caso, iremos configurar três containers: um para o aplicativo Laravel, um para o banco de dados MySQL e um para o phpMyAdmin (interface gráfica para o MySQL).

Crie o arquivo docker-compose.yml na raiz do seu projeto.
Adicione o seguinte conteúdo:

```yaml
# version: '3.8'

services:
  # Serviço do PHP-FPM para rodar o Laravel
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: laravel_app
    restart: unless-stopped
    working_dir: /var/www/html
    volumes:
      - ./app:/var/www/html
    environment:
      - DB_HOST=mysql
      - DB_PORT=3306
      - DB_DATABASE=laravel
      - DB_USERNAME=user_laravel
      - DB_PASSWORD=password_laravel
    networks:
      - laravel_network

  # Serviço Nginx para servir a aplicação Laravel
  nginx:
    image: nginx:alpine
    container_name: nginx
    restart: unless-stopped
    ports:
      - "8080:80"
    volumes:
      - ./app:/var/www/html
      - ./nginx:/etc/nginx/conf.d
    depends_on:
      - app
    networks:
      - laravel_network

  # Banco de dados MySQL
  mysql:
    image: mysql:8.0
    container_name: mysql
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: password_laravel
      MYSQL_DATABASE: laravel
      MYSQL_USER: user_laravel
      MYSQL_PASSWORD: password_laravel
    ports:
      - "3306:3306"
    volumes:
      - dbdata:/var/lib/mysql
    networks:
      - laravel_network

  # Interface do PHPMyAdmin
  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: phpmyadmin_
    restart: unless-stopped
    environment:
      PMA_HOST: mysql
      # Nome de usuário do banco que o PhpMyAdmin utilizará para se conectar.
      PMA_USER: user_laravel
      # Senha do usuário do banco de dados para o acesso via PhpMyAdmin.
      PMA_PASSWORD: password_laravel
      MYSQL_ROOT_PASSWORD: password_laravel
    ports:
      - "8081:80"
    depends_on:
      - mysql
    networks:
      - laravel_network

# Rede personalizada
networks:
  laravel_network:
    driver: bridge

# Volume para armazenar dados do banco de dados
volumes:
  dbdata:
```

Explicações:

- `app`: Define o container do Laravel, mapeando a porta 8080 do host para a porta 80 no container (onde o nginx servirá a aplicação).
- `mysql`: Define o container do banco de dados MySQL, expondo a porta 3306 para conexão externa e configurando variáveis de ambiente com as credenciais do banco.
- `phpmyadmin`: Configura o phpMyAdmin para gerenciar o MySQL via interface web, disponível na porta 8081.
- `volumes`: Define volumes persistentes para que os dados do MySQL não sejam perdidos ao reiniciar os containers.
- `networks`: Cria uma rede Docker onde todos os serviços podem se comunicar entre si.


## Passo 2: Criar o arquivo Dockerfile para PHP e Laravel
O Dockerfile define a configuração do ambiente PHP 8.3 que será usado para rodar o Laravel.

Crie um arquivo chamado Dockerfile na raiz do projeto.
Adicione o seguinte conteúdo:

```php
# Dockerfile
FROM php:8.3-fpm

# Instala extensões necessárias
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl

# Instala extensões PHP
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configura diretório de trabalho
WORKDIR /var/www/html

# Copia os arquivos da aplicação
COPY . /var/www/html

# Ajustar permissões
#RUN chown -R www-data:www-data /var/www/html \
#    && chmod -R 755 /var/www/html/storage \
#    && chmod -R 755 /var/www/html/bootstrap/cache

EXPOSE 9000

CMD ["php-fpm"]

```

Explicações:

- `php:8.3-apache`: Imagem base com PHP 8.3 e Apache pré-instalados.
- `RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl`: Instala as bibliotecas necessárias, como libzip (para ZIP), curl, git, etc...
- `RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip`: Instala extensões PHP.
- `COPY --from=composer:latest /usr/bin/composer /usr/bin/composer`: Instala o Composer.
- `WORKDIR`: Define o diretório /var/www/html como o local de trabalho no container.
- `COPY . /var/www/html`: Copia os arquicos da aplicação.


Inicie os containers com o Docker Compose:
```bash
docker-compose up -d
```

Com os containers rodando, entre no container da aplicação:
```bash
docker exec -it laravel_app bash
```

Dentro do container, instale o Laravel usando o Composer:
```bash
composer create-project --prefer-dist laravel/laravel .
```

Após instalar o Laravel, gere a chave da aplicação:
```bash
php artisan key:generate
```

Rode as migrates para criar as tabelas do banco de dados
```bash
php artisan migrate
```

Ajuste as permissões:
```bash
chmod -R 777 storage bootstrap/cache
```

## Passo 3: Configurar o arquivo .env do Laravel
Após instalar o Laravel (veja o Passo 3), você precisa configurar o arquivo .env para conectar ao banco de dados MySQL.

Abra o arquivo .env dentro do diretório Laravel (será gerado no próximo passo).
Modifique as seguintes linhas para ajustar as credenciais do MySQL:

```env
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=root
DB_PASSWORD=root
```

Explicações:

- `DB_CONNECTION`: Define o tipo de banco de dados (MySQL neste caso).
- `DB_HOST`: O nome do serviço MySQL, que no Docker é simplesmente mysql (conforme definido no docker-compose.yml).
- `DB_PORT`: A porta padrão do MySQL.
- `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`: Correspondem às variáveis configuradas no serviço MySQL no docker-compose.yml.


## Passo 4: Acessar o Laravel e phpMyAdmin
Com todos os containers rodando e o Laravel instalado, agora você pode acessar a aplicação e o phpMyAdmin.

- Laravel: Acesse http://localhost:8080 no navegador.
- phpMyAdmin: Acesse http://localhost:8081 para gerenciar o banco de dados.

Explicações:

- O Laravel estará disponível na porta 8080, conforme mapeado no `docker-compose.yml`.
- O phpMyAdmin estará disponível na porta 8081, permitindo o gerenciamento visual do banco de dados MySQL.
