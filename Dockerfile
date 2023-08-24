FROM elixir:1.15.4-alpine AS build

WORKDIR /app
ENV MIX_ENV=prod

RUN apk add --no-cache git ncurses libstdc++ libgcc && \
    mix local.hex --force && \
    mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get --no-archives-check --only=prod
RUN mix deps.compile

COPY lib/ lib/
COPY config/ config/
RUN mix compile

COPY priv/ priv/
RUN mix release

#

FROM elixir:1.15.4-alpine AS prod

RUN mix local.hex --force && \
    mix local.rebar --force

WORKDIR /app
ENV MIX_ENV=prod

COPY --from=build /app/ /app/

STOPSIGNAL SIGINT

ENV PORT=3000
EXPOSE 3000

ENTRYPOINT [ "_build/prod/rel/rinha/bin/rinha", "start" ]
