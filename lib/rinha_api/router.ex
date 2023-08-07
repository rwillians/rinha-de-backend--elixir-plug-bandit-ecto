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

  plug :match
  plug :dispatch

  # region: rotas da aplicação

  get "/ping" do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "pong!")
  end

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
