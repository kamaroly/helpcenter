defmodule Helpcenter.Repo.Migrations.RenameCategoryTimestampsColumns do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    rename table(:tags), :created_at, to: :inserted_at

    alter table(:tags) do
      modify :inserted_at, :utc_datetime_usec
    end

    rename table(:comments), :created_at, to: :inserted_at

    alter table(:comments) do
      modify :article_id, :uuid, null: true
      modify :inserted_at, :utc_datetime_usec

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    rename table(:categories), :created_at, to: :inserted_at

    alter table(:categories) do
      modify :inserted_at, :utc_datetime_usec
    end

    rename table(:articles), :created_at, to: :inserted_at

    alter table(:articles) do
      modify :category_id, :uuid, null: true
      modify :inserted_at, :utc_datetime_usec
    end

    alter table(:article_feedbacks) do
      modify :article_id, :uuid, null: true
    end
  end

  def down do
    alter table(:article_feedbacks) do
      modify :article_id, :uuid, null: false
    end

    alter table(:articles) do
      modify :created_at, :utc_datetime_usec
      modify :category_id, :uuid, null: false
    end

    rename table(:articles), :inserted_at, to: :created_at

    alter table(:categories) do
      modify :created_at, :utc_datetime_usec
    end

    rename table(:categories), :inserted_at, to: :created_at

    alter table(:comments) do
      remove :updated_at
      modify :created_at, :utc_datetime_usec
      modify :article_id, :uuid, null: false
    end

    rename table(:comments), :inserted_at, to: :created_at

    alter table(:tags) do
      modify :created_at, :utc_datetime_usec
    end

    rename table(:tags), :inserted_at, to: :created_at
  end
end
