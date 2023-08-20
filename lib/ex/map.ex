defmodule Ex.Map do
  @moduledoc """
  Funcionalidades extendidas para o módulo `Map`.
  """

  import Enum, only: [into: 2, to_list: 1]
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

  def atomize_keys(%{} = map), do: do_atomize_keys(to_list(map), [])

  defp do_atomize_keys([{k, v} | tail], acc), do: do_atomize_keys(tail, [{to_atom(k), v} | acc])
  defp do_atomize_keys([], acc), do: into(acc, %{})
end
