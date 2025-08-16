FROM ruby:3.3.0-slim

WORKDIR /app

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs curl gnupg \
  && mkdir -p /etc/apt/keyrings \
  && curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /etc/apt/keyrings/yarn.gpg \
  && echo "deb [signed-by=/etc/apt/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
  && apt-get update -qq && apt-get install -y yarn

# Defina variáveis obrigatórias para o build dos assets (valor dummy)
ARG SECRET_KEY_BASE=dummy_key_for_build_only
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE

# Set environment variable for Rails
ENV RAILS_ENV=staging

COPY Gemfile* ./
RUN bundle install --without development test

COPY package.json yarn.lock ./
RUN yarn install --production

COPY . .

RUN bundle exec rake assets:precompile

EXPOSE 3000

CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec rails server -e staging -b 0.0.0.0"]
