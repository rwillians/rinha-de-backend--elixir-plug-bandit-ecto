defmodule RinhaApi.ListarPessoasPaginadoTest do
  use APICase, async: true

  @fixtures [
    %{
      "nome" => "Rafael Willians",
      "apelido" => "rwillians",
      "data_nascimento" => "1970-01-01",
      "stack" => ["Elixir", "JS", "TS", "PHP", "Ruby"]
    },
    %{
      "nome" => "João das Neves",
      "apelido" => "jsilvaneves",
      "data_nascimento" => "1970-01-01",
      "stack" => nil
      #          ^ sabe nada, joão
    },
    %{
      "nome" => "José da Silva",
      "apelido" => "jsilva",
      "data_nascimento" => "1970-01-01",
      "stack" => ["Python"]
    },
    %{
      "nome" => "Osvaildo Alfredo Machado da Silva Sauro",
      "apelido" => "oamssauro",
      "data_nascimento" => "1970-01-01",
      "stack" => ["Fortran", "JS"]
    }
  ]

  describe "GET /pessoas[?pagina=0&limite=10]" do
    setup ctx do
      %{status: 201} = conn(:post, "/pessoas", Enum.at(@fixtures, 0)) |> send_req()
      %{status: 201} = conn(:post, "/pessoas", Enum.at(@fixtures, 1)) |> send_req()
      %{status: 201} = conn(:post, "/pessoas", Enum.at(@fixtures, 2)) |> send_req()
      %{status: 201} = conn(:post, "/pessoas", Enum.at(@fixtures, 3)) |> send_req()

      {:ok, ctx}
    end

    test ":: 200 :: campo `qtd` mostra a quantidade de resultados na página" do
      conn = conn(:get, "/pessoas") |> send_req()

      assert conn.state == :sent
      assert conn.status == 200

      assert conn.body_params["qtd"] == 4
    end

    test ":: 200 :: campo `total` mostra a quantidade total de resultados existentes" do
      conn = conn(:get, "/pessoas") |> send_req()

      assert conn.state == :sent
      assert conn.status == 200

      assert conn.body_params["total"] == 4
    end

    test ":: 200 :: campo `pagina` mostra o número da página atual" do
      conn = conn(:get, "/pessoas") |> send_req()

      assert conn.state == :sent
      assert conn.status == 200

      assert conn.body_params["pagina"] == 0
    end

    test ":: 200 :: campo `anterior` mostrá o número da página anterior (se houver)" do
      conn = conn(:get, "/pessoas?pagina=0&limite=1") |> send_req()
      assert conn.state == :sent
      assert conn.status == 200
      assert conn.body_params["anterior"] == nil

      conn = conn(:get, "/pessoas?pagina=1&limite=1") |> send_req()
      assert conn.state == :sent
      assert conn.status == 200
      assert conn.body_params["anterior"] == 0
    end

    test ":: 200 :: campo `proxima` mostrá o número da proxima página (se houver)" do
      conn = conn(:get, "/pessoas?pagina=2&limite=1") |> send_req()
      assert conn.state == :sent
      assert conn.status == 200
      assert conn.body_params["proxima"] == 3

      conn = conn(:get, "/pessoas?pagina=3&limite=1") |> send_req()
      assert conn.state == :sent
      assert conn.status == 200
      assert conn.body_params["proxima"] == nil
    end

    test ":: 200 :: campo `resultados` contém os resultados" do
      conn = conn(:get, "/pessoas") |> send_req()

      assert conn.state == :sent
      assert conn.status == 200
      assert drop_id(conn.body_params["resultados"]) == @fixtures
    end

    test ":: 200 :: é possível iterar sobre as páginas" do
      conn = conn(:get, "/pessoas?pagina=2&limite=1") |> send_req()
      assert conn.state == :sent
      assert conn.status == 200
      assert conn.body_params["qtd"] == 1
      assert conn.body_params["total"] == 4
      assert conn.body_params["pagina"] == 2
      assert conn.body_params["anterior"] == 1
      assert conn.body_params["proxima"] == 3
      assert drop_id(conn.body_params["resultados"]) == [Enum.at(@fixtures, 2)]

      conn = conn(:get, "/pessoas?pagina=3&limite=1") |> send_req()
      assert conn.state == :sent
      assert conn.status == 200
      assert conn.body_params["qtd"] == 1
      assert conn.body_params["total"] == 4
      assert conn.body_params["pagina"] == 3
      assert conn.body_params["anterior"] == 2
      assert conn.body_params["proxima"] == nil
      assert drop_id(conn.body_params["resultados"]) == [Enum.at(@fixtures, 3)]

      conn = conn(:get, "/pessoas?pagina=4&limite=1") |> send_req()
      assert conn.state == :sent
      assert conn.status == 200
      assert conn.body_params["qtd"] == 0
      assert conn.body_params["total"] == 4
      assert conn.body_params["pagina"] == 4
      assert conn.body_params["anterior"] == 3
      assert conn.body_params["proxima"] == nil
      assert drop_id(conn.body_params["resultados"]) == []
    end
  end

  describe "GET /pessoas?pagina=999999" do
    setup ctx do
      %{status: 201} = conn(:post, "/pessoas", Enum.at(@fixtures, 0)) |> send_req()
      %{status: 201} = conn(:post, "/pessoas", Enum.at(@fixtures, 1)) |> send_req()
      %{status: 201} = conn(:post, "/pessoas", Enum.at(@fixtures, 2)) |> send_req()
      %{status: 201} = conn(:post, "/pessoas", Enum.at(@fixtures, 3)) |> send_req()

      {:ok, ctx}
    end

    test ":: 200 :: (página não existente) retorna o número da ultima página com conteúdo no campo 'anterior'" do
      conn = conn(:get, "/pessoas?pagina=999999&limite=1") |> send_req()

      assert conn.state == :sent
      assert conn.status == 200

      assert conn.body_params["anterior"] == 3
    end
  end

  describe "GET /pessoas?t=termo" do
    setup ctx do
      %{status: 201} = conn(:post, "/pessoas", Enum.at(@fixtures, 0)) |> send_req()
      %{status: 201} = conn(:post, "/pessoas", Enum.at(@fixtures, 1)) |> send_req()
      %{status: 201} = conn(:post, "/pessoas", Enum.at(@fixtures, 2)) |> send_req()
      %{status: 201} = conn(:post, "/pessoas", Enum.at(@fixtures, 3)) |> send_req()

      {:ok, ctx}
    end

    test ":: 200 :: é possível pesquisar pessoas por nome" do
      conn = conn(:get, "/pessoas?t=silva") |> send_req()

      assert conn.state == :sent
      assert conn.status == 200

      assert drop_id(conn.body_params["resultados"]) == [
               Enum.at(@fixtures, 2),
               Enum.at(@fixtures, 3),
               Enum.at(@fixtures, 1)
             ]
    end

    test ":: 200 :: é possível pesquisar pessoas por apelido" do
      conn = conn(:get, "/pessoas?t=jsilva") |> send_req()

      assert conn.state == :sent
      assert conn.status == 200

      assert drop_id(conn.body_params["resultados"]) == [Enum.at(@fixtures, 2), Enum.at(@fixtures, 1)]
    end

    test ":: 200 :: dá pra pesquisar por skill da stack também, mas tem que ser identico" do
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
      assert drop_id(conn.body_params["resultados"]) == []

      conn = conn(:get, "/pessoas?t=JS") |> send_req()
      assert conn.state == :sent
      assert conn.status == 200

      assert drop_id(conn.body_params["resultados"]) == [
               Enum.at(@fixtures, 3),
               #                  ^ Por que tem skill `"JS"` e por que está
               #                    ordenado por `nome ASC` como critério de
               #                    desimpate
               Enum.at(@fixtures, 0),
               #                  ^ Por que tem a skill `"JS"`
               Enum.at(@fixtures, 2),
               #                  ^ Por que tem `"js"` no apelido
               Enum.at(@fixtures, 1)
               #                  ^ Por que tem `"js"` no apelido
             ]
    end
  end

  #
  # PRIVATE
  #

  defp drop_id(acc \\ [], value)
  defp drop_id(_acc, %{} = map), do: Map.drop(map, ["id"])
  defp drop_id(acc, [head | tail]), do: [drop_id(head) | acc] |> drop_id(tail)
  defp drop_id(acc, []), do: :lists.reverse(acc)
end
