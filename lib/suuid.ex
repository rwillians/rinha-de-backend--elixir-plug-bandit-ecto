defmodule SUUID do
  @moduledoc """
  Sortable UUID.
  """

  use Ecto.Type

  import Bigflake, only: [mint: 0]
  import String, only: [pad_leading: 3]

  @typedoc """
  String representation of a sortable UUID.
  """
  @type t :: <<_::256>>

  @doc """
  Generates a new sortable UUID.
  """
  @spec generate() :: t
  def generate do
    {:ok, id} = mint() |> with_retry(3)

    to_string(id)
    |> pad_leading(32, "0")
  end

  defp with_retry({:ok, value}, _), do: {:ok, value}
  defp with_retry({:error, :time_moved_backwards} = result, 0), do: result

  defp with_retry({:error, :time_moved_backwards}, n) do
    Process.sleep(5)
    mint() |> with_retry(n - 1)
  end

  defp with_retry({:error, _} = result, _), do: result

  @doc false
  @impl Ecto.Type
  def type, do: :string

  @doc false
  @impl Ecto.Type
  def cast(value), do: {:ok, value}

  @doc false
  @impl Ecto.Type
  def dump(value), do: {:ok, value}

  @doc false
  @impl Ecto.Type
  def load(value), do: {:ok, value}

  @doc false
  @impl Ecto.Type
  def autogenerate, do: generate()
end
