defmodule Rinha.Repo.Migrations.InitDatabase do
  use Ecto.Migration

  def change do
    create table(:pessoas, primary_key: false) do
      add :id, :uuid, autogenerate: true, primary_key: true
      add :nome, :string, size: 75, null: false
      add :apelido, :string, size: 32, null: false
      add :data_nascimento, :date, null: false
      add :stack, {:array, :string}, default: nil
    end

    create unique_index(:pessoas, [:apelido])
  end
end
