#!/bin/sh
set -eux

if [ "$1" = 'bundle' ]; then

  rm -f /usr/src/app/tmp/pids/server.pid
  find . -type d | xargs chmod 0755
  find . -type f -not -path "./vendor/*" | xargs chmod 0644

  if [ "$(id -u)" = '0' ]; then
    find . \! -user app -exec chown app:app '{}' +
    exec su-exec app "$@"
  fi
fi

exec "$@"
