defmodule RinhaAPI.Endpoint do
  @moduledoc false

  require Logger

  use Plug.Router, init_mode: :compile

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

  plug Plug.Static,
    at: "/",
    from: {:rinha, "priv/static"}

  plug Plug.Parsers,
    parsers: [:urlencoded, :json],
    json_decoder: Jason

  plug ETag.Plug,
    generator: ETag.Generator.SHA1Base64,
    methods: ["GET", "HEAD"],
    status_codes: [200, 201, 304]

  plug :match
  plug :dispatch

  forward "/", to: RinhaAPI.Router

  #

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
