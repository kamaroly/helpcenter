defmodule Helpcenter.KnowledgeBase.Tag do
  use Ash.Resource,
    domain: Helpcenter.KnowledgeBase,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "tags"
    repo Helpcenter.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false
    attribute :slug, :string

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    many_to_many :articles, Helpcenter.KnowledgeBase.Article,
      through: Helpcenter.KnowledgeBase.ArticleTag,
      source_attribute_on_join_resource: :tag_id,
      destination_attribute_on_join_resource: :article_id
  end
end
