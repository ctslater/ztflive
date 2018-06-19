# Stage 1 - Compile elm, elm scripts to static javascript.
FROM node:9.11
WORKDIR /opt

RUN npm install elm

COPY elm-package.json *.elm ./

# /opt/node_modules/.bin
#run $(npm bin)/elm-package install --yes elm-lang/http
run $(npm bin)/elm-make --yes ZtfLive.elm --output static/elm.js

COPY static/elm.js static/

# Stage 2 - Compile uwsgi to host the site.
FROM python:3.6-slim
LABEL maintainer "ctslater@uw.edu"
WORKDIR /opt

# gcc is required to compile uwsgi
# Need /etc/mime.types for serving static files from uwsgi
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y gcc mime-support

COPY . .

RUN pip install --no-cache-dir -r requirements.txt

# Not sure about this part
RUN groupadd -r uwsgi_grp && useradd -r -g uwsgi_grp uwsgi
RUN chown -R uwsgi:uwsgi_grp /opt
USER uwsgi

EXPOSE 8000
CMD uwsgi --env REDIS_HOST=$REDIS_HOST uwsgi.ini
