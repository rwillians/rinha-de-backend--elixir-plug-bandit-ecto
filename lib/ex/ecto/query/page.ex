defmodule Ex.Ecto.Query.Page do
  @moduledoc false

  @typedoc """
  Estrutura representando uma página de resultados de uma query paginada.

  ## Campos

    - `qtd` (integer): quantidade de resultados retornados na página;
    - `total` (integer): quantidade total de resultados existentes;
    - `pagina` (integer): o número da página de resultados (zero-based);
    - `anterior` (integer): o número da página anterior, se houver;
    - `proxima` (integer): o número da próxima página, se houver;
    - `resultados` (lista de objetos): os resultados da página atual, se houver.

  """
  @type t :: %Ex.Ecto.Query.Page{
    qtd: pos_integer,
    total: pos_integer,
    pagina: pos_integer,
    anterior: pos_integer | nil,
    proxima: pos_integer | nil,
    resultados: [term]
  }

  @derive {Jason.Encoder, []}
  defstruct [:qtd, :total, :pagina, :anterior, :proxima, :resultados]
end
