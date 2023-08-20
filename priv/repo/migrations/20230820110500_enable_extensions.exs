defmodule Rinha.Repo.Migrations.EnableExtensions do
  use Ecto.Migration

  def change do
    execute """
    CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;
    """

    execute """
    COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';
    """
  end
end
