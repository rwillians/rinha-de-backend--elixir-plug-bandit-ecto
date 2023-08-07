defmodule Mix.Tasks.Server do
  @moduledoc """
  Comando para iniciar o servidor HTTP.

  O comando aceita os seguintes argumentos:
  * `-p, --port`: especifica a porta na qual o servidor HTTP escutará por
    requisições.

  """

  @shortdoc """
  Inicia o servidor HTTP
  """

  use Mix.Task

  @requirements ["app.config"]

  @options strict: [port: :integer],
           aliases: [p: :port]

  @impl Mix.Task
  def run(args) do
    {opts, [], []} = OptionParser.parse(args, @options)

    config =
      case Keyword.get(opts, :port) do
        nil -> RinhaAPI.Endpoint.get_config(run_server?: true)
        port -> RinhaAPI.Endpoint.get_config(run_server?: true, port: port)
      end

    :ok = RinhaAPI.Endpoint.put_config(config)

    port = Keyword.fetch!(config, :port)
    Mix.shell().info("🤠 Cowboy is starting on http://localhost:#{port}")

    Mix.Tasks.Run.run(run_args())
  end

  #
  # PRIVATE
  #

  # Truquezinho do Phoenix para rodar o servidor e mantelo rodando (no-halt)
  # sem que seja necessário passar a flag `--no-halt` para essa task.
  # @see {https://github.com/phoenixframework/phoenix/blob/main/lib/mix/tasks/phx.server.ex#L34-L54}
  defp run_args do
    # Se o processo estiver rodando com IEx (`iex -S mix server`), não há
    # necessidade de passar a flag `--no-halt`
    if Code.ensure_loaded?(IEx) and IEx.started?(),
      do: [],
      else: ["--no-halt"]
  end
end
