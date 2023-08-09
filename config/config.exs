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
#   LOGGER
#

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id],
  backends: [:console]

#
#   ECTO
#

config :rinha, ecto_repos: [Rinha.Repo]

#
#   SERVIDOR HTTP DA APLICAÇÃO
#

#   Define se o servidor HTTP deve ser iniciado automaticamente ao iniciar a
#   aplicação. Desabilitador por padrão, utilize o comando `mix server` para
#   iniciar a aplicação juntamente com o servidor HTTP.
config :rinha, RinhaAPI.Endpoint, run_server?: false

#
#   LIBCLUSTER
#

config :libcluster, debug: true

#
#   CONFIGURAÇÕES ESPECIFICAS POR AMBIENTE
#   --------------------------------------
#
#   Essas configurações serão importadas de seus respecitivos arquivos e podem
#   sobrescrever configurações definidas nesse arquivo. Os ambientes "dev" e
#   "test" são considerados ambientes locais; logo, demais ambiente são
#   considerados "remotos".
#

case config_env() do
  :dev  -> import_config("dev.exs")
  :test -> import_config("test.exs")
  _     -> import_config("remote.exs")
end
