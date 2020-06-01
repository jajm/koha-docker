FROM debian:buster AS builder

RUN apt-get update && apt-get --no-install-recommends -y install \
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
    libyaz-dev \
    make \
    perl \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ADD https://raw.githubusercontent.com/Koha-Community/Koha/master/cpanfile .

RUN export PERL_CPANM_OPT="--quiet --metacpan --notest --local-lib-contained /app/.local" \
    && cpanm --installdeps . \
    && cpanm Starman \
    && rm -rf /root/.cpanm

# Invalidate docker cache when there are new commits
ADD https://api.github.com/repos/Koha-Community/Koha/git/refs/heads/master version.json

RUN git clone --progress --depth 1 --branch master https://github.com/Koha-Community/Koha.git koha

FROM debian:buster

RUN apt-get update && apt-get --no-install-recommends -y install \
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

COPY --chown=koha:koha koha-conf.xml.in etc/
COPY --chown=koha:koha app.psgi .

ENV KOHA_CONF /home/koha/etc/koha-conf.xml
ENV PERL5LIB /home/koha/koha:/home/koha/.local/lib/perl5
ENV PATH /home/koha/.local/bin:$PATH
ENV LANG C.UTF-8

EXPOSE 5000 5001

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["starman", "--listen", ":5000", "--listen", ":5001"]
