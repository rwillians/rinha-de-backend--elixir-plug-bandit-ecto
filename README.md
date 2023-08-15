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


## Rodando com Docker Compose

A imagem OCI já está compilada e está disponível publicamente (vide endereço em `docker-compose.yaml`). O arquivo `docker-compose.yaml` incluso no projetojá está configurado de forma que cada serviço tem seus limites de recursos estabelecidos, de acordo com a regra da [rinha de backend 2023Q3](https://github.com/zanfranceschi/rinha-de-backend-2023-q3).

Para simplificar o processo de limpeza de execuções prévias, execute o seguinte comando à partir do diretório raiz da aplicação:

```sh
scripts/start
```

O script `start` irá limpar os vestígios de execuções prévias e irá iniciar a aplicação utilizando [docker compose](https://docs.docker.com/compose/compose-file/compose-file-v3/).

> **Note**
> Após as instâncias do servidor HTTP inicializar, há um período de alguns segundos de intenso uso de CPU enquato a poll de conexões com o banco de dados é inicializada. É recomendado esperar esse período acabar antes dar início os testes de desempenho.
>
> Para simplificar o projeto, não há uma mensagem clara indicando quando o sistema está pronto. A forma mais simples de fazê-lo é monitorando os containeres com [`ctop`](https://github.com/bcicen/ctop) -- quando a mensagem "starting http server..." for impressa pelas instancias da api, você verá um breve intenso uso de CPU e, então, após alguns segundos, quando a utilização de CPU zerar (ou aproximar zero), a aplicação estará pronta para ser testada.
>
> TL;DR: espere uns 15s após ver a mensagem "starting http server..." antes de iniciar o teste.


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

GET /pessoas?t=termo :: 200 :: é possível pesquisar pessoas por nome
GET /pessoas?t=termo :: 200 :: é possível pesquisar pessoas por apelido
GET /pessoas?t=termo :: 200 :: dá pra pesquisar por skill da stack também, mas tem que ser identico
```

## Teste de carga com K6

> **Warning**
> É necessário ter o CLI do `k6` instalado ([ver instruções](https://k6.io/docs/get-started/installation/) -- no macos: `brew install k6`).

Esse projeto inclui testes de carga com [K6](https://k6.io/). Para executá-los, siga os seguintes passos:

1.  **Gerar carga de teste**:

    Execute o comando `scripts/gerar-pessoas` à partir do diretório raiz da aplicação. Ele criará o arquivo `scripts/k6/pessoas.jsonl`.

2.  **Teste 1 - criar pessoas**:

    À partir do diretório `scripts/k6`, execute o comando `k6 run criar-pessoas.js`. Esse teste criará pessoas no banco de dados, possibilitando o próximo teste.

3.  **Test 2 - iterar sobre as pessoas existentes no banco de dados**:

    Também à partir do diretório `scripts/k6`, execute o comando `k6 iterar-pessoas.js`. Esse teste irá descobrir pessoas iterando sobre as páginas retornadas pela rota `/pessoas?pagina=n&limite=n` e então irá buscar individualmente o registro de cada pessoa na rota `/pessoas/:id`.
