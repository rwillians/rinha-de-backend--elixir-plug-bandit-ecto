defmodule Ex.Ecto.Changeset do
  @moduledoc """
  Funcionalidades extendidas para um `Ecto.Changeset`.
  """

  import Ecto.Changeset, only: [validate_change: 3]
  import Enum, only: [flat_map: 2, map: 2]
  import Keyword, only: [get: 2]
  import String, only: [replace: 3]

  @doc """
  Destinado para campos do tipo array em um changeset, aplica a função
  `validador` para cada item do array podem produzir zero ou mais erros.

  ## Exemplos

    ```elixir
    changeset
    |> cast(params, [:stack])
    |> validate_array(:stack, each_length(max: 32, message: "deve conter..."))
    ```

  """
  def validate_array(changeset, field, validator),
    do: validate_change(changeset, field, &validate_array({&1, &2}, validator))

  defp validate_array({field, [_ | _] = values}, validator) do
    values
    |> flat_map(validator)
    |> map(fn {value, error} -> {field, {error, value: value}} end)
  end

  defp validate_array({_field, [] = _values}, _validator), do: []
  defp validate_array({_, nil}, _), do: []

  defp validate_array({field, _}, _),
    do: [{field, "Campo `#{field}` deve conter um array ou ser nullo"}]

  @doc """
  Destinado a ser utilizado juntamente com `validate_array/3`, valida o tamanho
  de strings continas em um parametro do tipo array em um `Ecto.Changeset`.

  ## Relacionado

  - Veja `Ex.Ecto.Changeset.validate_array/3`.

  """
  def each_length([{:max, _} | _] = opts), do: &each_length(&1, opts)

  defp each_length(value, [{:max, max} | opts]) do
    message =
      case get(opts, :message) do
        nil -> "expected a string with max %{count} chars"
        <<_, _::binary>> = string -> string
      end

    case String.length(value) > max do
      true -> [{value, replace(message, "%{count}", "#{max}")}]
      false -> []
    end
  end
end
