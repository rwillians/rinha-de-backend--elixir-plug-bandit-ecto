defmodule PegarPessoaTest do
  use APICase, async: true

  @fixture %{
    nome: "Rafael Willians",
    apelido: "rwillians",
    data_nascimento: "1970-01-01",
    stack: ["Elixir", "JS", "TS", "PHP", "Ruby"]
  }

  setup do
    conn = conn(:post, "/pessoas", @fixture) |> send_req()

    :sent               = conn.state
    201                 = conn.status
    ["/pessoas/" <> id] = get_resp_header(conn, "location")

    [fixture_id: id]
  end

  describe "GET /pessoas/:id" do
    test ":: 200 :: quando existe pessoa com o dado id", ctx do
      conn = conn(:get, "/pessoas/" <> ctx.fixture_id) |> send_req()

      assert conn.state == :sent
      assert conn.status == 200

      assert conn.body_params["nome"] == @fixture.nome
      assert conn.body_params["apelido"] == @fixture.apelido
      assert conn.body_params["data_nascimento"] == @fixture.data_nascimento
      assert conn.body_params["stack"] == @fixture.stack
    end

    test ":: 404 :: quando não existe pessoa com o dado id" do
      conn = conn(:get, "/pessoas/123123") |> send_req()

      assert conn.state == :sent
      assert conn.status == 404
    end
  end
end
