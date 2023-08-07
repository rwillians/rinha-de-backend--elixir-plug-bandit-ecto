defmodule RinhaAPI.Router do
  @moduledoc false

  require Logger

  use Plug.Router, init_mode: :compile
  use Plug.ErrorHandler

  import RinhaAPI.Controller,
    only: [
      http_error: 1,
      send_resp_json: 2
    ]

  import RinhaAPI.Controller.Pessoas,
    only: [
      criar_pessoa: 1,
      listar_pessoas: 1,
      pegar_pessoa: 1
    ]

  plug :match
  plug :dispatch

  # region: rotas da aplicação

  get "/ping" do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "pong!")
  end

  get  "/pessoas", do: listar_pessoas(conn)
  post "/pessoas", do: criar_pessoa(conn)
  get  "/pessoas/:id", do: pegar_pessoa(conn)

  # endregion

  match _ do
    Logger.warning("#{conn.method} #{conn.request_path} :: unknown resource requested")

    http_error(:not_found)
    |> send_resp_json(conn)
  end

  @impl Plug.ErrorHandler
  def handle_errors(conn, %{kind: :error, reason: %Plug.Parsers.ParseError{}}) do
    http_error(:bad_request)
    |> send_resp_json(conn)
  end

  def handle_errors(conn, _) do
    http_error(:internal_server_error)
    |> send_resp_json(conn)
  end
end
