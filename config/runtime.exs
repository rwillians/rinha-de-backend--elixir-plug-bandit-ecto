##
#
#   CONFIGURAÇÕES DE TEMPO DE EXECUÇÃO
#   Computadas ao inicializar a aplicação, aplicada para todos ambientes.
#   =====================================================================
#
#   Este arquivo deve conter apenas configurações as quais serão acessadas em
#   tempo de execução. Para configurações de tempo de compilação, consulte
#   "configs.exs".
#
##

import Config
import Ex.Config

#
#   ECTO
#

if is_remote?(config_env()) do
  database_url =
    env("DATABASE_URL") ||
      raise """
      missing "DATABASE_URL" environment variable!
      """

  maybe_ipv6 =
    if env("ECTO_IPV6", "false") in ["true", "1"],
      do: [:inet6],
      else: []

  pool_size =
    env("POOL_SIZE", "20")
    |> String.to_integer()

  config :rinha, Rinha.Repo,
    url: database_url,
    pool_size: pool_size,
    socket_options: maybe_ipv6,
    ssl: flag_enabled?("DATABASE_SSL_ENABLED", true) in ["true", "1"]
end

#
#   SERVIDOR HTTP DA APLICAÇÃO
#

config :rinha, RinhaAPI.Endpoint,
  port: env("PORT", "3000") |> String.to_integer(10),
  run_server?: flag_enabled?("SERVER_ENABLED", false)
