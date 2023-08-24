defmodule Pessoa do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query
  import Enum, only: [join: 2]
  import Ex.Ecto.Changeset
  import String, only: [downcase: 1]

  @typedoc false
  @type t :: %Pessoa{
          id: Ecto.UUID.t(),
          nome: String.t(),
          apelido: String.t(),
          nascimento: Date.t(),
          stack: [String.t(), ...] | nil,
          pesquisa: String.t()
        }

  @primary_key false
  @derive {Jason.Encoder, only: [:id, :nome, :apelido, :nascimento, :stack]}
  schema "pessoas" do
    field :id, Ecto.UUID, autogenerate: true, primary_key: true
    field :nome, :string
    field :apelido, :string
    field :nascimento, :date
    field :stack, {:array, :string}, default: nil
    field :pesquisa, :string
  end

  ##
  #
  #   CHANGESET
  #
  ##

  @doc """
  Returna um `Ecto.Changeset` com as alterações feitas em um model
  `Pessoa`.
  """
  @spec changeset(t(), map) :: Ecto.Changeset.t()

  @dup_nick_error_msg "já existe uma pessoa com esse apelido"
  @alphabet_error_msg "apenas letras e espaços são permitidos"
  @min_char_error_msg "deve conter no mínimo %{count} caracteres"
  @max_char_error_msg "deve conter no máximo %{count} caracteres"
  @required_error_msg "campo obrigatório"

  @accents "àèìòùÀÈÌÒÙáéíóúýÁÉÍÓÚÝâêîôûÂÊÎÔÛãñõÃÑÕäëïöüÿÄËÏÖÜŸçÇ"
  @name_pattern ~r/^[a-zA-Z#{@accents}\.\s]+$/
  #                                    ^ minha carge de teste gerou nomes
  #                                      incluindo títulos como "Dr. ..."

  def changeset(pessoa, params \\ %{}) do
    changeset =
      pessoa
      |> cast(params, [:nome, :apelido, :nascimento, :stack])
      |> validate_required([:nome, :apelido, :nascimento], message: @required_error_msg)
      |> validate_length(:nome, min: 3, message: @min_char_error_msg)
      |> validate_length(:nome, max: 100, message: @max_char_error_msg)
      |> validate_format(:nome, @name_pattern, message: @alphabet_error_msg)
      |> validate_length(:apelido, max: 32, message: @max_char_error_msg)
      |> unique_constraint(:apelido, message: @dup_nick_error_msg)
      |> validate_array(:stack, each_length(max: 32, message: @max_char_error_msg))

    case changeset.valid? do
      true ->
        term =
          apply_changes(changeset)
          |> to_search_term()
          |> downcase()

        put_change(changeset, :pesquisa, term)

      false ->
        changeset
    end
  end

  defp to_search_term(%{stack: [_ | _] = stack} = p), do: join([p.nome, p.apelido] ++ stack, " ")
  defp to_search_term(p), do: join([p.nome, p.apelido], " ")

  ##
  #
  #   QUERIES
  #
  ##

  @doc """
  Query builder para o model `Pessoa`.
  """
  @spec pessoas_query([{atom, term}, ...]) :: Ecto.Queryable.t()

  def pessoas_query(filters)
      when is_list(filters),
      do: from(pessoa in Pessoa, order_by: [asc: pessoa.id]) |> filter(filters)

  defp filter(query, []), do: query
  defp filter(query, [{:id, id} | tail]), do: where(query, [p], p.id == ^id) |> filter(tail)

  defp filter(query, [{:t, term} | tail]) do
    term = downcase(term)

    query
    |> where([p], like(p.pesquisa, ^"%#{term}%"))
    |> filter(tail)
  end
end
