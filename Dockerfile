# Start with PHP 7.2
FROM quay.io/pantheon-public/build-tools-ci:1.x
# https://github.com/pantheon-systems/docker-build-tools-ci/blob/master/Dockerfile

# Install ssh
RUN \
	echo -e "\nInstalling node..." && \
	apt-get install -y node

# Install backstopjs
RUN \
	echo -e "\nInstalling backstopjs..." && \
	npm install -g backstopjs

