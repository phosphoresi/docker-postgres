	FROM postgres:11

RUN apt-get update && apt-get -yq install curl sudo daemontools  pv python2-pip lzop && python2 -m pip install wal-e[swift] \
    && apt-get autoclean

ENV WALG_VERSION="v0.2.14"
ADD pgbkp.sh /sudokeys/

RUN ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime && dpkg-reconfigure -f noninteractive tzdata
RUN localedef -i fr_FR -c -f UTF-8 -A /usr/share/locale/locale.alias fr_FR.UTF-8



RUN cd /usr/local/bin && curl -L https://github.com/wal-g/wal-g/releases/download/$WALG_VERSION/wal-g.linux-amd64.tar.gz | tar xzf -
