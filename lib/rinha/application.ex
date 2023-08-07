defmodule Rinha.Application do
  @moduledoc """
  Árvore de supervisão principal da aplicação.
  """

  use Application

  @impl true
  def start(_type, opts) do
    children =
      List.flatten([
        #  ^ Gambiarra por que não quero que o servidor HTTP rode durante os
        #    tests. Chamadas à API serão feitas diretamente à aplicação Plug.
        Rinha.Repo,
        http_server_children(opts)
      ])

    Supervisor.start_link(children, strategy: :one_for_one, name: Rinha.Supervisor)
  end

  defp http_server_children(opts) do
    config = RinhaAPI.Endpoint.get_config(opts)

    port = Keyword.fetch!(config, :port)
    run_server? = Keyword.fetch!(config, :run_server?)

    opts = [
      plug: RinhaAPI.Endpoint,
      scheme: :http,
      options: [port: port]
    ]

    case run_server? do
      true -> [{Plug.Cowboy, opts}]
      false -> []
    end
  end
end
