defmodule Rinha.Repo.Migrations.InitDatabase do
  use Ecto.Migration

  def change do
    create table(:pessoas, primary_key: false) do
      add :id, :string, size: 32, primary_key: true
      add :nome, :string, size: 100, null: false
      add :apelido, :string, size: 32, null: false
      add :nascimento, :date, null: false
      add :stack, {:array, :string}, default: nil
      add :pesquisa, :text, default: nil
    end

    create unique_index(:pessoas, [:apelido])
    create index(:pessoas, [:pesquisa])
    # create index(:pessoas, ["(to_tsvector('simple', pesquisa))"], using: :gin)

    # execute """
    # CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;
    # """

    # execute """
    # COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';
    # """
  end
end
