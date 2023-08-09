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

config :logger, level: :info
config :logger, compile_time_purge_matching: [[level_lower_than: :info]]

#
#   ECTO
#

config :rinha, Rinha.Repo, force: false
