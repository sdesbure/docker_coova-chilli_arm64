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
  net-tools \
  python \
  libpcap-dev \
  libnetfilter-queue1 \
  libnetfilter-queue-dev \
  curl \
  supervisor

# COOVA PART
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

# patch redir.c to make it accept fonts file types
ADD  mimetypes.patch .
RUN patch -p1 < mimetypes.patch

# create package
RUN debuild -us -uc -b

# install package
RUN dpkg -i ../coova-chilli_*.deb

EXPOSE 3990 4990

COPY defaults /etc/chilli
COPY start_chilli.sh /usr/bin

# Wombat PART
# Retrieve nodejs 6.2.2
WORKDIR /src
RUN curl https://nodejs.org/dist/v6.2.2/node-v6.2.2-linux-arm64.tar.xz | tar -Jx
ENV PATH=/src/node-v6.2.2-linux-arm64/bin:${PATH}

# Retrieve Wombat
COPY Wombat.tar.xz /src
RUN tar -Jxf Wombat.tar.xz
WORKDIR /src/Wombat
RUN npm install
RUN mkdir -p logs && touch logs/wombat.log

VOLUME /config

# Configure supervisord
COPY supervisor.conf /etc/supervisor/supervisord.conf
COPY *.sv.conf /etc/supervisor/conf.d/

# clean
RUN apt-get purge -y git build-essential libtool autoconf automake gengetopt devscripts debhelper && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


ENTRYPOINT ["/usr/bin/supervisord"]
