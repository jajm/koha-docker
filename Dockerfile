ARG PERL_TAG=latest

FROM perl:${PERL_TAG}

RUN apt-get update && apt-get install -y \
    fonts-dejavu \
    gettext \
    libfribidi-dev \
    libgd-dev \
    libyaz-dev \
    && rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos '' koha

USER koha

WORKDIR /home/koha

ARG KOHA_VERSION=master
ARG KOHA_REPOSITORY=https://github.com/Koha-Community/Koha.git

RUN git clone --progress --depth 1 --branch ${KOHA_VERSION} ${KOHA_REPOSITORY} koha

COPY --chown=koha:koha generate-cpanfile.pl ./

RUN perl /home/koha/generate-cpanfile.pl \
    && export PERL_CPANM_OPT="--quiet --metacpan --notest --local-lib-contained /home/koha/.local" \
    && cpanm Module::Install \
    && cpanm --installdeps /home/koha/koha \
    && cpanm Starman \
    && rm -f /home/koha/generate-cpanfile.pl \
    && rm -rf /home/koha/.cpanm

COPY --chown=koha:koha etc ./etc/
COPY --chown=koha:koha koha.psgi ./

ENV KOHA_CONF /home/koha/etc/koha-conf.xml
ENV PERL5LIB /home/koha/koha:/home/koha/.local/lib/perl5
ENV PATH /home/koha/.local/bin:$PATH

EXPOSE 5000 5001

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["starman", "--listen", ":5000", "--listen", ":5001", "koha.psgi"]
