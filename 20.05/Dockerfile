FROM debian:buster

RUN apt-get update && apt-get --no-install-recommends -y install \
    ca-certificates \
    cpanminus \
    default-libmysqlclient-dev \
    fonts-dejavu \
    gcc \
    gettext \
    git \
    libc6-dev \
    libexpat1-dev \
    libfribidi-dev \
    libgd-dev \
    libxslt1-dev \
    libyaz-dev \
    make \
    perl \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos '' koha

USER koha

WORKDIR /home/koha

ADD --chown=koha:koha https://raw.githubusercontent.com/Koha-Community/Koha/v20.05.18/cpanfile .

ENV PERL_CPANM_OPT --local-lib-contained /home/koha/.local
RUN export PERL_CPANM_OPT="--quiet --metacpan --notest $PERL_CPANM_OPT" \
    && cpanm --installdeps . \
    && cpanm JSON::Validator@0.97 Mojolicious::Plugin::OpenAPI@1.15 Mojolicious@7.21 \
    && cpanm Starman \
    && rm -rf /home/koha/.cpanm


RUN git clone --progress --depth 1 --branch v20.05.18 https://github.com/Koha-Community/Koha.git koha

COPY --chown=koha:koha koha-conf.xml.in log4perl.conf etc/
COPY --chown=koha:koha intranet.psgi opac.psgi ./

ENV KOHA_CONF /home/koha/etc/koha-conf.xml
ENV PERL5LIB /home/koha/koha:/home/koha/.local/lib/perl5
ENV PATH /home/koha/.local/bin:$PATH
ENV LANG C.UTF-8

EXPOSE 3000

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["starman", "--listen", ":3000", "intranet.psgi"]
