<h2>Tutorial: Configuração do Projeto Laravel 10 com Docker e WSL</h2>

Este tutorial fornece instruções detalhadas sobre como configurar um projeto Laravel 10 com Docker, incluindo Nginx, PHPMyAdmin e MySQL, utilizando o Windows Subsystem for Linux (WSL). <br>

<h4>Pré-requisitos</h4><br>
Docker e Docker Compose instalados no sistema.<br>
Windows Subsystem for Linux (WSL) instalado (versão 2 recomendada).<br>
Composer instalado no WSL.<br>

<h3>Passo 1: Criar um novo projeto Laravel</h3>

<pre>
# Substitua "nomedoseuprojeto" pelo nome desejado
composer create-project --prefer-dist laravel/laravel nomedoseuprojeto
cd nomedoseuprojeto
</pre>


<h3>Passo 2: Criar os arquivos Docker</h3><br>
Crie um arquivo chamado "Dockerfile" na raiz do seu projeto Laravel:

<pre>
# Use a imagem oficial do PHP com FPM
FROM php:8.2-fpm

# Instale as dependências necessárias
RUN apt-get update && \
    apt-get install -y \
        nginx \
        git \
        unzip \
        libpq-dev \
        libzip-dev \
        && docker-php-ext-install pdo pdo_mysql pdo_pgsql zip

# Configurar o servidor Nginx
COPY nginx/default /etc/nginx/sites-available/default
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Configurar o ponto de entrada do Docker
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# Definir o diretório de trabalho
WORKDIR /var/www/html

# Copiar o código do aplicativo para o contêiner
COPY . /var/www/html

# Instalar as dependências do Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --no-scripts --no-autoloader && \
    composer dump-autoload --optimize

# Expor a porta 80
EXPOSE 80

# Comando de inicialização
CMD ["php-fpm"]
</pre>


Arquivos Nginx <br>

Crie uma pasta chamada nginx na raiz do seu projeto Laravel e adicione os arquivos default e nginx.conf:<br>

nginx/default:

<pre>
server {
    listen 80;
    index index.php index.html;
    server_name localhost;
    root /var/www/html/public;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
</pre>

nginx/nginx.conf:

<pre>
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 768;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
</pre>


<h3>Passo 3: Configurar o Docker Compose</h3><br>
Crie um arquivo chamado "docker-compose.yml" na raiz do seu projeto Laravel:

<pre>
version: '3'
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    image: laravel10_app
    container_name: laravel10_app
    restart: unless-stopped
    volumes:
      - .:/var/www/html
    networks:
      - laravel10_network
    depends_on:
      - db
  db:
    image: mysql:5.7
    container_name: laravel10_db
    restart: unless-stopped
    environment:
      MYSQL_DATABASE: laravel10
      MYSQL_USER: laravel10_user
      MYSQL_PASSWORD: laravel10_password
      MYSQL_ROOT_PASSWORD: root_password
    networks:
      - laravel10_network
  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: laravel10_phpmyadmin
    restart: unless-stopped
    environment:
      PMA_HOST: db
      MYSQL_ROOT_PASSWORD: root_password
    ports:
      - "8080:80"
    networks:
      - laravel10_network
networks:
  laravel10_network:
    driver: bridge
</pre>

<h3>Passo 4: Criar o arquivo de entrada Docker</h3><br>
Crie um arquivo chamado docker-entrypoint.sh na raiz do seu projeto Laravel:

<pre>
#!/bin/bash

set -e

# Configurar as permissões
chmod -R 775 storage bootstrap/cache

# Executar o comando de entrada padrão do Laravel
exec "$@"
</pre>

Passo 5: Construir e Iniciar os Contêineres Docker
No terminal, execute os seguintes comandos na raiz do seu projeto:

<pre>
docker-compose up -d --build
</pre>

Este comando irá construir as imagens Docker e iniciar os contêineres em segundo plano.

<h3>Passo 6: Configurar o ambiente Laravel</h3><br>
No terminal WSL, acesse o contêiner do aplicativo Laravel:

<pre>
docker-compose exec app bash
</pre>

Dentro do contêiner, execute os seguintes comandos para configurar o ambiente Laravel:<br>

<pre>
cp .env.example .env
php artisan key:generate
php artisan config:cache
php artisan migrate
exit
</pre>

<h3>Passo 7: Acessar o Aplicativo Laravel</h3><br>
Abra seu navegador e acesse <a href="http://localhost" tarjet="_blank">http://localhost</a>. Você deverá ver a página inicial do seu projeto Laravel.

<h3>Passo 8: Acessar o PHPMyAdmin</h3><br>
Abra seu navegador e acesse <a href="http://localhost:8080" tarjet="_blank">http://localhost:8080</a>. Use as credenciais definidas no arquivo docker-compose.yml para fazer login no PHPMyAdmin.

<br>

Agora você configurou com sucesso um ambiente Docker para o seu projeto Laravel 10, incluindo Nginx, PHPMyAdmin e MySQL, usando o Windows Subsystem for Linux (WSL). Certifique-se de adaptar as configurações de acordo com suas necessidades específicas.
