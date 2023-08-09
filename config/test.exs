##
#
#   CONFIGURAÇÕES DE TEMPO DE COMPILAÇÃO
#   Específicas para o ambiente de "test".
#
##

import Config

#
#   LOGGER
#

config :logger,
  level: :warning,
  truncate: :infinity

#
#   ECTO
#

database_url =
  System.get_env("DATABASE_URL_TEST") ||
    "postgres://postgres:postgres@localhost:5432/rinha_test"

config :rinha, Rinha.Repo,
  url: database_url,
  pool: Ecto.Adapters.SQL.Sandbox,
  force_drop: true
