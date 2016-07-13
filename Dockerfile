FROM postgres:9.5
MAINTAINER Mike Dillon <mike@appropriate.io>

ENV POSTGIS_MAJOR 2.2
ENV POSTGIS_VERSION 2.2.2+dfsg-4.pgdg80+1

RUN apt-get update \
      && apt-get install -y --no-install-recommends wget \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
           postgis=$POSTGIS_VERSION \
      && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/postgis.sh