defmodule Rinha.Pessoa.Query do

  @doc """
  Estabelece uma pontuação para cada pessoa com base em um valor pesquisado.

  A pontuação final é estabelecida pela combinação expressões menores:
  proximidade trigonométrica (requer extensão "pg_trgm" do postgres),
  proximidade vetorial (utilizando `tsvector` do postgres) e uma pontuação
  arbitrária caso o termo pesquisado seja um dos elementos da `stack` da
  pessoa.

  Tal pontuação combinada pode variar entre `0.00` e `4.15`, sendo que
  resultados assima de `0.15` já costumam ser relevantes (pode precisar
  de ajustes).

  """
  defmacro search_score(nome, apelido, stack, reasonable_score, value) do
    quote do
      fragment(
        """
        -- Compara proximidade entre o nome e o term de pesquisa
        (1 - (? <-> ?)) +

        -- Compara proximidade entre o apelido e o termo de pesquisa, porém,
        -- a pontuação é 20% menos relevante do que a pontuação da proximidade
        -- com o nome.
        ((1 - (? <-> ?)) * 0.8) +

        -- Confere se o term pesquisado é igual à um dos items da stack da
        -- pessoa. Caso seja, então incrementa a pontuação final pelo valor de
        -- `reasonable_score`, que é o valor minimo para que a linha aparece
        -- nos resultados da pesquisa.
        (
          CASE
            WHEN ? IS NOT NULL AND ? = ANY(?) THEN ? * 2.00 -- buff pra subir nos
                                                            -- resultados da pesquisa
            ELSE 0.00
          END
        )
        """,
        unquote(nome),
        unquote(value),
        unquote(apelido),
        unquote(value),
        unquote(stack),
        unquote(value),
        unquote(stack),
        unquote(reasonable_score)
      )
    end
  end
end
