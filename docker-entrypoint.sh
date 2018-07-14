#!/bin/bash

set -e

# Add elasticsearch as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- elasticsearch "$@"
fi

# Drop root privileges if we are running elasticsearch
# allow the container to be started with `--user`
if [ "$1" = 'elasticsearch' -a "$(id -u)" = '0' ]; then
	# Change the ownership of user-mutable directories to elasticsearch
	for path in \
		/usr/share/elasticsearch/data \
		/usr/share/elasticsearch/logs \
	; do
		chown -R elasticsearch:elasticsearch "$path"
	done
	
	set -- gosu elasticsearch "$@"
	#exec gosu elasticsearch "$BASH_SOURCE" "$@"
fi
 echo -e -n "http.port: ">> /usr/share/elasticsearch/config/elasticsearch.yml

echo -e -n $PORT >> /usr/share/elasticsearch/config/elasticsearch.yml

echo -e -n - >> /usr/share/elasticsearch/config/elasticsearch.yml

echo -e -n $PORT >> /usr/share/elasticsearch/config/elasticsearch.yml
# As argument is not related to elasticsearch,
# then assume that user wants to run his own process,
# for example a `bash` shell to explore this image
/usr/share/elasticsearch/bin/elasticsearch --E http.port=$PORT
