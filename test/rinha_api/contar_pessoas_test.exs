defmodule ContaPessoasTest do
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

  describe "GET /contagem-pessoas" do
    test ":: 200 :: retorna quantas pessoas existem no bando de dados" do
      conn = conn(:get, "/contagem-pessoas") |> send_req()
      assert conn.state == :sent
      assert conn.status == 200
      assert conn.resp_body == "0"

      conn(:post, "/pessoas",Enum.at(@fixtures, 0)) |> send_req()

      conn = conn(:get, "/contagem-pessoas") |> send_req()
      assert conn.state == :sent
      assert conn.status == 200
      assert conn.resp_body == "1"

      conn(:post, "/pessoas", Enum.at(@fixtures, 1)) |> send_req()
      conn(:post, "/pessoas", Enum.at(@fixtures, 2)) |> send_req()
      conn(:post, "/pessoas", Enum.at(@fixtures, 3)) |> send_req()

      conn = conn(:get, "/contagem-pessoas") |> send_req()
      assert conn.state == :sent
      assert conn.status == 200
      assert conn.resp_body == "4"
    end
  end
end
