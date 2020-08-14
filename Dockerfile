# Global Build Args ----------------------------------
# Deployment environment
ARG APP_ENV=production

# Linux distro
ARG IMAGE_DISTRO=alpine

# The root of our app
ARG RAILS_ROOT=/home/app

# Ruby version
ARG RUBY_VERSION=2.5.1


# Base Image -----------------------------------------
FROM ruby:${RUBY_VERSION}-${IMAGE_DISTRO} AS baseimage
LABEL description="Base image used by other stages"


# Build Image ----------------------------------------
FROM baseimage AS build
LABEL description="Image to build our application"

ARG APP_ENV
ENV APP_ENV=${APP_ENV}

ARG RAILS_ROOT
ENV RAILS_ROOT=${RAILS_ROOT}

ENV BUNDLE_APP_CONFIG="${RAILS_ROOT}/.bundle"

WORKDIR ${RAILS_ROOT}

COPY Gemfile* ./

# Install
RUN bundle config --global frozen 1 && \
    bundle install $([ "$APP_ENV" == "development" ] && printf %s '--with development:test --path=vendor/bundle' || printf %s '--deployment') -j$(nproc) --retry 3 && \
    rm -rf vendor/bundle/ruby/*/cache/*.gem && \
    find vendor/bundle/ruby/*/gems/ \( -name "*.c" -o -name "*.o" \) -delete && \
    rm -rf tmp/cache app/assets vendor/assets lib/assets spec

COPY . .

# Final Image ----------------------------------------
FROM baseimage
LABEL description="Final image of our application"

ARG APP_ENV
ENV APP_ENV=${APP_ENV}

ARG RAILS_ROOT
ENV RAILS_ROOT=${RAILS_ROOT}

ENV BUNDLE_APP_CONFIG="${RAILS_ROOT}/.bundle"

COPY --from=build ${RAILS_ROOT} ${RAILS_ROOT}
COPY ./docker-entrypoint.sh /usr/local/bin/

WORKDIR ${RAILS_ROOT}

# Make entrypoint executable, add app user, and install dependencies
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    addgroup -S app && adduser -S app -G app -h ${RAILS_ROOT} && \
    apk add --no-cache \
        shadow \
        'su-exec>=0.2'

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3000

VOLUME ${RAILS_ROOT}

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "--port", "3000"]
