FROM openjdk:8-jre

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.10
RUN set -x \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true


# https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-repositories.html
# https://www.elastic.co/guide/en/elasticsearch/reference/5.0/deb.html

ENV ELASTICSEARCH_VERSION 2.4.1
ENV ELASTICSEARCH_DEB_VERSION 2.4.1

RUN set -x \
	\
# don't allow the package to install its sysctl file (causes the install to fail)
# Failed to write '262144' to '/proc/sys/vm/max_map_count': Read-only file system
	&& dpkg-divert --rename /usr/lib/sysctl.d/elasticsearch.conf \
	\
	&& apt-get update \
	&& apt-get install -y --no-install-recommends wget curl \
	&& rm -rf /var/lib/apt/lists/* \
	&& wget https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/2.4.1/elasticsearch-2.4.1.deb \
	&& dpkg -i elasticsearch-2.4.1.deb

ENV PATH /usr/share/elasticsearch/bin:$PATH

WORKDIR /usr/share/elasticsearch

RUN set -ex \
	&& for path in \
		./data \
		./logs \
		./config \
		./config/scripts \
	; do \
		mkdir -p "$path"; \
		chown -R elasticsearch:elasticsearch "$path"; \
	done
RUN wget https://github.com/eiblog/eiblog/archive/master.zip \
    && unzip master.zip \
    && cd eiblog-master/conf/es \
    && cp -r ./config /usr/share/elasticsearch/config \
    && cp -r ./plugins /usr/share/elasticsearch/plugins


VOLUME /usr/share/elasticsearch/data

COPY docker-entrypoint.sh /

EXPOSE 9200 9300
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["elasticsearch"]
