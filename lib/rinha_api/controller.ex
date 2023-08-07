defmodule RinhaAPI.Controller do
  @moduledoc false

  import Enum, only: [group_by: 3, into: 2]
  import Plug.Conn, only: [put_resp_content_type: 2, send_resp: 3]

  @typedoc false
  @type error :: %{
          code: String.t(),
          message: String.t(),
          details: map
        }

  @typedoc false
  @type http_error_alias ::
          :bad_request
          | :not_found
          | :validation_error
          | :internal_server_error

  defmacro __using__(_) do
    quote do
      import Plug.Conn
      import unquote(__MODULE__)
    end
  end

  @doc """
  Envia uma resposta ao cliente contendo JSON no corpo da resposta.
  """
  @spec send_resp_json(Plug.Conn.t(), 100..599, map | struct | [map | struct]) :: no_return
  @spec send_resp_json({100..599, map | struct | [map | struct]}, Plug.Conn) :: no_return

  def send_resp_json(conn, status_code, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status_code, Jason.encode!(body))
  end

  def send_resp_json({status_code, error}, conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status_code, Jason.encode!(error))
  end

  @doc """
  Gera uma erro padronizado para os erros HTTP mais comuns utilizados por essa
  API.
  """
  @spec http_error(http_error_alias, params :: term) :: error

  def http_error(status_code, params \\ nil)

  def http_error(:bad_request, details) do
    {400,
     %{
       code: "REQUISICAO_INVALIDA",
       message: "O corpo da requisição é invalida ou utiliza um formato o qual não é suportado.",
       details: details
     }}
  end

  def http_error(:not_found, details) do
    {404,
     %{
       code: "NAO_ENCONTRADO",
       message: "O recurso solicitado não existe ou foi removido.",
       details: details
     }}
  end

  def http_error(:validation_error, %Ecto.Changeset{} = changeset) do
    errors_by_field =
      changeset.errors
      |> group_by(fn {field, _value} -> field end,
                  fn {_field, value} -> to_validation_error(value) end)
      |> into(%{})

    {422,
     %{
       code: "ERRO_VALIDACAO",
       message: "Um ou mais campos e/ou parametros falharam na validação.",
       details: %{
         fields: errors_by_field
       }
     }}
  end

  def http_error(:internal_server_error, details) do
    {500,
     %{
       code: "ERRO_INTERNAL_SERVIDOR",
       message: "Ops, ocorreu um erro do nosso lado :eyes:",
       details: details
     }}
  end

  #
  # PRIVATE
  #

  # a mensagem não pode ser uma string vazia
  defp to_validation_error({<<_, _::binary>> = msg, details})
       when is_list(details),
       do: %{message: msg, details: into(details, %{})}

  defp to_validation_error(<<_, _::binary>> = msg),
    do: %{message: msg, details: %{}}
end
