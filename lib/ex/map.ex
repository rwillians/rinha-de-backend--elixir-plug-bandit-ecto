defmodule Ex.Map do
  @moduledoc """
  Funcionalidades extendidas para o módulo `Map`.
  """

  import Enum, only: [to_list: 1]
  import Map, only: [put: 3]
  import String, only: [to_atom: 1]

  @doc """
  Dado um `Map` ou uma lista de `Map`, transforma todas as chaves as quais
  estão em string para atoms.

  ## Exemplos

      iex> Ex.Map.atomize_keys(%{"foo" => %{"bar" => "baz"}})
      %{foo: %{bar: "baz"}}

      iex> Ex.Map.atomize_keys(%{"foo" => [%{"bar" => "baz"}, %{"baz" => "bar"}]})
      %{foo: [%{bar: "baz"}, %{baz: "bar"}]}

  """
  @spec atomize_keys(map) :: map

  def atomize_keys(%{} = map), do: do_atomize_keys(map)

  defp do_atomize_keys(%{} = map), do: atomize_map(%{}, to_list(map))
  defp do_atomize_keys([_ | _] = list), do: atomize_elements([], list)
  defp do_atomize_keys([]), do: []
  defp do_atomize_keys(any), do: any

  defp atomize_map(%{} = acc, [{key, value} | tail]) do
    acc
    |> put(maybe_to_integer(key), do_atomize_keys(value))
    |> atomize_map(tail)
  end

  defp atomize_map(%{} = acc, []), do: acc

  defp atomize_elements(acc, [head | tail]), do: atomize_elements([do_atomize_keys(head) | acc], tail)
  defp atomize_elements(acc, []), do: :lists.reverse(acc)

  defp maybe_to_integer(<<_, _::binary>> = key), do: to_atom(key)
  defp maybe_to_integer(value), do: value
end
