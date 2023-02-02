FROM python:bullseye

ENV DEBUG = 'false'
ENV DB_NAME = ''
ENV DB_USER = ''
ENV DB_PASS = ''
ENV DB_HOST = ''
ENV DB_PORT = ''
ENV SECRET_KEY = ''
ARG ENV

WORKDIR /usr/src/temp

COPY requiriments.txt .

RUN pip install --upgrade pip
RUN pip install -r ./requiriments.txt
RUN SECRET_KEY=${SECRET_KEY:-$(cat /proc/sys/kernel/random/uuid)}

WORKDIR /usr/src/app

EXPOSE 8000

ENTRYPOINT [ "gunicorn", "core.wsgi" ]