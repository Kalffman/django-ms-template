# Simple variables/CONSTANTS
DB_CONTAINER_NAME := template-db
DB_NAME := template
DB_USER := template-user
DB_PASS := t3mp14t3
SKIP_DOT_ENV ?= false


# Scripts for check status of db container with docker
DB_CONTAINER_EXIST := $(if $(shell docker ps -aq -f name=$(DB_CONTAINER_NAME)),true,false)
DB_CONTAINER_RUNNING := $(if $(shell docker ps -aq -f name=$(DB_CONTAINER_NAME) -f status=running),true,false)


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


# Goal to create virtual python environment using venv ( You can use as your preference :D *** check lno 15 & 19 for compatibilities)
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
python_dependencies: pyenv
	$(strip $(PYENV_BIN))/pip install -r requirements.txt


# Goal to create db container with docker (used mysql as eg)
db_container:
ifeq ($(DB_CONTAINER_EXIST), false)
# --- Creating psql_db container ---
	docker run --name $(DB_CONTAINER_NAME) -p 3306:3306 -e MYSQL_PASSWORD=$(DB_PASS) -e MYSQL_USER=$(DB_USER) -e MYSQL_DATABASE=$(DB_NAME) -e MYSQL_ROOT_PASSWORD=root -d mysql:8
endif
ifeq ($(PSQL_CONTAINER_RUNNING), false)
# --- Starting psql_db container ---
	docker start $(PSQL_CONTAINER_NAME)
endif



# Goal to apply django migrations
migrations:
	$(PYENV_BIN)/python manage.py makemigrations
	$(PYENV_BIN)/python manage.py migrate


# Easy goal to init develoment environment
local_environment: db_container python_dependencies