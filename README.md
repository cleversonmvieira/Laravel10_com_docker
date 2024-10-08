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
├── apache-laravel.conf
├── docker-compose.yml
├── Dockerfile
└── laravel/
    └── (código do Laravel será instalado aqui)
```

## Passo 1: Criar o arquivo docker-compose.yml
O arquivo docker-compose.yml define os serviços Docker que serão utilizados no projeto. No caso, iremos configurar três containers: um para o aplicativo Laravel, um para o banco de dados MySQL e um para o phpMyAdmin (interface gráfica para o MySQL).

Crie o arquivo docker-compose.yml na raiz do seu projeto.
Adicione o seguinte conteúdo:

```yaml

# Define a versão do Docker Compose que está sendo usada
# A versão 3.8 é uma das versões mais recentes e estável
# que traz compatibilidade com várias funcionalidades.
#version: '3.8'

services:
  # Definição do serviço 'app', que representa a aplicação Laravel
  app:
    # A aplicação será construída com base no Dockerfile localizado na raiz do projeto (indicado pelo '.')
    build: .
    
    # Mapeamento de portas do contêiner para o host
    # A porta 8000 no host será mapeada para a porta 80 do contêiner, permitindo acessar o app via http://localhost:8000
    ports:
      - "8000:80"
    
    # Volume compartilhado entre o host e o contêiner
    # A pasta local 'laravel' será mapeada para '/var/www/html' dentro do contêiner
    # Isso permite que alterações no código no host sejam refletidas instantaneamente no contêiner
    volumes:
      - ./laravel:/var/www/html
    
    # Conectando o serviço 'app' à rede interna 'app-network', para se comunicar com outros serviços
    networks:
      - app-network

  # Definição do serviço 'db', que representa o banco de dados MySQL
  db:
    # A imagem do MySQL será baixada automaticamente com base na última versão disponível ('mysql:latest')
    image: mysql:latest
    
    # Configuração de variáveis de ambiente para o contêiner MySQL
    # Estes valores são usados para criar o banco de dados e configurar o acesso
    environment:
      # Senha do usuário root do MySQL
      MYSQL_ROOT_PASSWORD: root_password
      # Nome do banco de dados a ser criado automaticamente
      MYSQL_DATABASE: laravel
      # Nome de usuário a ser criado automaticamente para o banco
      MYSQL_USER: user_laravel
      # Senha do usuário que será criado para o banco
      MYSQL_PASSWORD: password_laravel
    
    # Mapeamento da porta 3306 do contêiner (porta padrão do MySQL) para a mesma porta no host
    # Permite que você se conecte ao MySQL no contêiner via localhost:3306
    ports:
      - "3306:3306"
    
    # Conectando o serviço 'db' à rede interna 'app-network', para que a aplicação possa se comunicar com o banco de dados
    networks:
      - app-network

  # Definição do serviço 'phpmyadmin', que fornece uma interface gráfica para gerenciar o banco de dados MySQL
  phpmyadmin:
    # A imagem do PhpMyAdmin será baixada automaticamente
    image: phpmyadmin/phpmyadmin
    
    # Configuração das variáveis de ambiente para o PhpMyAdmin
    environment:
      # Nome do host (serviço) onde o MySQL está rodando. Neste caso, o serviço 'db' dentro da rede do Docker.
      PMA_HOST: db
      # Nome de usuário do banco de dados que o PhpMyAdmin usará para se conectar (mesmo usuário criado para o MySQL)
      PMA_USER: user_laravel
      # Senha do usuário para acessar o banco de dados
      PMA_PASSWORD: password_laravel
    
    # Mapeamento da porta 8080 no host para a porta 80 do contêiner, permitindo acessar o PhpMyAdmin via http://localhost:8080
    ports:
      - "8080:80"
    
    # Conectando o serviço 'phpmyadmin' à rede interna 'app-network', para que ele possa se comunicar com o banco de dados MySQL
    networks:
      - app-network

# Definição da rede interna 'app-network' usada para comunicação entre os contêineres
networks:
  app-network:
    # Usando o driver 'bridge', que cria uma rede isolada para permitir a comunicação entre os serviços Docker
    driver: bridge


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
COPY app/ /var/www/html/

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

```

Explicações:

- `php:8.3-apache`: Imagem base com PHP 8.3 e Apache pré-instalados.
- `RUN apt-get update ...`: Instala as bibliotecas necessárias, como libzip (para ZIP), pdo_mysql (para MySQL) e Git.
- `COPY --from=composer:2`: Copia o Composer diretamente da imagem oficial do Composer, facilitando a instalação de dependências do Laravel.
- `WORKDIR`: Define o diretório /var/www/html como o local de trabalho no container.
- `a2enmod rewrite`: Habilita o módulo mod_rewrite do Apache, necessário para o Laravel funcionar corretamente.

## Passo 3: Instalar o Laravel
Agora que o ambiente Docker está configurado, você precisa instalar o Laravel no diretório `laravel` dentro do projeto.

Instale o Laravel utilizando o Composer:
```bash
composer create-project --prefer-dist laravel/laravel laravel
```

Entre no diretório do laravel e crie a chave
```bash
cd laravel
php artisan key:generate
```

Rode as migrates para criar as tabelas do banco de dados
```bash
php artisan migrate
```

Inicie os containers com o Docker Compose:
```bash
docker-compose up -d
```

Explicações:

- O `composer create-project` instala o Laravel na versão mais recente dentro do diretório `/var/www/html`, que está mapeado para o diretório `./laravel` no seu sistema local.
- - O comando `docker-compose up -d` inicia os serviços em segundo plano.

## Passo 4: Configurar o arquivo .env do Laravel
Após instalar o Laravel (veja o Passo 3), você precisa configurar o arquivo .env para conectar ao banco de dados MySQL.

Abra o arquivo .env dentro do diretório Laravel (será gerado no próximo passo).
Modifique as seguintes linhas para ajustar as credenciais do MySQL:

```env
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=user_laravel
DB_PASSWORD=password_laravel
```

Explicações:

- `DB_CONNECTION`: Define o tipo de banco de dados (MySQL neste caso).
- `DB_HOST`: O nome do serviço MySQL, que no Docker é simplesmente mysql (conforme definido no docker-compose.yml).
- `DB_PORT`: A porta padrão do MySQL.
- `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`: Correspondem às variáveis configuradas no serviço MySQL no docker-compose.yml.


## Passo 5: Acessar o Laravel e phpMyAdmin
Com todos os containers rodando e o Laravel instalado, agora você pode acessar a aplicação e o phpMyAdmin.

- Laravel: Acesse http://localhost:8000 no navegador.
- phpMyAdmin: Acesse http://localhost:8080 para gerenciar o banco de dados.

Credenciais do phpMyAdmin:

- Servidor: mysql
- Usuário: laravel_user
- Senha: laravel_password

Explicações:

- O Laravel estará disponível na porta 8000, conforme mapeado no `docker-compose.yml`.
- O phpMyAdmin estará disponível na porta 8080, permitindo o gerenciamento visual do banco de dados MySQL.
