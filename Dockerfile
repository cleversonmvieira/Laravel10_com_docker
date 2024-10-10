# Usar a imagem oficial do PHP 8.3 com Apache.
# Esta imagem já vem pré-configurada com PHP e Apache, simplificando o setup para rodar aplicações web.
FROM php:8.3-apache

# Instalar extensões PHP necessárias para o Laravel.
# O Laravel depende do PDO para conexões com bancos de dados, e o MySQL é um banco comum.
# As extensões são instaladas usando o comando 'docker-php-ext-install'.
RUN docker-php-ext-install pdo pdo_mysql

# Habilitar o mod_rewrite do Apache para suporte a URLs amigáveis, necessário para o Laravel.
# O mod_headers também é habilitado para permitir a manipulação de cabeçalhos HTTP.
RUN a2enmod rewrite
RUN a2enmod headers

# Configurar variáveis de ambiente relacionadas ao ambiente de execução da aplicação.
# 'APP_ENV=production' garante que estamos em produção.
# 'APP_DEBUG=false' desabilita a exibição de erros detalhados, e 'APP_LOG_LEVEL=warning' limita os logs a avisos ou mais graves.
ENV APP_ENV=production
ENV APP_DEBUG=false
ENV APP_LOG_LEVEL=warning

# Configurar limites para upload de arquivos para evitar ataques de negação de serviço (DoS) via arquivos grandes.
# 'upload_max_filesize' define o tamanho máximo permitido para uploads.
# 'post_max_size' define o tamanho máximo de dados que podem ser enviados em uma requisição POST.
RUN echo "upload_max_filesize=10M" > /usr/local/etc/php/conf.d/uploads.ini && \
    echo "post_max_size=12M" >> /usr/local/etc/php/conf.d/uploads.ini

# Desabilitar a listagem de diretórios no Apache para melhorar a segurança, impedindo o acesso direto a diretórios.
RUN echo "Options -Indexes" >> /etc/apache2/apache2.conf

# Copiar os arquivos da aplicação Laravel para o diretório padrão do Apache.
# O Laravel estará localizado em '/var/www/html', que é o DocumentRoot padrão no Apache.
COPY laravel/ /var/www/html/

# Definir permissões corretas para o diretório da aplicação.
# O usuário e grupo 'www-data' são padrões do Apache, e devem ter propriedade dos arquivos para garantir que o servidor web tenha acesso apropriado.
RUN chown -R www-data:www-data /var/www/html

# Ajustar permissões de segurança para limitar o acesso indevido a arquivos:
# Arquivos terão permissões de leitura (644) e diretórios terão permissões de execução e leitura (755).
RUN find /var/www/html -type f -exec chmod 644 {} \; && \
    find /var/www/html -type d -exec chmod 755 {} \;

# Proteger o arquivo .env, que contém informações sensíveis, como credenciais e chaves de API.
# Usamos uma diretiva do Apache para bloquear o acesso a este arquivo pelo navegador.
# RUN echo "<FilesMatch \"^\.env$\">\n    Require all denied\n</FilesMatch>" >> /etc/apache2/apache2.conf

# Copiar um arquivo de configuração personalizada do Apache para ajustar o DocumentRoot e outras diretivas.
# Isso garante que o Apache esteja configurado corretamente para servir a aplicação Laravel.
COPY ./apache-laravel.conf /etc/apache2/sites-available/000-default.conf

# Expor a porta 80, que é a porta padrão do Apache para servir a aplicação web.
EXPOSE 80

# Iniciar o Apache no primeiro plano (modo foreground) para que o contêiner continue rodando.
CMD ["apache2-foreground"]
