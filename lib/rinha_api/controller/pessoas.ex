defmodule RinhaAPI.Controller.Pessoas do
  @moduledoc false

  use RinhaAPI.Controller

  import Rinha.Pessoa, only: [query: 1]
  import Rinha.Repo, only: [one: 1]

  alias Rinha.Pessoa

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

  def listar_pessoas(%Plug.Conn{} = conn) do
    conn
    |> send_resp_json(200, %{
      qtd: 0,
      pagina: 0,
      anterior: nil,
      proxima: nil,
      resultados: []
    })
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
      query(id: id)
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
