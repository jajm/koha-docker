# Docker files for Koha

Simple `Dockerfile`s to run Koha.

## Quick start

### Using docker-compose

```
cd master && docker-compose up
```

Then go to http://localhost:3000 to run the install process.  OPAC is
accessible at http://localhost:3001

### Using docker

```
docker network create koha

docker run -d --name elasticsearch --network koha \
    -e discovery.type=single-node koha/elasticsearch-icu:6.x

docker run -d --name memcached --network koha memcached

docker run -d --name db --network koha \
    -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=koha \
    -e MYSQL_USER=koha -e MYSQL_PASSWORD=koha mariadb

docker build --tag koha:master master
docker run -d --name koha-intranet --network koha -p 3000:3000 koha:master
docker run -d --name koha-opac --network koha -p 3001:3000 koha:master bin/opac prefork
```

Then go to http://localhost:3000 to run the install process.  OPAC is
accessible at http://localhost:3001

### Enable elasticsearch and rebuild index

For the search to work, two additional steps are required:

1. Set syspref `SearchEngine` to `Elasticsearch`
2. `docker exec koha-intranet perl misc/search_tools/rebuild_elasticsearch.pl -d`

The name of the container (`koha-intranet`) might differ if you used docker-compose

## Environment variables

### `MYSQL_HOST`

MySQL hostname.

Default is `db`.

### `MYSQL_PORT`

MySQL port.

Default is `3306`.

### `MYSQL_DATABASE`

MySQL database name.

Default is `koha`.

### `MYSQL_USER`

MySQL user.

Default is `koha`.

### `MYSQL_PASSWORD`

MySQL password.

Default is `koha`.

### `MEMCACHED_SERVER`

Memcached server URL.

Default is `memcached:11211`

### `MEMCACHED_NAMESPACE`

Memcached namespace

Default is `KOHA`

### `ELASTICSEARCH_SERVER`

Elasticsearch server URL.

Default is `elasticsearch:9200`

### `ELASTICSEARCH_INDEX_NAME`

Elasticsearch index name.

Default is `koha`

## Complete usage example

```
docker build --tag koha:master master

docker run -d \
    -e MYSQL_HOST=mariadb \
    -e MYSQL_PORT=3307 \
    -e MYSQL_DATABASE=koha_master \
    -e MYSQL_USER=koha_master \
    -e MYSQL_PASSWORD=Secr3t! \
    -e MEMCACHED_SERVER=memcached:22122 \
    -e MEMCACHED_NAMESPACE=koha_master
    -e ELASTICSEARCH_SERVER=elasticsearch6:9200 \
    -e ELASTICSEARCH_INDEX_NAME=koha_master
    --name koha-intranet --network koha -p 3000:3000 koha:master

docker run -d \
    -e MYSQL_HOST=mariadb \
    -e MYSQL_PORT=3307 \
    -e MYSQL_DATABASE=koha_master \
    -e MYSQL_USER=koha_master \
    -e MYSQL_PASSWORD=Secr3t! \
    -e MEMCACHED_SERVER=memcached:22122 \
    -e MEMCACHED_NAMESPACE=koha_master
    -e ELASTICSEARCH_SERVER=elasticsearch6:9200 \
    -e ELASTICSEARCH_INDEX_NAME=koha_master
    --name koha-opac --network koha -p 3001:3000 koha:master bin/opac prefork
```
