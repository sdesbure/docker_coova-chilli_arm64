FROM bogdanpurcareata/arm64-ubuntu
MAINTAINER Sylvain Desbureaux <sylvain@desbureaux.fr>

RUN apt-get update && apt-get install -y \
  git \
  build-essential \
  libtool \
  autoconf \
  automake \
  gengetopt \
  devscripts \
  debhelper \
  libssl-dev \
  iptables \
  net-tools

# grep last version of haserl
WORKDIR /src
RUN wget http://downloads.sourceforge.net/project/haserl/haserl-devel/haserl-0.9.35.tar.gz

RUN tar zxvf haserl-0.9.35.tar.gz
WORKDIR /src/haserl-0.9.35

RUN ./configure --prefix=/usr && make && make install

# grep git version of coova-chilli
RUN git clone --depth 2 https://github.com/coova/coova-chilli.git /src/coova-chilli

WORKDIR /src/coova-chilli

# remove haserl dependency as it's not well installed
RUN sed -e 's/, haserl//' -i debian/control

# create package
RUN debuild -us -uc -b

# install package
RUN dpkg -i ../coova-chilli_*.deb

# clean
RUN apt-get purge -y git build-essential libtool autoconf automake gengetopt devscripts debhelper && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 3990 4990

COPY defaults /etc/chilli
COPY start_chilli.sh /usr/bin

VOLUME /config

ENTRYPOINT ["/usr/bin/start_chilli.sh"]
CMD ["--local", "/config/local.conf", "--default", "/config/defaults", "--prescript", "/config/prescript.sh", "--upscript", "/config/up.sh"]
