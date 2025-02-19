defmodule Helpcenter.Repo.Migrations.AddArticleOnDeleteConstrainToCategories do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:comments) do
      modify :article_id, :uuid, null: false
    end

    alter table(:articles) do
      modify :category_id, :uuid, null: false
    end

    alter table(:article_feedbacks) do
      modify :article_id, :uuid, null: false
    end
  end

  def down do
    alter table(:article_feedbacks) do
      modify :article_id, :uuid, null: true
    end

    alter table(:articles) do
      modify :category_id, :uuid, null: true
    end

    alter table(:comments) do
      modify :article_id, :uuid, null: true
    end
  end
end
