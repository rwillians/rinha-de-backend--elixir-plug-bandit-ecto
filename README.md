# Rinha de Backend 2023Q3

Implementação da API proposta para [rinha de backend 2023Q3](https://github.com/zanfranceschi/rinha-de-backend-2023-q3) utilizando:
* [Elixir](https://elixir-lang.org) (linguagem);
* [Ecto](https://github.com/elixir-ecto/ecto) (ORM);
* [Cowboy](https://github.com/ninenines/cowboy) (servidor HTTP);
* [Plug](https://github.com/elixir-plug/plug) (middleware stack);

Componentes da infra os quais compõe esse projeto:
* [PostgreSQL](https://www.postgresql.org) (banco de dados);
* [HAProxy](https://www.haproxy.org) (proxy reverso e balanceamento de carga);
* [Docker](https://www.docker.com) (OCI runtime engine)
* [Docker Compose (v3.8)](https://docs.docker.com/compose/compose-file/compose-file-v3/) (Infra-estrutura como código de forma declarativa).

Ferramenta de teste de stress sugerida:
* [K6](https://k6.io).


## Sumário

* [TODOs](#todo);
* [Clonando o projeto localmente](#clonando-o-projeto-localmente);
* [Buildando a imagem do projeto](#buildando-a-imagem-do-projeto-opcional)
* [Rodando com docker compose](#rodando-com-docker-compose);
* [Testes de contrato](#testes-de-contrato);
* [Teste de performance com K6](#teste-de-performance-com-k6).


## TODO

- [x] rota para adicionar pessoa;
- [x] rota para listar pessoas (paginado);
- [x] rota para pegar pessoa 👀 por id;
- [x] docker compose;
- [x] teste de stress com [K6](https://k6.io) (vide diretório `./k6` ou [repositório dedicado ao teste com K6](https://github.com/rwillians/rinha-backend-2023Q3-k6));
- [ ] pipelines para publicar imagens OCI atualizadas quando fizer merge para branch `main` (ou por release tag, TBD).


## Clonando o projeto localmente

Esse repo contem submódulos ([git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)), então utilize o seguinte comando para clonar o repositório localmente já com os submódulos inicializados:

```sh
git clone --recurse-submodules git@github.com:rwillians/rinha-backend--elixir-cowboy-ecto.git rwillians-elixir-cowboy-ecto
```


## Buildando a imagem do projeto (opcional)

Uma imagem OCI já está compilada e está disponível publicamente em `ghcr.io/rwillians/rinha-de-backend--elixir-cowboy-ecto:latest` (vide tags versionadas [aqui](https://github.com/rwillians/rinha-backend--elixir-cowboy-ecto/pkgs/container/rinha-backend--elixir-cowboy-ecto)). No entanto, caso a imagem publicada não seja compativel com a arquitetura da máquina onde pretende rodar a aplicação, você pode facilmente compilar uma nova imagem rodando o seguinte comando:

```sh
# À partir do diretório raiz do projeto
./build
```

À partir do momento que você buildar uma imagem local, sem que você faça mais nada, ela será utilizada ao invés de utilizar a que eu buildei e publiquei. Isso pode atrapalhar você utilizar uma versão mais recente publicada, portanto, se certifique de excluir as imagems `ghcr.io/rwillians/rinha-de-backend--elixir-cowboy-ecto` para que você possa utilizar uma versão mais nova publicada.

Você também pode utilizar a variável de ambiente `IMAGE_TAG` para especificar qual versão/tag da imagem publicida você quer utilizar. Por padrão, será utilizado a tag `latest`, mas você pode especificar outra versão da seguinte forma:

```sh
IMAGE_TAG="0.2.0" ./start
```


## Rodando a aplicação com Docker Compose

O arquivo `docker-compose.yaml` incluso no projeto já está configurado de forma que cada serviço tem seus limites de recursos estabelecidos, de acordo com a regra da [rinha de backend 2023Q3](https://github.com/zanfranceschi/rinha-de-backend-2023-q3) (1.5vcpu e 3GiB ao todo).

Para simplificar o processo de limpeza de execuções prévias, utilize sempre o seguinte comando para rodar a aplicação:

```sh
# À partir do diretório raiz da aplicação
./start
```

O script `start` irá limpar os vestígios de execuções prévias e irá iniciar a aplicação utilizando [docker compose](https://docs.docker.com/compose/compose-file/compose-file-v3/).

> **Note**
> Após as instâncias do servidor HTTP inicializarem, haverá um período de alguns segundos de intenso uso de CPU enquato a poll de conexões com o banco de dados é inicializada. É recomendado esperar esse período acabar antes de submeter requisições para a API.
>
> Para simplificar o projeto, não há uma mensagem clara indicando quando o sistema está pronto. A forma mais simples de identificar isso é monitorando os containeres com [`ctop`](https://github.com/bcicen/ctop) ou `docker status`. Quando a mensagem "starting http server..." for impressa pelas instancias da api, você verá um breve intenso uso de CPU e, então, após alguns segundos, quando a utilização de CPU zerar (ou aproximar zero), a aplicação estará pronta para receber requisições.
>
> TL;DR: espere uns 30s após ver a mensagem "starting http server...", somente então a aplicação estará pronta para receber requisições.


## Teste de performance com K6

Confira as instruções no reposório [rwillians/rinha-backend-2023Q3-k6](https://github.com/rwillians/rinha-backend-2023Q3-k6).

### TL;DR:

1.  **Inicie a aplicação**:

    ```sh
    ./start
    ```

2.  **Aguarde a aplicação ficar disponível para receber requisições**:

    Você pode utilizar `ctop` ou `docker stats` para acompanhar o consumo de recursos característico do boot da aplicação. Quando você ver a mensage `"starting http server..."` nos logs do docker compose, logo em seguida você vera intenso consumo de CPU em ambos os conteineres da API e no conteiner do banco de dados. Após alguns seguindos, quando o Poll de conexões iniciar todas as conexões necessários com o banco, o consumo de CPU irá normalizar em zero (ou bem próximo de zero). Quando isso acontecer, significa que a aplicação está pronta para receber requisições.

    TL;DR: quando você ver a mensagem `"starting http server..."` nos logs do docker compose, aguarde uns 30s antes de iniciar o teste.

3.  **Inicie o teste**

    Inicie o teste com a sua ferramenta de preferência.

    Esse repositório inclui teste com [K6](https://k6.io). Para executá-los, siga adicionalmente as instruções em [rwillians/rinha-backend-2023Q3-k6](https://github.com/rwillians/rinha-backend-2023Q3-k6#rodando-o-teste).


## Testes de contrato

```txt
$> MIX_ENV=test mix do ecto.drop --quiet, ecto.create --quiet, ecto.load --quiet, test --max-failures=1

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
#                ^ Olha, até caberia um 409 (conflict) aqui -- seria até legal
#                  por que eu poderia retornar o `Location` do recurso --, mas
#                  como as respostas de error dessa rota retornam todos os
#                  erros que podem ter acontecido (1+n) então achei ok mandar
#                  422 independente de quais errors foram encontrados.
#                  Numa próxima iteração, quem sabe, se o único erro for o
#                  apelido duplicado, vou considerar usar 409.

GET /pessoas/:id :: 200 :: quando existe pessoa com o dado id (Elixir.PegarPessoaTest)
GET /pessoas/:id :: 404 :: quando não existe pessoa com o dado id (Elixir.PegarPessoaTest)

GET /pessoas?t={termo} :: 400 :: quando query parameter `t` não foi informado
GET /pessoas?t={termo} :: 400 :: quando query parameter `t` está vazio
GET /pessoas?t={termo} :: 200 :: é possível pesquisar pessoas por nome
GET /pessoas?t={termo} :: 200 :: é possível pesquisar pessoas por apelido
GET /pessoas?t={termo} :: 200 :: é possível pesquisar pessoa por skill da stack

GET /pessoas?t={termo}&pagina={num}&limite={num} :: 200 :: campo `qtd` mostra a quantidade de resultados na página
GET /pessoas?t={termo}&pagina={num}&limite={num} :: 200 :: campo `total` mostra a quantidade total de resultados existentes
GET /pessoas?t={termo}&pagina={num}&limite={num} :: 200 :: campo `pagina` mostra o número da página atual
GET /pessoas?t={termo}&pagina={num}&limite={num} :: 200 :: campo `anterior` mostrá o número da página anterior (se houver)
GET /pessoas?t={termo}&pagina={num}&limite={num} :: 200 :: campo `proxima` mostrá o número da proxima página (se houver)
GET /pessoas?t={termo}&pagina={num}&limite={num} :: 200 :: campo `resultados` contém os resultados
GET /pessoas?t={termo}&pagina=99999&limite={num} :: 200 :: (página não existente) retorna o número da ultima página com conteúdo no campo 'anterior'

GET /contagem-pessoas :: 200 :: retorna quantas pessoas existem no bando de dados
```
