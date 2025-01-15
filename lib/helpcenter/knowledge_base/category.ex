defmodule Helpcenter.KnowledgeBase.Category do
  use Ash.Resource,
    domain: Helpcenter.KnowledgeBase,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "categories"
    repo Helpcenter.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false
    attribute :slug, :string
    attribute :description, :string, allow_nil?: true

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :articles, Helpcenter.KnowledgeBase.Article, destination_attribute: :category_id
  end
end
