FROM public.ecr.aws/docker/library/ruby:3.1.2-slim-buster as builder
WORKDIR /app

RUN apt-get update \
    && apt-get install -y curl git libpq-dev build-essential \
    && curl -sL https://deb.nodesource.com/setup_15.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock .ruby-version /app/
RUN bundle install --jobs=10 --path=vendor/bundle --deployment --without test
COPY package.json yarn.lock /app/
RUN npm install -g yarn \
    && yarn install --frozen-lockfile
COPY . /app/
RUN bin/rails assets:precompile

FROM public.ecr.aws/docker/library/ruby:3.1.2-slim-buster
WORKDIR /app
COPY --from=builder /app/vendor/bundle /app/vendor/bundle
COPY --from=builder /app/.bundle /app/.bundle
COPY --from=builder /app/public/packs /app/public/packs
COPY . /app/

ENV PORT 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
