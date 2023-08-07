# Rinha de Backend 2023Q3

Implementação da API proposta para [rinha de backend 2023Q3](https://github.com/zanfranceschi/rinha-de-backend-2023-q3) utilizando:
- [Elixir](https://elixir-lang.org) (linguagem);
- [Ecto](https://github.com/elixir-ecto/ecto) (ORM);
- [Cowboy](https://github.com/ninenines/cowboy) (servidor HTTP);
- [Plug](https://github.com/elixir-plug/plug) (middleware stack).


## Como rodar

### Docker

> **Note**
> WIP

### Docker compose

> **Note**
> WIP

### Local

Esse projeto utiliza [`asdf-vm`](https://github.com/asdf-vm/asdf) para gerenciar versão de dependecias, como Elixir e Erlang.
Caso você já tenha `asdf-vm` instalado e configurado, basta rodar o seguinte comando dentro do diretório raiz desse projeto:

```sh
asdf install
```

Para instalar as dependências do projeto, rode:

```sh
mix deps.get
```

Depois compile o projeto:

```sh
mix compile
```

E, por fim, use o seguinte comando para rodar o servidor:

```sh
mix server
```


## Testes

```txt
TAP version 13
ok       1 test GET /pessoas/:id :: 404 :: quando não existe pessoa com o dado id (Elixir.PegarPessoaTest)
ok       2 test GET /pessoas/:id :: 200 :: quando existe pessoa com o dado id (Elixir.PegarPessoaTest)
ok       3 Elixir.PegarPessoaTest
ok       4 test POST /pessoas :: 201 :: quando todos campos são válidos (stack null) (Elixir.CriarPessoaTest)
ok       5 test POST /pessoas :: 422 :: quando campo `nome` está vazio (Elixir.CriarPessoaTest)
ok       6 test POST /pessoas :: 422 :: quando `apelido` já existe (Elixir.CriarPessoaTest)
ok       7 test POST /pessoas :: 422 :: quando campo `nome` excede limite de caracteres (Elixir.CriarPessoaTest)
ok       8 test POST /pessoas :: 422 :: quando campo `apelido` está vazio (Elixir.CriarPessoaTest)
ok       9 test POST /pessoas :: 422 :: quando campo `apelido` excede limite de caracteres (Elixir.CriarPessoaTest)
ok      10 test POST /pessoas :: 422 :: quando nenhum campo é informado (Elixir.CriarPessoaTest)
ok      11 test POST /pessoas :: 201 :: quando todos campos são válidos (Elixir.CriarPessoaTest)
ok      12 test POST /pessoas :: 422 :: quando campo `dataNascimento` está vazio (Elixir.CriarPessoaTest)
ok      13 test POST /pessoas :: 422 :: quando campo `stack` possui elemento que excede limite de caracteres (Elixir.CriarPessoaTest)
ok      14 test POST /pessoas :: 422 :: quando campo `dataNascimento` term formato invalido (Elixir.CriarPessoaTest)
ok      15 test POST /pessoas :: 422 :: quando campo `nome` tem caracteres especiais (Elixir.CriarPessoaTest)
```
