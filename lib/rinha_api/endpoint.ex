defmodule RinhaAPI.Endpoint do
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
      contar_pessoas: 1,
      criar_pessoa: 1,
      listar_pessoas: 1,
      pegar_pessoa: 1
    ]

  plug Plug.RequestId, http_header: "x-request-id"
  plug Plug.Logger
  plug Plug.Head

  plug Corsica,
    origins: "*",
    allow_methods: :all,
    allow_headers: :all,
    allow_credentials: true,
    passthrough_non_cors_requests: true,
    expose_headers: ["x-request-id"],
    max_age: 600

  plug ETag.Plug,
    generator: ETag.Generator.SHA1Base64,
    methods: ["GET", "HEAD"],
    status_codes: [200, 201, 304]

  plug Plug.Static,
    at: "/",
    from: {:rinha, "priv/static"}

  plug Plug.Parsers,
    parsers: [:urlencoded, :json],
    json_decoder: Jason

  plug :match
  plug :dispatch

  get "/ping" do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "pong!")
  end

  # region: rotas da aplicação

  get  "/pessoas", do: listar_pessoas(conn)
  post "/pessoas", do: criar_pessoa(conn)
  get  "/pessoas/:id", do: pegar_pessoa(conn)
  get  "/contagem-pessoas", do: contar_pessoas(conn)

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

  #
  # CONFIG
  #

  @doc """
  Returna lista de aplicações filhas necessárias para rodar o servidor HTTP.

  Caso a opção `:run_server?` seja passada como `false`, a lista será retornada
  vazia pois não haverá necessidade de rodar o servidor.

  ## Exemplos

    ```elixir
    opts = [port: 3000, run_server?: true]

    children =
      List.flatten([
        Rinha.Repo,
        RinhaAPI.Endpoint.children_spec(opts)
      ])

    Supervisor.start_link(children, strategy: :one_for_one)
    ```
  """
  @spec children_spec([option]) :: [Supervisor.child_spec()]

  def children_spec(opts \\ []) do
    config = RinhaAPI.Endpoint.get_config(opts)

    port = Keyword.fetch!(config, :port)
    run_server? = Keyword.fetch!(config, :run_server?)

    opts = [
      plug: RinhaAPI.Endpoint,
      scheme: :http,
      options: [port: port]
    ]

    case run_server? do
      true -> [Plug.Cowboy.child_spec(opts)]
      false -> []
    end
  end

  @typedoc false
  @type option :: {:port, pos_integer} | {:run_server?, boolean}

  @doc """
  Retorna configurações da API com a possibilidade de sobrescrever
  configurações passando uma keyword list como argument para `config/1`.
  """
  @spec get_config(opts :: [option]) :: [
          port: pos_integer,
          run_server?: boolean
        ]

  def get_config(opts \\ []) do
    Application.fetch_env!(:rinha, RinhaAPI.Endpoint)
    |> Keyword.merge(opts)
    |> Keyword.take([:port, :run_server?])
    |> Keyword.put_new(:port, 3000)
    |> Keyword.put_new(:run_server?, false)
  end

  @doc """
  Altera configurações de tempo de execução referentes à API.
  """
  @spec put_config(opts :: [option]) :: :ok

  def put_config(opts) do
    updated_config =
      Application.fetch_env!(:rinha, RinhaAPI.Endpoint)
      |> Keyword.merge(opts)
      |> Keyword.take([:port, :run_server?])

    Application.put_env(:rinha, RinhaAPI.Endpoint, updated_config)
  end
end
