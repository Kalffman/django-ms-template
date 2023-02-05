# Simple variables/CONSTANTS
DB_CONTAINER_NAME := template-db
DB_NAME := template
DB_USER := template-user
DB_PASS := t3mp14t3
SKIP_DOT_ENV ?= true
ENV ?= LOCAL


# Scripts for check status of db container with docker
DB_CONTAINER_EXIST := $(if $(shell docker ps -aq -f name=$(DB_CONTAINER_NAME)),true,false)
DB_CONTAINER_RUNNING := $(if $(shell docker ps -aq -f name=$(DB_CONTAINER_NAME) -f status=running),true,false)
PSQL_CREATE_SCHEMAS:=psql -U $(PSQL_USER) -d $(PSQL_DB) -c "CREATE SCHEMA IF NOT EXISTS core;"


# All custom variables if you want to do things depending on OS 
ifeq ($(OS), Windows_NT)
PYENV_BIN := ./venv/Scripts # setting path for python venv for windows
COPY_DOT_ENV_COMMAND:=Copy ".env.example" ".env"
else
PYENV_BIN := ./venv/bin # setting path for python venv for linux/unix
COPY_DOT_ENV_COMMAND:=cp .env.example .env
endif


# Checking existence of custom files/folders with wildcard directive
ifneq ($(wildcard .env),)
DOT_ENV_EXIST:=true
else
DOT_ENV_EXIST:=false
endif


ifneq ($(wildcard ./venv/*),)
PYENV_EXIST:=true
else
PYENV_EXIST:=false
endif



# Goal to create virtual python environment using venv ( You can use as your preference :D *** check ln 17 & 20 for compatibilities)
pyenv:
ifeq ($(PYENV_EXIST), false)
	python -m venv venv
endif
ifeq ($(SKIP_DOT_ENV), false) # if you want to not generate .env type `SKIP_DOT_ENV=true` argument
ifeq ($(DOT_ENV_EXIST), false)
	$(COPY_DOT_ENV_COMMAND)
endif
endif



# setup of python dependencies after ran pyenv as prerequisite
python_dependencies: pyenv requirements.txt
	$(strip $(PYENV_BIN))/pip install -r requirements.txt



# Goal to create db container with docker (used mysql as eg)
db_container:
ifeq ($(DB_CONTAINER_EXIST), false)
# --- Creating postgres container ---
	docker run --name $(DB_CONTAINER_NAME) -p 5432:5432 -e MYSQL_PASSWORD=$(DB_PASS) -e POSTGRES_USER=$(DB_USER) -e POSTGRES_DB=$(DB_NAME) -d postgres:15
endif
ifeq ($(DB_CONTAINER_RUNNING), false)
# --- Starting postgres container ---
	docker start $(PSQL_CONTAINER_NAME)
endif



# Goal to apply django migrations
migrations:
	docker exec -it $(DB_CONTAINER_NAME) $(PSQL_CREATE_SCHEMAS)
	$(strip $(PYENV_BIN))/python manage.py makemigrations
	$(strip $(PYENV_BIN))/python manage.py migrate
	$(strip $(PYENV_BIN))/python manage.py migrate --database=core



# Easy goal to init local environment
environment: db_container python_dependencies migrations
ifeq ($(ENV), LOCAL)
	$(strip $(PYENV_BIN))/python manage.py createsuperuser --email user@template.com --username admin
endif