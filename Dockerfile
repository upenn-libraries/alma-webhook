FROM alpine:3.2

MAINTAINER Christopher Clement <clemenc@upenn.edu>

EXPOSE 80

#RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app

#COPY Gemfile Gemfile.lock /usr/src/app/
COPY . /usr/src/app/

RUN apk add --no-cache --virtual build-deps build-base ruby-dev ca-certificates && \
    apk add --no-cache ruby ruby-bundler && \
    bundle install && \
    apk del --no-cache build-deps

CMD ["rackup", "--host", "0.0.0.0", "--port", "80"]
