defmodule Helpcenter.KnowledgeBase.Tag do
  use Ash.Resource,
    domain: Helpcenter.KnowledgeBase,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "tags"
    repo Helpcenter.Repo
  end

  actions do
    default_accept [:name]
    defaults [:create, :read, :update, :destroy]
  end

  multitenancy do
    strategy :context
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    timestamps()
  end

  relationships do
    many_to_many :articles, Helpcenter.KnowledgeBase.Article do
      through Helpcenter.KnowledgeBase.ArticleTag
      source_attribute_on_join_resource :tag_id
      destination_attribute_on_join_resource :article_id
    end
  end
end
