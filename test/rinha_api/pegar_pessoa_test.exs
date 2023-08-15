defmodule PegarPessoaTest do
  use APICase, async: true

  @fixture %{
    "nome" => "Rafael Willians",
    "apelido" => "rwillians",
    "nascimento" => "1970-01-01",
    "stack" => ["Elixir", "JS", "TS", "PHP", "Ruby"]
  }

  setup do
    conn = conn(:post, "/pessoas", @fixture) |> send_req()

    assert conn.state == :sent
    assert conn.status == 201
    ["/pessoas/" <> id] = get_resp_header(conn, "location")

    [fixture_id: id]
  end

  describe "GET /pessoas/:id" do
    test ":: 200 :: quando existe pessoa com o dado id", ctx do
      conn = conn(:get, "/pessoas/" <> ctx.fixture_id) |> send_req()

      assert conn.state == :sent
      assert conn.status == 200

      assert drop_id(conn.body_params) == @fixture
    end

    test ":: 404 :: quando não existe pessoa com o dado id" do
      conn = conn(:get, "/pessoas/123123") |> send_req()

      assert conn.state == :sent
      assert conn.status == 404
    end
  end
end
