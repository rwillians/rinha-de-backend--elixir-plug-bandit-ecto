defmodule Rinha.Application do
  @moduledoc """
  Árvore de supervisão principal da aplicação.
  """

  use Application

  @impl true
  def start(_type, opts) do
    children =
      List.flatten([
        Rinha.Repo,
        RinhaAPI.Endpoint.children_spec(opts),
        #                 ^ Gambiarra por que não quero que o servidor HTTP
        #                   rode durante os tests. Chamadas à API serão feitas
        #                   diretamente à aplicação Plug.
      ])

    Supervisor.start_link(children, strategy: :one_for_one, name: Rinha.Supervisor)
  end
end
