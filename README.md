# Rinha de Backend 2023Q3

Implementação da API proposta para [rinha de backend 2023Q3](https://github.com/zanfranceschi/rinha-de-backend-2023-q3) utilizando:
- [Elixir](https://elixir-lang.org) (linguagem);
- [Ecto](https://github.com/elixir-ecto/ecto) (ORM);
- [Cowboy](https://github.com/ninenines/cowboy) (servidor HTTP);
- [Plug](https://github.com/elixir-plug/plug) (middleware stack).


## TODO

- [x] rota para adicionar pessoa;
- [x] rota para listar pessoas (paginado);
- [x] rota para pegar pessoa 👀 por id;
- [x] docker compose;
- [ ] pipelines para publicar imagens OCI atualizadas quando fizer merge para branch `main`.


## Como rodar

### Docker compose

A imagem OCI já está compilada e está disponível publicamente (vide endereço em `"docker-compose.yaml"`).
O `"docker-compose.yaml"`já está configurado com limites de recursos os quais podem ser utilizados da máquina hospedeira (4 cores de CPU e 4GB de memória RAM, ao todo) e também define a quantidade de replicas para cada serviço.

Portanto, a unica coisa que você precisa fazer é rodar up:

```sh
docker compose up
```

Por padrão, o load balancer será exposto na porta `8080`. Essa configuração poderá ser alterado definindo a variável de ambiente `LB_PORT` com o número da porta desejada. Por exemplo:

```sh
LB_PORT=8888 docker compose up
```

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


## Testes de contrato

```txt
POST /pessoas :: 201 :: quando todos campos são válidos
POST /pessoas :: 201 :: quando todos campos são válidos (stack null)
POST /pessoas :: 422 :: quando nenhum campo é informado
POST /pessoas :: 422 :: quando campo `nome` está vazio
POST /pessoas :: 422 :: quando campo `nome` tem caracteres especiais
POST /pessoas :: 422 :: quando campo `nome` excede limite de caracteres
POST /pessoas :: 422 :: quando campo `dataNascimento` está vazio
POST /pessoas :: 422 :: quando campo `dataNascimento` term formato invalido
POST /pessoas :: 422 :: quando campo `stack` possui elemento que excede limite de caracteres
POST /pessoas :: 422 :: quando campo `apelido` está vazio
POST /pessoas :: 422 :: quando campo `apelido` excede limite de caracteres
POST /pessoas :: 422 :: quando `apelido` já existe
#                ^ Olha, até caberia um 409 (conflict) aqui, mas como a
#                  resposta contém os erros de validação de todos os campos
#                  (1+n) então achei mais adequado mandar 422 independente de
#                  quais errors foram encontrados.

GET /pessoas/:id :: 200 :: quando existe pessoa com o dado id
GET /pessoas/:id :: 404 :: quando não existe pessoa com o dado id

GET /pessoas[?pagina=0&limite=10] :: 200 :: campo `qtd` mostra a quantidade de resultados na página
GET /pessoas[?pagina=0&limite=10] :: 200 :: campo `total` mostra a quantidade total de resultados existentes
GET /pessoas[?pagina=0&limite=10] :: 200 :: campo `pagina` mostra o número da página atual
GET /pessoas[?pagina=0&limite=10] :: 200 :: campo `anterior` mostrá o número da página anterior (se houver)
GET /pessoas[?pagina=0&limite=10] :: 200 :: campo `proxima` mostrá o número da proxima página (se houver)
GET /pessoas[?pagina=0&limite=10] :: 200 :: campo `resultados` contém os resultados
GET /pessoas[?pagina=0&limite=10] :: 200 :: é possível iterar sobre as páginas
GET /pessoas?pagina=999999        :: 200 :: (página não existente) retorna o número da ultima página com conteúdo no campo 'anterior'

GET /pessoas?q=termo :: 200 :: é possível pesquisar pessoas por nome
GET /pessoas?q=termo :: 200 :: é possível pesquisar pessoas por apelido
GET /pessoas?q=termo :: 200 :: dá pra pesquisar por skill da stack também, mas tem que ser identico
```
