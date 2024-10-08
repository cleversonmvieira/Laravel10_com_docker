# Usar a imagem oficial do PHP 8.3 com Apache
# A imagem já inclui Apache e PHP, garantindo um ambiente pronto para rodar aplicações web
FROM php:8.3-apache

# Instalar extensões necessárias para o Laravel, como suporte a PDO e MySQL
# Isso é importante para que o Laravel possa se conectar ao banco de dados
RUN docker-php-ext-install pdo pdo_mysql

# Habilitar o mod_rewrite do Apache, que é necessário para a manipulação de URLs amigáveis no Laravel
RUN a2enmod rewrite

# Configurar variáveis de ambiente para limitar a exposição de erros em produção
# Isso ajuda a evitar que informações sensíveis sejam exibidas caso ocorram erros
ENV APP_ENV=production
ENV APP_DEBUG=false
ENV APP_LOG_LEVEL=warning

# Configurar o limite de upload para evitar ataques de negação de serviço (DOS) via arquivos grandes
# Ajuste conforme a necessidade da sua aplicação
RUN echo "upload_max_filesize=10M" > /usr/local/etc/php/conf.d/uploads.ini && \
    echo "post_max_size=12M" >> /usr/local/etc/php/conf.d/uploads.ini

# Desabilitar listagem de diretórios no Apache, o que melhora a segurança ao impedir o acesso direto a arquivos
RUN echo "Options -Indexes" >> /etc/apache2/apache2.conf

# Copiar os arquivos da aplicação para o diretório padrão do Apache
# As permissões são importantes para garantir que o servidor web possa ler os arquivos corretamente
COPY laravel/ /var/www/html/

# Definir as permissões corretas para o diretório da aplicação
# O usuário e grupo 'www-data' são padrões do Apache e devem ter propriedade dos arquivos da aplicação
RUN chown -R www-data:www-data /var/www/html

# Ajustar permissões de segurança adicionais:
# Conceder permissões de leitura (644) para arquivos e de execução (755) para diretórios
# Isso limita as permissões para evitar acesso indevido a arquivos sensíveis
RUN find /var/www/html -type f -exec chmod 644 {} \; && \
    find /var/www/html -type d -exec chmod 755 {} \;

# Proteger arquivos sensíveis no Laravel, como .env, para evitar que sejam acessados diretamente pelo navegador
RUN echo "<FilesMatch \"^\.env$\">\n    Require all denied\n</FilesMatch>" >> /etc/apache2/apache2.conf

# Copiar o arquivo de configuração personalizada do Apache para configurar o DocumentRoot e outras diretivas do Apache
COPY ./apache-laravel.conf /etc/apache2/sites-available/000-default.conf

# Ativar cabeçalhos de segurança no Apache para mitigar ataques comuns, como XSS e clickjacking
RUN echo "Header set X-Content-Type-Options: nosniff" >> /etc/apache2/apache2.conf && \
    echo "Header always append X-Frame-Options SAMEORIGIN" >> /etc/apache2/apache2.conf && \
    echo "Header set X-XSS-Protection \"1; mode=block\"" >> /etc/apache2/apache2.conf
