#!/bin/sh
set -e

# If the command being run is `bundle exec rackup`
if [[ "$1" == "bundle" ]] && [[ "$2" == "exec" ]] && [[ "$3" == "rackup" ]]; then

  # Ensure a server is not running
  rm -f /usr/src/app/tmp/pids/server.pid

  # Set permissions on project folders/files
  find . -type d | xargs chmod 0755
  find . -type f -not -path "./vendor/*" | xargs chmod 0644

  # If running a development environment then set permissions and install the gems
  if [[ "${APP_ENV}" == "development" ]] && [[ -n "${APP_UID+set}" ]] && [[ -n "${APP_GID+set}" ]]; then
    echo "Running development environment with mapped project dir"

    if [[ -z "${APP_UID}" ]] || [[ -z "${APP_GID}" ]]; then
      echo "Error - APP_IUD and APP_GID must be set"
      exit 1
    fi

    # Update the user and group id
    echo "Changing app user and group id"
    usermod -u ${APP_UID} app
    groupmod -g ${APP_GID} app

    # Install the gems
    echo "Installing gems"
    bundle install --with development:test -j$(nproc) --retry 3 --path=vendor/bundle
  fi

  # If the current user is root then set file permissions to and run the application as the app user
  if [[ "$(id -u)" == "0" ]]; then
    find . \! -user app -exec chown app:app '{}' +
    exec su-exec app "$@"
  fi
fi

# Run any other command
exec "$@"
