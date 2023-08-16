defmodule RinhaApi.ListarPessoasPaginadoTest do
  use APICase, async: true

  @fixtures [
    %{
      "nome" => "Rafael Willians",
      "apelido" => "rwillians",
      "nascimento" => "1970-01-01",
      "stack" => ["Elixir", "JS", "TS", "PHP", "Ruby"]
    },
    %{
      "nome" => "João das Neves",
      "apelido" => "jsilvaneves",
      "nascimento" => "1970-01-01",
      "stack" => nil
      #          ^ sabe nada, joão
    },
    %{
      "nome" => "José da Silva",
      "apelido" => "jsilva",
      "nascimento" => "1970-01-01",
      "stack" => ["Python"]
    },
    %{
      "nome" => "Osvaildo Alfredo Machado da Silva Sauro",
      "apelido" => "oamssauro",
      "nascimento" => "1970-01-01",
      "stack" => ["Fortran", "JS"]
    }
  ]

  describe "GET /pessoas?t={termo}" do
    setup ctx do
      %{status: 201} = conn(:post, "/pessoas", Enum.at(@fixtures, 0)) |> send_req()
      %{status: 201} = conn(:post, "/pessoas", Enum.at(@fixtures, 1)) |> send_req()
      %{status: 201} = conn(:post, "/pessoas", Enum.at(@fixtures, 2)) |> send_req()
      %{status: 201} = conn(:post, "/pessoas", Enum.at(@fixtures, 3)) |> send_req()

      {:ok, ctx}
    end

    test ":: 400 :: quando query parameter `t` não foi informado" do
      conn = conn(:get, "/pessoas?pagina=0&limite=10") |> send_req()

      assert conn.state == :sent
      assert conn.status == 400
    end

    test ":: 400 :: quando query parameter `t` está vazio" do
      conn = conn(:get, "/pessoas?t=&pagina=0&limite=10") |> send_req()

      assert conn.state == :sent
      assert conn.status == 400
    end

    test ":: 200 :: é possível pesquisar pessoas por nome" do
      conn = conn(:get, "/pessoas?t=silva") |> send_req()

      assert conn.state == :sent
      assert conn.status == 200

      assert drop_id(conn.body_params["resultados"]) == [
               Enum.at(@fixtures, 1),
               Enum.at(@fixtures, 2),
               Enum.at(@fixtures, 3)
             ]
    end

    test ":: 200 :: é possível pesquisar pessoas por apelido" do
      conn = conn(:get, "/pessoas?t=jsilva") |> send_req()

      assert conn.state == :sent
      assert conn.status == 200

      assert drop_id(conn.body_params["resultados"]) == [
               Enum.at(@fixtures, 1),
               #                  ^ por que tem "jsilva" no apelido
               Enum.at(@fixtures, 2),
               #                  ^ por que tem "jsilva" no apelido
               Enum.at(@fixtures, 3)
               #                  ^ por que tem silva no nome
             ]
    end

    test ":: 200 :: é possível pesquisar pessoa por skill da stack" do
      conn = conn(:get, "/pessoas?t=Fortran") |> send_req()
      assert conn.state == :sent
      assert conn.status == 200
      assert drop_id(conn.body_params["resultados"]) == [Enum.at(@fixtures, 3)]

      conn = conn(:get, "/pessoas?t=TS") |> send_req()
      assert conn.state == :sent
      assert conn.status == 200
      assert drop_id(conn.body_params["resultados"]) == [Enum.at(@fixtures, 0)]

      conn = conn(:get, "/pessoas?t=ts") |> send_req()
      assert conn.state == :sent
      assert conn.status == 200
      assert drop_id(conn.body_params["resultados"]) == [Enum.at(@fixtures, 0)]

      conn = conn(:get, "/pessoas?t=JS") |> send_req()
      assert conn.state == :sent
      assert conn.status == 200

      assert drop_id(conn.body_params["resultados"]) == [
               Enum.at(@fixtures, 0),
               #                  ^ Por que tem a skill `"JS"`
               Enum.at(@fixtures, 1),
               #                  ^ Por que tem `"js"` no apelido
               Enum.at(@fixtures, 2),
               #                  ^ Por que tem `"js"` no apelido
               Enum.at(@fixtures, 3)
               #                  ^ Por que tem skill `"JS"`
             ]
    end
  end

  describe "GET /pessoas?t={termo}&pagina={num}&limite={num}" do
    setup ctx do
      %{status: 201} = conn(:post, "/pessoas", Enum.at(@fixtures, 0)) |> send_req()
      %{status: 201} = conn(:post, "/pessoas", Enum.at(@fixtures, 1)) |> send_req()
      %{status: 201} = conn(:post, "/pessoas", Enum.at(@fixtures, 2)) |> send_req()
      %{status: 201} = conn(:post, "/pessoas", Enum.at(@fixtures, 3)) |> send_req()

      {:ok, ctx}
    end

    test ":: 200 :: campo `qtd` mostra a quantidade de resultados na página" do
      conn = conn(:get, "/pessoas?t=js") |> send_req()

      assert conn.state == :sent
      assert conn.status == 200

      assert conn.body_params["qtd"] == 4
    end

    test ":: 200 :: campo `total` mostra a quantidade total de resultados existentes" do
      conn = conn(:get, "/pessoas?t=silva&limite=1") |> send_req()

      assert conn.state == :sent
      assert conn.status == 200

      assert conn.body_params["qtd"] == 1
      assert conn.body_params["total"] == 3
    end

    test ":: 200 :: campo `pagina` mostra o número da página atual" do
      conn = conn(:get, "/pessoas?page=0&limite=1&t=js") |> send_req()

      assert conn.state == :sent
      assert conn.status == 200

      assert conn.body_params["pagina"] == 0
    end

    test ":: 200 :: campo `anterior` mostrá o número da página anterior (se houver)" do
      conn = conn(:get, "/pessoas?pagina=0&limite=1&t=js") |> send_req()
      assert conn.state == :sent
      assert conn.status == 200
      assert conn.body_params["anterior"] == nil

      conn = conn(:get, "/pessoas?pagina=1&limite=1&t=js") |> send_req()
      assert conn.state == :sent
      assert conn.status == 200
      assert conn.body_params["anterior"] == 0
    end

    test ":: 200 :: campo `proxima` mostrá o número da proxima página (se houver)" do
      conn = conn(:get, "/pessoas?pagina=1&limite=1&t=silva") |> send_req()
      assert conn.state == :sent
      assert conn.status == 200
      assert conn.body_params["proxima"] == 2

      conn = conn(:get, "/pessoas?pagina=2&limite=1&t=silva") |> send_req()
      assert conn.state == :sent
      assert conn.status == 200
      assert conn.body_params["proxima"] == nil
    end

    test ":: 200 :: campo `resultados` contém os resultados" do
      conn = conn(:get, "/pessoas?pagina=0&limite=10&t=js") |> send_req()

      assert conn.state == :sent
      assert conn.status == 200
      assert drop_id(conn.body_params["resultados"]) == @fixtures
    end
  end

  describe "GET /pessoas?t={termo}&pagina=99999&limite={num}" do
    setup ctx do
      %{status: 201} = conn(:post, "/pessoas", Enum.at(@fixtures, 0)) |> send_req()
      %{status: 201} = conn(:post, "/pessoas", Enum.at(@fixtures, 1)) |> send_req()
      %{status: 201} = conn(:post, "/pessoas", Enum.at(@fixtures, 2)) |> send_req()
      %{status: 201} = conn(:post, "/pessoas", Enum.at(@fixtures, 3)) |> send_req()

      {:ok, ctx}
    end

    test ":: 200 :: retorna o número da ultima página que tem conteúdo no campo 'anterior'" do
      conn = conn(:get, "/pessoas?pagina=99999&limite=1&t=silva") |> send_req()

      assert conn.state == :sent
      assert conn.status == 200

      assert conn.body_params["anterior"] == 2
    end
  end
end
