FROM ruby:2.5

RUN apt-get -y update \
	&& apt-get -y install git nodejs mysql-client libssl-dev mysql-common tzdata \
	&& git clone https://github.com/atech/postal.git /opt/postal \
	&& rm -rf /var/lib/apt/lists/* \
	&& gem install bundler \
	&& gem install procodile \
	&& gem install tzinfo-data \
	&& useradd -r -d /opt/postal -s /bin/bash postal \
	&& chown -R postal:postal /opt/postal/ \
	&& /opt/postal/bin/postal bundle /opt/postal/vendor/bundle \
	&& mv /opt/postal/config /opt/postal/config-original

## Stick in required files
ADD wrapper.sh /wrapper.sh

## Expose
EXPOSE 5000

## Startup
ENTRYPOINT ["/bin/bash", "-c", "/wrapper.sh ${*}", "--"]
