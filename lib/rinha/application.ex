defmodule Rinha.Application do
  @moduledoc """
  Árvore de supervisão principal da aplicação.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Rinha.Repo
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Rinha.Supervisor)
  end
end
