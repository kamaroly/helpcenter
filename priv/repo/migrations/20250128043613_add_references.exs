defmodule Helpcenter.Repo.Migrations.AddReferences do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    drop constraint(:articles, "articles_category_id_fkey")

    alter table(:articles) do
      modify :category_id,
             references(:categories,
               column: :id,
               name: "articles_category_id_fkey",
               type: :uuid,
               prefix: "public",
               on_delete: :nilify_all
             )
    end
  end

  def down do
    drop constraint(:articles, "articles_category_id_fkey")

    alter table(:articles) do
      modify :category_id,
             references(:categories,
               column: :id,
               name: "articles_category_id_fkey",
               type: :uuid,
               prefix: "public",
               on_delete: :nothing
             )
    end
  end
end
