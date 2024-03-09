Configuração do Laravel 10 com Docker
Este projeto fornece um guia passo a passo para executar um projeto Laravel 10 usando o Docker.

Começando
1. Clone o Projeto
git clone https://github.com/cleversonmvieira/Laravel10_com_docker.git laravel-10
cd laravel-10/

2. Crie o Arquivo .env
Faça uma cópia do arquivo .env.example para criar o arquivo .env.
cp .env.example .env

3. Atualize as Variáveis de Ambiente
Abra o arquivo .env e atualize as seguintes variáveis de ambiente:
APP_NAME="Laravel 10 com Docker"
APP_URL=http://localhost

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=nome_desejado_db
DB_USERNAME=nome_usuario
DB_PASSWORD=senha_aqui

CACHE_DRIVER=redis
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis

REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379

4. Inicie os Containers do Projeto
Execute o seguinte comando para iniciar os containers do projeto:
docker-compose up -d

5. Acesse o Container do Projeto
Acesse o container do projeto usando o seguinte comando:
docker-compose exec app bash

6. Instale as Dependências do Projeto
Dentro do container, instale as dependências do projeto usando o Composer:
composer install

7. Gere a Chave do Projeto Laravel
Gere a chave do projeto Laravel com o seguinte comando:
php artisan key:generate

8. Acesse o Projeto no Navegador
Abra seu navegador e acesse:
http://localhost
