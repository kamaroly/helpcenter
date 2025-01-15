defmodule Helpcenter.KnowledgeBase.Comment do
  use Ash.Resource,
    domain: Helpcenter.KnowledgeBase,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "comments"
    repo Helpcenter.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :content, :string, allow_nil?: false
    timestamps()
  end

  relationships do
    belongs_to :article, Helpcenter.KnowledgeBase.Article do
      source_attribute :article_id
    end
  end
end
