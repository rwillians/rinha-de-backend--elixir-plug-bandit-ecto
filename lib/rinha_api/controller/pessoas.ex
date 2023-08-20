defmodule RinhaAPI.Controller.Pessoas do
  @moduledoc false

  use RinhaAPI.Controller

  import Enum, only: [to_list: 1]
  import Ex.Ecto.Query, only: [paginated: 2]
  import Keyword, only: [get: 2]
  import Map, only: [take: 2]
  import Pessoa, only: [changeset: 2, pessoas_query: 1]
  import Rinha.Repo, only: [insert: 1, one: 1]
  import String, only: [to_atom: 1]

  @doc """
  Endpoint para criação de uma nova pessoa :eyes:
  """
  def criar_pessoa(conn) do
    changeset = changeset(%Pessoa{}, conn.body_params)

    case insert(changeset) do
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
  Lista de forma paginada todas a pessoas existentes no banco de dados. Aceita os seguintes filtros:

  - `pagina` (integer, opcional): o número da página a ser retornada (zero-based -- valor padrão é `0`);
  - `limite` (integer, opcional): o número máximo de resultados a ser retornado na página (zero-based -- valor padrão é `50`);
  - `q` (string, opcional): um termo de pesquisa o qual será à ambos nome e apelido em `Pessoa`.

  """
  @missing_t_error_detials %{fields: %{t: "faltou o query parameter `t` ai"}}
  def listar_pessoas(conn) do
    params =
      conn.query_params
      |> take(["pagina", "limite", "t"])
      |> to_keyword_list()

    case get(params, :t) do
      # ↓  string e deve conter pelo menos 1 caractere
      <<_, _::binary>> ->
        {200, paginated(params, &pessoas_query/1)}
        |> send_resp_json(conn)

      _ ->
        http_error(:bad_request, @missing_t_error_detials)
        |> send_resp_json(conn)
    end
  end

  @doc """
  Pega uma pessoa 👀 dado seu id como parametro de URL.
  """
  def pegar_pessoa(%{params: %{"id" => <<_::256>> = id}} = conn) do
    #                                       ^ se não tiver o tamanho esperado
    #                                         de um id (256 bytes, 32 hex chars),
    #                                         então ignora a request e mete um
    #                                         404.

    maybe_pessoa =
      pessoas_query(id: id)
      |> one()

    case maybe_pessoa do
      nil -> http_error(:not_found) |> send_resp_json(conn)
      %Pessoa{} = pessoa -> send_resp_json(conn, 200, pessoa)
    end
  end

  def pegar_pessoa(conn), do: http_error(:not_found) |> send_resp_json(conn)

  @doc """
  Retorna a contagem de quantas pessoas existem no banco de dados.
  """
  def contar_pessoas(conn) do
    page = paginated([pagina: 0, limite: 0], &pessoas_query/1)

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "#{page.total}")
  end

  #
  # PRIVATE
  #

  defp to_keyword_list(%{} = map), do: to_keyword_list(to_list(map), [])
  defp to_keyword_list([{k, v} | tail], acc), do: to_keyword_list(tail, [{to_atom(k), v} | acc])
  defp to_keyword_list([], acc), do: acc
end
