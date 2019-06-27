FROM node:lts-alpine

#ENV HOST localhost
#ENV PORT 3000
ENV NODE_ENV=production

RUN apk update && apk upgrade && \
  apk add --no-cache build-base git && \
  rm -f /var/cache/apk/*

# https://www.alpinelinux.org/posts/Docker-image-vulnerability-CVE-2019-5021.html
# https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2019-5021
# make sure root login is disabled
RUN sed -i -e 's/^root::/root:!:/' /etc/shadow

# add a group and user for our app, for a system user or group
# add '-S' to addgroup or adduser commands
RUN addgroup gekko && adduser -g gekko gekko

# Install GYP dependencies globally, will be used to code build other dependencies
RUN yarn global add node-gyp && \
  yarn cache clean

# Copy Gekko dependencies
#COPY package.json .
# Copy Gekko Broker dependencies
#COPY exchange/package.json /home/gekko/app/exchange

# Copy app source
COPY . /home/gekko/app

WORKDIR /home/gekko/app

# Install Gekko dependencies
RUN yarn  && \
  yarn add redis@0.10.0 talib@1.0.2 tulind@0.8.7 pg && \
  yarn cache clean

WORKDIR /home/gekko/app/exchange

# Install Gekko Broker dependencies
RUN yarn && yarn cache clean

WORKDIR /home/gekko/app

RUN chown -R gekko:gekko /home/gekko

USER gekko

EXPOSE 3000

RUN chmod +x /home/gekko/app/docker-entrypoint.sh
#RUN chmod +x /usr/src/app/docker-entrypoint.sh

#ENTRYPOINT ["/usr/src/app/docker-entrypoint.sh"]
ENTRYPOINT ["/home/gekko/app/docker-entrypoint.sh"]

CMD ["--config", "config.js", "--ui"]
