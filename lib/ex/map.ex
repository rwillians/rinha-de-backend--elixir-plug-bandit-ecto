defmodule Ex.Map do
  @moduledoc """
  Funcionalidades extendidas para o módulo `Map`.
  """

  import Enum, only: [to_list: 1]
  import String, only: [to_atom: 1]

  @doc """
  Dado um `Map` ou uma lista de `Map`, transforma todas as chaves as quais
  estão em string para atoms.

  ## Exemplos

      iex> Ex.Map.atomize_keys(%{"foo" => "bar"})
      %{foo: "bar"}

      iex> Ex.Map.atomize_keys(%{"foo" => %{"bar" => "baz"}})
      %{foo: %{"bar" => "baz"}}

  """
  @spec atomize_keys(map) :: map

  def atomize_keys(%{} = map) do
    for {k, v} <- to_list(map),
        into: %{},
        do: {to_atom(k), v}
  end
end
