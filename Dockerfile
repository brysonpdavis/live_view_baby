ARG ELIXIR_VERSION=1.16.0
ARG OTP_VERSION=26.2.1
ARG ALPINE_VERSION=3.18.4

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-alpine-${ALPINE_VERSION}"
ARG RUNNER_IMAGE="alpine:${ALPINE_VERSION}"

FROM ${BUILDER_IMAGE} as builder

# install build dependencies
RUN apk add --no-cache build-base git nodejs yarn

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

# copy application code
COPY priv priv
COPY lib lib
COPY assets assets

# compile assets
WORKDIR /app/assets
RUN yarn install
WORKDIR /app
RUN mix assets.deploy

# Compile the elixir application
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
# Prepare the release
COPY config/runtime.exs config/
COPY rel rel
RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}

# Install runtime dependencies
RUN apk add --no-cache libstdc++ openssl ncurses-libs ca-certificates

WORKDIR "/app"
RUN chown nobody /app

# set runner ENV
ENV MIX_ENV="prod"
ENV LANG=C.UTF-8

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/live_view_baby ./

USER nobody

CMD ["/app/bin/server"]
