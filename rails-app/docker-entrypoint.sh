#!/bin/sh
set -e

rm tmp/pids/server.pid -f

exec bundle exec "$@"
