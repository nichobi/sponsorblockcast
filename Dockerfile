FROM alpine:latest
ARG SPONSORBLOCKCAST_REPO=nichobi/sponsorblockcast
RUN apk -U add jq bc grep git go curl \
  && git clone https://github.com/vishen/go-chromecast \
  && cd go-chromecast \
  && latest_release=`curl https://api.github.com/repos/vishen/go-chromecast/tags | jq -r '.[0].name'` \
  && git pull origin $latest_release \
  && git checkout $latest_release \
  && go install \
  && cp ~/go/bin/go-chromecast /usr/bin/go-chromecast \
  && cd .. \
  && rm -rf go-chromecast \
  && git clone https://github.com/$SPONSORBLOCKCAST_REPO \
  && cp  sponsorblockcast/sponsorblockcast.sh /usr/bin/sponsorblockcast \
  && rm -rf sponsorblockcast \
  && chmod +x /usr/bin/sponsorblockcast \
  && chmod +x /usr/bin/go-chromecast \
  && apk del git go curl
ENV SBCPOLLINTERVAL 1
ENV SBCSCANINTERVAL 300
ENV SBCCATEGORIES sponsor
ENV SBCDIR /tmp/sponsorblockcast
LABEL Description="Container to run go-chromecast with some preset ENVs, run as net-mode host"
CMD /usr/bin/sponsorblockcast
