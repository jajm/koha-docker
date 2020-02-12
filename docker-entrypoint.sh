#!/bin/sh

export MYSQL_HOST=${MYSQL_HOST:-db}
export MYSQL_PORT=${MYSQL_PORT:-3306}
export MYSQL_DATABASE=${MYSQL_DATABASE:-koha}
export MYSQL_USER=${MYSQL_USER:-koha}
export MYSQL_PASSWORD=${MYSQL_PASSWORD:-koha}
export MEMCACHED_SERVER=${MEMCACHED_SERVER:-memcached:11211}
export MEMCACHED_NAMESPACE=${MEMCACHED_NAMESPACE:-KOHA}
export ELASTICSEARCH_SERVER=${ELASTICSEARCH_SERVER:-elasticsearch:9200}
export ELASTICSEARCH_INDEX_NAME=${ELASTICSEARCH_INDEX_NAME:-koha}

KOHA_CONF_IN="$KOHA_CONF.in"
if [ -r "$KOHA_CONF_IN" ]; then
    envsubst < "$KOHA_CONF_IN" > "$KOHA_CONF" \
        && rm -f "$KOHA_CONF_IN"
fi

exec "$@"
