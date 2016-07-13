#!/bin/sh

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

# Create the 'template_postgis' template db
"${psql[@]}" <<- 'EOSQL'
CREATE DATABASE template_postgis;
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template_postgis';
EOSQL

# Load PostGIS into both template_database and $POSTGRES_DB
for DB in template_postgis "$POSTGRES_DB"; do
	echo "Loading PostGIS extensions into $DB"
	"${psql[@]}" --dbname="$DB" <<-'EOSQL'
		CREATE EXTENSION IF NOT EXISTS postgis;
		CREATE EXTENSION IF NOT EXISTS postgis_topology;
		CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
		CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
EOSQL

# create database named gis for osm2pgsql
"${psql[@]}" <<- 'EOSQL'
DROP DATABASE IF EXISTS gis;
CREATE DATABASE gis;
EOSQL

"${psql[@]}" --dbname=gis <<- 'EOSQL'
CREATE EXTENSION postgis;
CREATE EXTENSION hstore;
EOSQL

# update config
"${psql[@]}" <<- 'EOSQL'
ALTER SYSTEM SET shared_buffers = '1024MB';
ALTER SYSTEM SET maintenance_work_mem = '256MB';
ALTER SYSTEM SET effective_cache_size = '2048MB';
ALTER SYSTEM SET autovacuum = 'off';
EOSQL

echo "Databases ready."
done