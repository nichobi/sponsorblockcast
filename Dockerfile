FROM alpine:latest

# Add the BuildKit global arch args to get the correct go-chromecast release
# go-chromecast package linux architectures: linux_386, linux_amd64, linux_arm64, linux_armv6, linux_armv7
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

RUN apk --no-cache add jq bc grep curl \
  && GC_URL=`wget https://api.github.com/repos/vishen/go-chromecast/releases/latest -O - | jq -r '.assets[].browser_download_url' | grep ${TARGETOS}_${TARGETARCH}${TARGETVARIANT}` \
  && wget $GC_URL -O /root/go-chromecast.tgz \
  && tar xzf /root/go-chromecast.tgz -C /usr/bin \
  && rm -rf /root/* \
  && chmod +x /usr/bin/go-chromecast

ENV SBCPOLLINTERVAL 1
ENV SBCSCANINTERVAL 300
ENV SBCCATEGORIES sponsor
ENV SBCDIR /tmp/sponsorblockcast
LABEL Description="Container to run go-chromecast with some preset ENVs, run as net-mode host"

ADD sponsorblockcast.sh /usr/bin/sponsorblockcast

CMD /usr/bin/sponsorblockcast
