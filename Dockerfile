FROM ruby:3-alpine
RUN apk add --no-cache vault libcap && setcap cap_ipc_lock= /usr/sbin/vault
COPY . /app
WORKDIR /app
RUN bundle update --bundler && bundle install
ENTRYPOINT ["bundle", "exec", "rake"]
