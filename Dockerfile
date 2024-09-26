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
