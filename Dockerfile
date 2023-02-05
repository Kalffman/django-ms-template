FROM python:bullseye

ENV DEBUG = 'false'
ENV DB_NAME = ''
ENV DB_USER = ''
ENV DB_PASS = ''
ENV DB_HOST = ''
ENV DB_PORT = ''
ENV SECRET_KEY = ''
ARG ENV

WORKDIR /usr/src/app

COPY . .

RUN pip install --upgrade pip && \
    pip install -r ./requiriments.txt

RUN SECRET_KEY=${SECRET_KEY:-$(cat /proc/sys/kernel/random/uuid)}

EXPOSE 8000

ENTRYPOINT [ "gunicorn", "core.wsgi" ]