# Start with PHP 7.2
# Must override pantheon parent because pantheon does not bother to update their own build tools :(
# FROM quay.io/pantheon-public/build-tools-ci:1.x
# parent
# https://github.com/pantheon-systems/docker-build-tools-ci/blob/master/Dockerfile
# grandparent
# https://github.com/drupal-docker/php/blob/2.x/7.2/Dockerfile-cli

## BEGIN PANTHEON OVERRIDE ##
## (replaces FROM quay.io/pantheon-public/build-tools-ci:1.x) ##

# Use an official Python runtime as a parent image
FROM drupaldocker/php:7.2-cli

# Set the working directory to /build-tools-ci
WORKDIR /build-tools-ci

# Copy the current directory contents into the container at /build-tools-ci
ADD . /build-tools-ci

# Collect the components we need for this image
RUN apt-get update
RUN composer -n global require -n "hirak/prestissimo:^0.3"
RUN mkdir -p /usr/local/share/terminus
RUN /usr/bin/env COMPOSER_BIN_DIR=/usr/local/bin composer -n --working-dir=/usr/local/share/terminus require pantheon-systems/terminus:"^1.9"
RUN mkdir -p /usr/local/share/drush
RUN /usr/bin/env composer -n --working-dir=/usr/local/share/drush require drush/drush "^8"
RUN ln -fs /usr/local/share/drush/vendor/drush/drush/drush /usr/local/bin/drush
RUN chmod +x /usr/local/bin/drush

env TERMINUS_PLUGINS_DIR /usr/local/share/terminus-plugins
RUN mkdir -p /usr/local/share/terminus-plugins
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-build-tools-plugin:^1
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-secrets-plugin:^1
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-rsync-plugin:^1
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-quicksilver-plugin:^1
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-composer-plugin:^1
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-drupal-console-plugin:^1
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-mass-update:^1
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-site-clone-plugin:^1

## END PANTHEON OVERRIDE ##

# Set up imagemagick
# https://github.com/docker-library/php/issues/105#issuecomment-348296120
RUN export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        libmagickwand-dev \
    && rm -rf /var/lib/apt/lists/* \
    && pecl install imagick-3.4.3 \
    && docker-php-ext-enable imagick

# wget is needed to use cut-and-pasted backstopjs dockerfile below
# jq is needed for lighthouse
# gnupg is used to install nodesource
# apt-utils is needed so docker hub doesn't whine
RUN apt-get update && \
	apt-get install -y wget jq apt-utils gnupg

# Install nodejs from nodesource, lock to version 8
# https://github.com/nodesource/distributions/blob/master/README.md
RUN \
 	echo -e "\nEasy install from nodesource..." && \
  curl -sL https://deb.nodesource.com/setup_8.x | bash -

RUN \
  echo -e "\nInstalling nodejs from nodesource..." && \
  apt-get install nodejs -y

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
	apt-get install -y git sudo software-properties-common
# python-software-properties is removed because it is included in software-properties-common

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
