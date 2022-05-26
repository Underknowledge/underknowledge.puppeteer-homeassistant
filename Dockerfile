FROM node:slim AS app

# We don't want the standalone Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
# To be able to use env variables in a build process we need to set this madness
ARG KINDLE_IP
ENV KINDLE_IP $KINDLE_IP
ARG KINDLE_PASSWORD
ENV KINDLE_PASSWORD $KINDLE_PASSWORD
ARG HOMEASSISTANT_LOGIN_USER
ENV HOMEASSISTANT_LOGIN_USER $HOMEASSISTANT_LOGIN_USER
ARG HOMEASSISTANT_LOGIN_PASS
ENV HOMEASSISTANT_LOGIN_PASS $HOMEASSISTANT_LOGIN_PASS
ARG HOMEASSISTANT_URL
ENV HOMEASSISTANT_URL $HOMEASSISTANT_URL
ARG SLEEP
ENV SLEEP $SLEEP
ARG READING_DURATION
ENV READING_DURATION $READING_DURATION


# Install Google Chrome Stable and fonts
# Note: this installs the necessary libs to make the browser work with Puppeteer.

RUN apt-get update && apt-get install curl gnupg imagemagick openssh-client sshpass netcat nano -y \
  && curl --location --silent https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list' \
  && apt-get update \
  && apt-get install google-chrome-stable -y --no-install-recommends \
  && apt-get install imagemagick \
  && rm -rf /var/lib/apt/lists/*

# Todo: Warings to be fixed 
# Warning: apt-key is deprecated. Manage keyring files in trusted.gpg.d instead (see apt-key(8)).
# W: Target Packages (main/binary-amd64/Packages) is configured multiple times in /etc/apt/sources.list.d/google-chrome.list:3 and /etc/apt/sources.list.d/google.list:1
# W: Target Packages (main/binary-all/Packages) is configured multiple times in /etc/apt/sources.list.d/google-chrome.list:3 and /etc/apt/sources.list.d/google.list:1

RUN  mkdir -p /opt/puppeteer/ && chown 1000:1000 /opt/puppeteer/

USER node

WORKDIR /opt/puppeteer/
ADD package.json /opt/puppeteer/package.json
RUN npm install

ADD homeassistant.sh /opt/puppeteer/homeassistant.sh
ADD home_assistant.js /opt/puppeteer/home_assistant.js
ADD entrypoint.sh /opt/puppeteer/entrypoint.sh

ENTRYPOINT ["/opt/puppeteer/entrypoint.sh"]