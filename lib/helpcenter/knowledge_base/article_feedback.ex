defmodule Helpcenter.KnowledgeBase.ArticleFeedback do
  use Ash.Resource,
    domain: Helpcenter.KnowledgeBase,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "article_feedbacks"
    repo Helpcenter.Repo
  end

  actions do
    default_accept [:feedback, :helpful, :article_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    uuid_primary_key :id

    attribute :helpful, :boolean, default: false
    attribute :feedback, :string, allow_nil?: true

    create_timestamp :created_at
  end

  relationships do
    belongs_to :article, Helpcenter.KnowledgeBase.Article do
      source_attribute :article_id
    end
  end
end
