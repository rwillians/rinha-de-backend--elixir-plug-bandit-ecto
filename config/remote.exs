##
#
#   CONFIGURAÇÕES DE TEMPO DE COMPILAÇÃO
#   Específicas para o ambientes remotos (todos exceto "dev" e "test").
#
##

import Config

#
#   LOGGER
#

config :logger, level: :error
config :logger, compile_time_purge_matching: [[level_lower_than: :error]]

#
#   ECTO
#

config :rinha, Rinha.Repo, force: false
