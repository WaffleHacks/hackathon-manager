#!/bin/ash

set -e

export RACK_ENV=production
export RAILS_ENV=production
export RAILS_LOG_TO_STDOUT=true
export RAILS_SERVE_STATIC_FILES=enabled

bundle exec rake db:migrate
bundle exec rake db:seed
exec bundle exec puma -C config/puma.rb -e production -b tcp://0.0.0.0:3000
