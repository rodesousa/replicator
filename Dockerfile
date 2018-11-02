FROM elixir:1.7-alpine AS build

WORKDIR /build

COPY . /build
ARG MIX_ENV=prod
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix hex.info

RUN mix deps.get
RUN mix release --env=$MIX_ENV

FROM elixir:1.7-alpine

WORKDIR /app

ENV LANG=en_US.UTF-8
ENV REPLACE_OS_VARS=true

RUN apk add bash

COPY --from=build /build/_build/prod/rel/ /app
ENV MIX_ENV=prod

ENTRYPOINT ["/bin/bash"]
CMD ["/app/replicator/bin/replicator", "foreground"]
