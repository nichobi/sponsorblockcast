FROM alpine:latest
ARG GC_BUILD=linux_amd64
ADD sponsorblockcast.sh /usr/bin/sponsorblockcast
RUN apk -U add jq bc grep \
  && GC_URL=`wget https://api.github.com/repos/vishen/go-chromecast/releases/latest -O - | jq -r '.assets[].browser_download_url' | grep $GC_BUILD` \
  && wget $GC_URL -O /root/go-chromecast.tgz \
  && tar xzf /root/go-chromecast.tgz -C /usr/bin \
  && chmod +x /usr/bin/sponsorblockcast \
  && chmod +x /usr/bin/go-chromecast \
  && rm -rf /var/cache/apk/* /lib/apk/db/* /root/*
ENV SBCPOLLINTERVAL 1
ENV SBCSCANINTERVAL 300
ENV SBCCATEGORIES sponsor
ENV SBCDIR /tmp/sponsorblockcast
LABEL Description="Container to run go-chromecast with some preset ENVs, run as net-mode host"
CMD /usr/bin/sponsorblockcast
