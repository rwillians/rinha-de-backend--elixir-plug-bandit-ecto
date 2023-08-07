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
# ECTO
#

if is_remote?(config_env()) do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      missing "DATABASE_URL" environment variable!
      """

  maybe_ipv6 =
    if System.get_env("ECTO_IPV6", "false") in ["true", "1"],
      do: [:inet6],
      else: []

  pool_size =
    System.get_env("POOL_SIZE", "20")
    |> String.to_integer()

  config :rinha, Rinha.Repo,
    url: database_url,
    pool_size: pool_size,
    socket_options: maybe_ipv6
end

#
# SERVIDOR HTTP DA APLICAÇÃO
#

config :rinha, RinhaAPI.Endpoint,
  port: System.get_env("PORT", "3000") |> String.to_integer(10),
  run_server?: System.get_env("SERVER_ENABLED", "false") in ["true", "1"]
