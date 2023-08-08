FROM elixir:1.15.4-alpine AS build

WORKDIR /app
ENV MIX_ENV=prod

RUN apk add --no-cache git coreutils ncurses libstdc++ libgcc && \
    mix local.hex --force && \
    mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get && \
    mix deps.compile

COPY lib/ lib/
COPY config/ config/
RUN mix compile

COPY priv/ priv/
RUN mix release

#

FROM elixir:1.15.4-alpine AS prod

RUN apk add --no-cache coreutils && \
    #                      ^ because I need the `ping` command to use from inside
    #                        docker-compose
    mix local.hex --force && \
    mix local.rebar --force

WORKDIR /app
ENV MIX_ENV=prod

COPY --from=build /app/ /app/
COPY .docker/api/wait-for-it /usr/bin/wait-for-it

ENV PORT=3000
EXPOSE 3000

ENTRYPOINT [ "_build/prod/rel/rinha/bin/rinha" ]
