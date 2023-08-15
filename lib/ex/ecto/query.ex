defmodule Ex.Ecto.Query do
  @moduledoc """
  Funcionalidades extendidas para o módulo `Ecto.Query`.
  """

  import Ecto.Query
  import Enum, only: [to_list: 1]
  import Keyword, only: [fetch!: 2, put_new: 3, split: 2]
  import Rinha.Repo, only: [all: 1, one: 1]
  import String, only: [to_integer: 2]

  alias Ex.Ecto.Query.Page

  @default_max_page_size 50

  @doc """
  Função a qual, dado uma keyword list de filtros e uma função de query
  builder, retorna resultado paginado da query resultado do query builder.

  O controle de paginação é feito à partir dos seguintes campos opcionais nos
  filtros:

  - `pagina` (integer): o número da página desejada (zero-based -- default `0`);
  - `limite` (integer): a quantidade máxima de resultado em cada páxina (default #{@default_max_page_size}).

  """
  @spec paginated(
          filters :: keyword | map,
          query_builder :: (keyword -> Ecto.Queryable.t())
        ) :: Page.t()

  def paginated(filters, query_builder)
      when is_list(filters) and is_function(query_builder, 1) do
    {pagination_control, filters} =
      filters
      |> put_new(:pagina, 0)
      |> put_new(:limite, @default_max_page_size)
      |> split([:pagina, :limite])

    page = fetch!(pagination_control, :pagina) |> maybe_to_integer()
    limit = fetch!(pagination_control, :limite) |> maybe_to_integer()
    offset = page * limit

    query = query_builder.(filters)

    total_count =
      query
      |> exclude(:order_by)
      |> exclude(:select)
      |> select([_], count(fragment("1")))
      |> one()

    with {:page_exists?, true} <- {:page_exists?, offset < total_count} do
      #               ^ É pra rodar a segunds query apenas se soubermos que
      #                 há conteúdo pra ser retornado. Se o offset for maior
      #                 do que o número total de pessoas filtradas, não tem
      #                 o por que rodar a segunda query.
      page_results = from(row in query, limit: ^limit, offset: ^offset) |> all()
      page_results_count = length(page_results)

      progress_count = page_results_count + offset

      %Page{
        qtd: page_results_count,
        total: total_count,
        pagina: page,
        anterior: if(offset > 0, do: page - 1),
        proxima: if(total_count > progress_count, do: page + 1),
        resultados: page_results
      }
    else
      {:page_exists?, false} ->
        last_page_with_contents =
          if total_count > 0,
            do: Float.ceil(total_count / limit) - 1

        %Page{
          qtd: 0,
          total: total_count,
          pagina: page,
          anterior: last_page_with_contents,
          proxima: nil,
          resultados: []
        }
    end
  end

  def paginated(%{} = filters, query_builder),
    do: to_list(filters) |> paginated(query_builder)

  #
  # PRIVATE
  #

  defp maybe_to_integer(<<_, _::binary>> = str), do: to_integer(str, 10)
  defp maybe_to_integer(num) when is_integer(num), do: num
end
