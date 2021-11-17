FROM debian:bullseye AS builder

COPY indexdata-archive-keyring.gpg /usr/share/keyrings/

RUN apt-get update && apt-get --no-install-recommends -y install ca-certificates \
    && echo 'deb [signed-by=/usr/share/keyrings/indexdata-archive-keyring.gpg] https://ftp.indexdata.com/debian bullseye main' > /etc/apt/sources.list.d/indexdata.list \
    && apt-get update && apt-get --no-install-recommends -y install \
    ca-certificates \
    cpanminus \
    default-libmysqlclient-dev \
    gcc \
    gettext \
    git \
    libc6-dev \
    libexpat1-dev \
    libfribidi-dev \
    libgd-dev \
    libxslt1-dev \
    libyaz5-dev \
    make \
    perl \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ADD https://raw.githubusercontent.com/Koha-Community/Koha/master/cpanfile .

RUN export PERL_CPANM_OPT="--quiet --metacpan --notest --local-lib-contained /app/.local" \
    && cpanm --installdeps . \
    && cpanm JSON::Validator@3.14 Mojolicious::Plugin::OpenAPI@2.16 Mojolicious@8.12 IO::Scalar \
    && rm -rf /root/.cpanm

# Invalidate docker cache when there are new commits
ADD https://api.github.com/repos/Koha-Community/Koha/git/refs/heads/master version.json

RUN git clone --progress --depth 1 --branch master https://github.com/Koha-Community/Koha.git koha

FROM debian:bullseye

COPY indexdata-archive-keyring.gpg /usr/share/keyrings/

RUN apt-get update && apt-get --no-install-recommends -y install ca-certificates \
    && echo 'deb [signed-by=/usr/share/keyrings/indexdata-archive-keyring.gpg] https://ftp.indexdata.com/debian bullseye main' > /etc/apt/sources.list.d/indexdata.list \
    && apt-get update && apt-get --no-install-recommends -y install \
    fonts-dejavu \
    gettext \
    libexpat1 \
    libfribidi0 \
    libgd3 \
    libmariadb3 \
    libxslt1.1 \
    libyaz5 \
    perl \
    && rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos '' koha

USER koha

WORKDIR /home/koha

COPY --from=builder --chown=koha:koha /app .

COPY --chown=koha:koha koha-conf.xml.in log4perl.conf etc/

ENV KOHA_CONF /home/koha/etc/koha-conf.xml
ENV PERL5LIB /home/koha/koha/lib:/home/koha/koha:/home/koha/.local/lib/perl5
ENV PATH /home/koha/.local/bin:$PATH
ENV LANG C.UTF-8

EXPOSE 3000

COPY docker-entrypoint.sh /usr/local/bin/

WORKDIR /home/koha/koha
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["bin/intranet", "prefork"]
