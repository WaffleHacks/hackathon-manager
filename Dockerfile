FROM ruby:2.6-alpine as base

# Install system dependencies for runtime and build time
RUN apk add --no-cache --update postgresql-dev tzdata nodejs yarn

# Install bundler
RUN gem install bundler


# Stage to install dependencies
FROM base as dependencies

# Install build dependencies
RUN apk add --no-cache --update build-base git

# Copy dependency specifications
COPY Gemfile Gemfile.lock ./
COPY vendor ./vendor

# Install gems (w/o development & test deps)
RUN bundle config set without "development test" && \
    bundle install --jobs=3 --retry=3

# Install node dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile


# Stage to copy project files for sidekiq and rails
FROM base as project

# Create a new user to run as
RUN adduser -D app
USER app

WORKDIR /hackathon-manager

# Copy dependencies
COPY --chown=app --from=dependencies /usr/local/bundle/ /usr/local/bundle/
COPY --chown=app --from=dependencies /node_modules/ node_modules/

# Copy application files
COPY --chown=app app ./app/
COPY --chown=app bin ./bin/
COPY --chown=app config ./config/
COPY --chown=app db ./db/
COPY --chown=app lib ./lib/
COPY --chown=app public ./public/
COPY --chown=app config.ru ./
COPY --chown=app Gemfile Gemfile.lock ./
COPY --chown=app Rakefile ./


###
# Rails image
###
FROM project as rails

# Build assets
RUN RAILS_ENV=production SECRET_KEY_BASE=assets bundle exec rake assets:precompile

# Startup configuration
EXPOSE 3000
COPY --chmod=775 docker-entrypoint.sh ./entrypoint.sh
CMD ["./entrypoint.sh"]


###
# Sidekiq image
###
FROM project as sidekiq
CMD ["bundle", "exec", "sidekiq", "-e", "production"]
