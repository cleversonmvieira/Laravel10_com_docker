# Usar a imagem oficial do PHP 8.3
FROM php:8.3-apache

# Instalar as extensões necessárias
RUN docker-php-ext-install pdo pdo_mysql

# Habilitar o mod_rewrite
RUN a2enmod rewrite

# Copiar os arquivos da aplicação para o diretório padrão do Apache
COPY app/ /var/www/html/

# Definir as permissões corretas
RUN chown -R www-data:www-data /var/www/html
