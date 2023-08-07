defmodule CriarPessoaTest do
  use APICase, async: true

  @fixture %{
    nome: "Rafael Willians",
    apelido: "rwillians",
    data_nascimento: "1970-01-01",
    stack: ["Elixir", "JS", "TS", "PHP", "Ruby"]
  }

  describe "POST /pessoas" do
    test ":: 201 :: quando todos campos são válidos" do
      conn = conn(:post, "/pessoas", @fixture) |> send_req()

      assert conn.state == :sent
      assert conn.status == 201
      assert [location] = get_resp_header(conn, "location")
      assert "/pessoas/" <> id = location
      assert id !== ""

      # retorna o objeto pessoa criado
      assert conn.body_params["nome"] == @fixture.nome
      assert conn.body_params["apelido"] == @fixture.apelido
      assert conn.body_params["data_nascimento"] == @fixture.data_nascimento
      assert conn.body_params["stack"] == @fixture.stack

      # foi persistido corretamente no banco
      pessoa = Rinha.Repo.get(Rinha.Pessoa, id)

      assert not is_nil pessoa
      assert pessoa.nome == @fixture.nome
      assert pessoa.apelido == @fixture.apelido
      assert pessoa.data_nascimento == Date.from_iso8601!(@fixture.data_nascimento)
      assert pessoa.stack == @fixture.stack
    end

    test ":: 201 :: quando todos campos são válidos (stack null)" do
      conn = conn(:post, "/pessoas", %{@fixture | stack: nil}) |> send_req()

      assert conn.state == :sent
      assert conn.status == 201
      assert [location] = get_resp_header(conn, "location")
      assert "/pessoas/" <> id = location
      assert id !== ""

      pessoa = Rinha.Repo.get(Rinha.Pessoa, id)

      assert not is_nil pessoa
      assert pessoa.stack == nil
    end

    test ":: 422 :: quando nenhum campo é informado" do
      conn = conn(:post, "/pessoas", %{}) |> send_req()

      assert conn.state == :sent
      assert conn.status == 422
    end

    test ":: 422 :: quando campo `nome` está vazio" do
      conn = conn(:post, "/pessoas", %{@fixture | nome: ""}) |> send_req()

      assert conn.state == :sent
      assert conn.status == 422
    end

    test ":: 422 :: quando campo `nome` tem caracteres especiais" do
      conn = conn(:post, "/pessoas", %{@fixture | nome: "Raf@el Willi@n$"}) |> send_req()

      assert conn.state == :sent
      assert conn.status == 422
    end

    test ":: 422 :: quando campo `nome` excede limite de caracteres" do
      nome = "asdfasdfasdfasdf asdfasdfasdfasdf asdfasdfasdfasdf asdfasdfasdfasdf asdfasdf"
      conn = conn(:post, "/pessoas", %{@fixture | nome: nome}) |> send_req()

      assert conn.state == :sent
      assert conn.status == 422
    end

    test ":: 422 :: quando campo `apelido` está vazio" do
      conn = conn(:post, "/pessoas", %{@fixture | apelido: ""}) |> send_req()

      assert conn.state == :sent
      assert conn.status == 422
    end

    test ":: 422 :: quando campo `apelido` excede limite de caracteres" do
      apelido = "asdfasdfasdfasdfasdfasdfasdfasdfa"
      conn = conn(:post, "/pessoas", %{@fixture | apelido: apelido}) |> send_req()

      assert conn.state == :sent
      assert conn.status == 422
    end

    test ":: 422 :: quando `apelido` já existe" do
      conn1 = conn(:post, "/pessoas", @fixture) |> send_req()

      assert conn1.state == :sent
      assert conn1.status == 201

      conn2 = conn(:post, "/pessoas", @fixture) |> send_req()

      assert conn2.state == :sent
      assert conn2.status == 422
    end

    test ":: 422 :: quando campo `dataNascimento` está vazio" do
      conn = conn(:post, "/pessoas", %{@fixture | data_nascimento: ""}) |> send_req()

      assert conn.state == :sent
      assert conn.status == 422
    end

    test ":: 422 :: quando campo `dataNascimento` term formato invalido" do
      conn = conn(:post, "/pessoas", %{@fixture | data_nascimento: "01/01/1970"}) |> send_req()

      assert conn.state == :sent
      assert conn.status == 422
    end

    test ":: 422 :: quando campo `stack` possui elemento que excede limite de caracteres" do
      conn = conn(:post, "/pessoas", %{@fixture | stack: ["foobarstackzilla"]}) |> send_req()

      assert conn.state == :sent
      assert conn.status == 422
    end
  end
end
