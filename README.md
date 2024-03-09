<h2>Configuração do Laravel 10 com Docker</h2>
Este projeto fornece um guia passo a passo para executar um projeto Laravel 10 usando o Docker. <br><br>

1. Clone o Projeto
<pre>
git clone https://github.com/cleversonmvieira/Laravel10_com_docker.git laravel-10
cd laravel-10/
</pre>

3. Crie o Arquivo .env <br>
Faça uma cópia do arquivo .env.example para criar o arquivo .env.
<pre>
cp .env.example .env
</pre>

4. Atualize as Variáveis de Ambiente <br>
Abra o arquivo .env e atualize as seguintes variáveis de ambiente:
<pre>
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
</pre>

4. Inicie os Containers do Projeto <br>
Execute o seguinte comando para iniciar os containers do projeto:
<pre>
docker-compose up -d
</pre>

5. Acesse o Container do Projeto <br>
Acesse o container do projeto usando o seguinte comando:
<pre>
docker-compose exec app bash
</pre>

6. Instale as Dependências do Projeto <br>
Dentro do container, instale as dependências do projeto usando o Composer:
<pre>
composer install
</pre>

7. Gere a Chave do Projeto Laravel <br>
Gere a chave do projeto Laravel com o seguinte comando:
<pre>
php artisan key:generate
</pre>

8. Acesse o Projeto no Navegador <br>
Abra seu navegador e acesse:
<pre>
http://localhost
</pre>
