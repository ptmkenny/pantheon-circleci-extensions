# Start with PHP 7.2
FROM quay.io/pantheon-public/build-tools-ci:1.x
# parent
# https://github.com/pantheon-systems/docker-build-tools-ci/blob/master/Dockerfile
# grandparent
# https://github.com/drupal-docker/php/blob/2.x/7.2/Dockerfile-cli

# Update
RUN apt-get update 

# Install node
# RUN \
# 	echo -e "\nInstalling node..." && \
# 	apt-get install -y nodejs npm
# Using Ubuntu
RUN \
	echo -e "\nInstalling node..." && \
  curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - \
  sudo apt-get install -y nodejs

# Install backstopjs
# https://github.com/garris/BackstopJS/blob/master/docker/Dockerfile

ARG BACKSTOPJS_VERSION

ENV \
	PHANTOMJS_VERSION=2.1.7 \
	CASPERJS_VERSION=1.1.4 \
	SLIMERJS_VERSION=0.10.3 \
	BACKSTOPJS_VERSION=$BACKSTOPJS_VERSION \
	# Workaround to fix phantomjs-prebuilt installation errors
	# See https://github.com/Medium/phantomjs/issues/707
	NPM_CONFIG_UNSAFE_PERM=true

# Base packages
RUN apt-get update && \
	apt-get install -y git sudo software-properties-common python-software-properties

RUN sudo npm install -g --unsafe-perm=true --allow-root phantomjs@${PHANTOMJS_VERSION}
RUN sudo npm install -g --unsafe-perm=true --allow-root casperjs@${CASPERJS_VERSION}
RUN sudo npm install -g --unsafe-perm=true --allow-root slimerjs@${SLIMERJS_VERSION}
RUN sudo npm install -g --unsafe-perm=true --allow-root backstopjs@${BACKSTOPJS_VERSION}

RUN wget https://dl-ssl.google.com/linux/linux_signing_key.pub && sudo apt-key add linux_signing_key.pub
RUN sudo add-apt-repository "deb http://dl.google.com/linux/chrome/deb/ stable main"

RUN	apt-get -y update && \
	apt-get -y install google-chrome-stable

RUN apt-get install -y firefox-esr

# Change for pantheon build image
WORKDIR /app

ENTRYPOINT ["backstop"]
