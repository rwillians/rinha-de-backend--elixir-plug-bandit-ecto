ExUnit.configure(formatters: [Tapex])
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Rinha.Repo, :manual)
