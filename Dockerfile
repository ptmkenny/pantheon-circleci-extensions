# Start with PHP 7.2
FROM quay.io/pantheon-public/build-tools-ci:1.x
# parent
# https://github.com/pantheon-systems/docker-build-tools-ci/blob/master/Dockerfile
# grandparent
# https://github.com/drupal-docker/php/blob/2.x/7.2/Dockerfile-cli

# wget is needed to use cut-and-pasted backstopjs dockerfile below
# jq is needed for lighthouse
RUN apt-get update && \
	apt-get install -y wget jq

# Install nodejs from nodesource, lock to version 8
# https://github.com/nodesource/distributions/blob/master/README.md
RUN \
 	echo -e "\nEasy install from nodesource..." && \
  curl -sL https://deb.nodesource.com/setup_8.x | bash -

RUN \
  echo -e "\nInstalling nodejs from nodesource..." && \
  sudo apt-get install nodejs

RUN \
  echo -e "\nInstalling lighthouse..." && \
  npm install -g lighthouse

# https://www.npmjs.com/package/lighthouse-batch
RUN \
  echo -e "\nInstalling lighthouse-batch..." && \
  npm install -g lighthouse-batch



# Install backstopjs
# cut and pasted from below with directory change, see comment
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
