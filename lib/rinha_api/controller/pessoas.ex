defmodule RinhaAPI.Controller.Pessoas do
  @moduledoc false

  use RinhaAPI.Controller

  import Ex.Ecto.Query, only: [paginated: 2]
  import Ex.Map, only: [atomize_keys: 1]
  import Map, only: [take: 2]
  import Pessoa, only: [pessoas_query: 1]
  import Rinha.Repo, only: [one: 1]

  @doc """
  Endpoint para criação de uma nova pessoa :eyes:
  """
  def criar_pessoa(%Plug.Conn{} = conn) do
    changeset = Pessoa.changeset(%Pessoa{}, conn.body_params)

    case Rinha.Repo.insert(changeset) do
      {:ok, pessoa} ->
        conn
        |> put_resp_header("location", "/pessoas/#{pessoa.id}")
        |> send_resp_json(201, pessoa)

      {:error, changeset} ->
        http_error(:validation_error, changeset)
        |> send_resp_json(conn)
    end
  end

  @doc """
  Lista de forma paginada todas a pessoas existentes no banco de dados. Aceita
  os seguintes filtros:

  - `pagina` (integer, opcional): o número da página a ser retornada
    (zero-based -- default `0`);
  - `limite` (integer, opcional): o número máximo de resultados a ser retornado
    na página (zero-based -- default `10`);
  - `q` (string, opcional): um termo de pesquisa o qual será à ambos nome e
    apelido em `Pessoa`.

  """
  def listar_pessoas(%Plug.Conn{} = conn) do
    page =
      atomize_keys(conn.query_params)
      |> take([:pagina, :limite, :q])
      |> paginated(&pessoas_query/1)

    send_resp_json(conn, 200, page)
  end

  @doc """
  Pega uma pessoa 👀 dado seu id como parametro de URL.
  """
  def pegar_pessoa(
        %{
          params: %{
            "id" => <<_::64, ?-, _::32, ?-, "4", _::24, ?-, _::32, ?-, _::96>> = id
            #            ^   ^               ^ se não for um uuid v4, passa
            #            ^   ^                 reto e já mete um 404
            #            ^   ^
            #            ^   ^ se não estiver formatado com os tracinho e
            #            ^     tals, foda-se vai dar 404
            #            ^
            #            ^ se não tiver o tamanho de um uuid v4 (288 bits), 404
            #              também
          }
        } = conn
      ) do
    maybe_pessoa =
      pessoas_query(id: id)
      |> one()

    case maybe_pessoa do
      nil -> http_error(:not_found) |> send_resp_json(conn)
      %Pessoa{} = pessoa -> send_resp_json(conn, 200, pessoa)
    end
  end

  def pegar_pessoa(conn) do
    http_error(:not_found)
    |> send_resp_json(conn)
  end
end
