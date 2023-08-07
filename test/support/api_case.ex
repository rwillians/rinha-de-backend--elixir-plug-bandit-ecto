defmodule APICase do
  use ExUnit.CaseTemplate

  import Plug.Conn

  using do
    quote do
      use Plug.Test

      import Ecto.Query
      import unquote(__MODULE__)

      alias Rinha.Repo
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Rinha.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Rinha.Repo, {:shared, self()})
    end

    :ok
  end

  @doc """
  Envia uma request para a aplicação Plug.
  """
  @spec send_req(Plug.Conn.t()) :: Plug.Conn.t()

  @opts RinhaAPI.Router.init([])

  def send_req(conn) do
    conn = RinhaAPI.Router.call(conn, @opts)

    case get_resp_header(conn, "content-type") do
      ["application/json" <> _] ->
        %{conn | body_params: Jason.decode!(conn.resp_body)}
        #        ^ hacky yea!

      _ ->
        conn
    end
  end
end
