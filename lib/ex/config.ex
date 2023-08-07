defmodule Ex.Config do
  @moduledoc """
  Funcionalidades extendidas do módulo `Elixir.Config`.
  """

  import Config, only: [config_env: 0]

  @doc """
  Confere se o ambiente atual é um ambiente remoto.

  Utiliza `Elixir.Config.config_env/0` e `Ex.Config.is_remote?/1` por baixo
  dos panos.
  """
  defmacro is_remote?, do: config_env() |> is_remote?

  @doc """
  Confere se o dado ambiente é um ambiente remoto.
  """
  @spec is_remote?(:dev | :doc | :test | atom) :: boolean
  @compile {:inline, is_remote?: 1}

  def is_remote?(:dev), do: false
  def is_remote?(:doc), do: false
  def is_remote?(:test), do: false
  def is_remote?(_), do: true
end
