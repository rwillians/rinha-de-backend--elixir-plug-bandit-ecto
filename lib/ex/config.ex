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

  @doc """
  O mesmo que chamar `System.get_env/1` ou `System.get_env/2`, porém, é garantido
  que um resultado de string vazia será substituido pro `nil` ("falsey") -- se
  você realmente quiser uma string vazia, passe isso como valor padrão no
  segundo argumento.
  """
  @spec env(name :: String.t(), default :: nil | String.t()) :: String.t() | nil

  def env(<<_, _::binary>> = name, default \\ nil)
      when is_nil(default)
      when is_binary(default) do
    default = if not is_nil(default), do: String.trim(default)
    value = System.get_env(name, "") |> String.trim()

    case String.length(value) > 0 do
      true -> value
      false -> default
    end
  end

  @doc """
  Confere se uma flag presente em forma de variável de ambiente está habilitada
  ou desabilitada. Valores considerados "habilitada" são: "true" e "1".
  """
  @spec flag_enabled?(name :: String.t(), default :: boolean) :: boolean

  def flag_enabled?(<<_, _::binary>> = name, default \\ false)
      when is_boolean(default) do
    case env(name) do
      nil -> default
      value -> String.downcase(value) in ["true", "1"]
    end
  end
end
