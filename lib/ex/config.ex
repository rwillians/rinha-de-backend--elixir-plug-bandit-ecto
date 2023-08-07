defmodule Ex.Config do
  @moduledoc """
  Funcionalidades extendidas do módulo `Elixir.Config`.
  """

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
