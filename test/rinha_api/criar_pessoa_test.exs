defmodule CriarPessoaTest do
  use APICase, async: true

  @fixture %{
    "nome" => "Rafael Willians",
    "apelido" => "rwillians",
    "nascimento" => "1970-01-01",
    "stack" => ["Elixir", "JS", "TS", "PHP", "Ruby"]
  }

  describe "POST /pessoas" do
    test ":: 201 :: quando todos campos são válidos" do
      conn = conn(:post, "/pessoas", @fixture) |> send_req()

      assert conn.state == :sent
      assert conn.status == 201

      ##
      # retorna o header `Location`
      assert [location] = get_resp_header(conn, "location")
      assert "/pessoas/" <> id = location
      assert id !== ""

      ##
      # o id do header location é igual ao id retornado no corpo da requisição
      assert conn.body_params["id"] == id

      ##
      # retorna o objeto pessoa criado
      assert drop_id(conn.body_params) == @fixture

      ##
      # foi persistido corretamente no banco
      pessoa = Rinha.Repo.get(Pessoa, id)

      assert not is_nil pessoa
      assert not is_nil pessoa.id
      assert pessoa.nome == @fixture["nome"]
      assert pessoa.apelido == @fixture["apelido"]
      assert pessoa.nascimento == Date.from_iso8601!(@fixture["nascimento"])
      assert pessoa.stack == @fixture["stack"]
    end

    test ":: 201 :: quando todos campos são válidos (stack null)" do
      payload = %{@fixture | "stack" => nil}

      conn = conn(:post, "/pessoas", payload) |> send_req()

      assert conn.state == :sent
      assert conn.status == 201

      ##
      # retorna `stack` como nulo
      assert is_nil conn.body_params["stack"]

      ##
      # `stack`foi persistido como nulo
      pessoa = Rinha.Repo.get(Pessoa, conn.body_params["id"])

      assert not is_nil pessoa
      assert is_nil pessoa.stack
    end

    test ":: 422 :: quando nenhum campo é informado" do
      conn = conn(:post, "/pessoas", %{}) |> send_req()

      assert conn.state == :sent
      assert conn.status == 422
    end

    test ":: 422 :: quando campo `nome` está vazio" do
      payload = %{@fixture | "nome" => ""}

      conn = conn(:post, "/pessoas", payload) |> send_req()

      assert conn.state == :sent
      assert conn.status == 422
    end

    test ":: 422 :: quando campo `nome` tem caracteres especiais" do
      payload = %{@fixture | "nome" => "Raf@el Willi@n$"}

      conn = conn(:post, "/pessoas", payload) |> send_req()

      assert conn.state == :sent
      assert conn.status == 422
    end

    test ":: 422 :: quando campo `nome` excede limite de caracteres" do
      nome = "asdfasdfasdfasdf asdfasdfasdfasdf asdfasdfasdfasdf asdfasdfasdfasdf asdfasdfasdfasdf asdfasdfasdfasdf"
      payload = %{@fixture | "nome" => nome}

      conn = conn(:post, "/pessoas", payload) |> send_req()

      assert conn.state == :sent
      assert conn.status == 422
    end

    test ":: 422 :: quando campo `apelido` está vazio" do
      payload = %{@fixture | "apelido" => ""}

      conn = conn(:post, "/pessoas", payload) |> send_req()

      assert conn.state == :sent
      assert conn.status == 422
    end

    test ":: 422 :: quando campo `apelido` excede limite de caracteres" do
      apelido = "asdfasdfasdfasdfasdfasdfasdfasdfa"
      payload = %{@fixture | "apelido" => apelido}

      conn = conn(:post, "/pessoas", payload) |> send_req()

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
      payload = %{@fixture | "nascimento" => ""}

      conn = conn(:post, "/pessoas", payload) |> send_req()

      assert conn.state == :sent
      assert conn.status == 422
    end

    test ":: 422 :: quando campo `dataNascimento` term formato invalido" do
      payload = %{@fixture | "nascimento" => "01/01/1970"}

      conn = conn(:post, "/pessoas", payload) |> send_req()

      assert conn.state == :sent
      assert conn.status == 422
    end

    test ":: 422 :: quando campo `stack` possui elemento que excede limite de caracteres" do
      payload = %{@fixture | "stack" => ["foobarstackzilla super hyper mega"]}

      conn = conn(:post, "/pessoas", payload) |> send_req()

      assert conn.state == :sent
      assert conn.status == 422
    end
  end
end
