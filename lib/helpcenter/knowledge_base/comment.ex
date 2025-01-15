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
    create_timestamp :created_at
  end

  relationships do
    belongs_to :article, Helpcenter.KnowledgeBase.Article,
      attribute_type: :uuid,
      allow_nil?: false
  end
end
