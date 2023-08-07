##
#
# CONFIGURAÇÕES DE TEMPO DE COMPILAÇÃO
# Específicas para o ambiente de "dev".
#
##

import Config

#
# LOGGER
#

config :logger,
  level: :info,
  truncate: :infinity

#
# ECTO
#

database_url =
  System.get_env("DATABASE_URL_DEV") ||
    "postgres://postgres:postgres@localhost:5432/rinha_dev"

config :rinha, Rinha.Repo,
  url: database_url,
  force: true
