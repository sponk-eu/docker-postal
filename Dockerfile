FROM ruby:2.6-rc-alpine

RUN wget https://github.com/wrouesnel/p2cli/releases/download/r5/p2 -O /usr/local/bin/p2 \
        && chmod +x /usr/local/bin/p2

RUN apk --no-cache add nodejs mariadb-client git bash libcap build-base mariadb-dev tzdata \
        && git clone https://github.com/atech/postal.git /opt/postal \
	&& rm -rf /var/lib/apt/lists/* \
	&& gem install bundler \
	&& gem install procodile \
	&& gem install tzinfo-data \
	&& addgroup -S postal \
	&& adduser -S -G postal -h /opt/postal -s /bin/bash postal \
	&& chown -R postal:postal /opt/postal/ \
	&& /opt/postal/bin/postal bundle /opt/postal/vendor/bundle \
	&& apk del git mariadb-dev \
	&& rm -rf /var/cache/apk/*

## Adjust permissions
RUN setcap 'cap_net_bind_service=+ep' /usr/local/bin/ruby

## Stick in required files
ADD wrapper.sh /wrapper.sh

## Expose
EXPOSE 5000

## Startup
ENTRYPOINT ["/bin/bash", "-c", "/wrapper.sh ${*}", "--"]
