##
#
#   CONFIGURAÇÕES DE TEMPO DE COMPILAÇÃO
#   ====================================
#
#   Esse arquivo deve conter apenas configurações básicas as quais fazem
#   sentido aplicar para qualquer ambiente. Para configurações específicas de
#   um determinado ambiente, consulte "dev.exs", "test.exs" e "remote.exs",
#   onde remote se refere a qualquer ambiente que não seja local (staging,
#   prod, etc).
#
#   NOTA:   Nessa aplicação, os ambientes "dev" e "test" são considerados
#           ambientes "locais" e qualquer outro ambiente ambiente (como
#           "staging" e "production") são considerados ambientes "remotos".
#
#   AVISO:  Ambientes remotos devem ser considerados como "zero-trust" e as
#           definições máxima de seguraça devem ser aplicadas para todos
#           igualmente. Por exemplo, independentemente se o ambiente é
#           "staging" ou "production", a conexão com o banco de dados deve
#           ser estabelecida com SSL habilitado.
#
##

import Config

#
# LOGGER
#

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  backends: [:console]

#
# ECTO
#

config :rinha, ecto_repos: [Rinha.Repo]

#
# CONFIGURAÇÕES ESPECIFICAS POR AMBIENTE
#
#   Essas configurações serão importadas de seus respecitivos arquivos e podem
#   sobrescrever configurações definidas nesse arquivo.
#

case config_env() do
  :dev  -> import_config("dev.exs")
  :test -> import_config("test.exs")
  _     -> import_config("remote.exs")
end
