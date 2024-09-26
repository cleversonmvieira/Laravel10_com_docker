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
