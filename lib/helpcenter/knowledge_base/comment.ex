defmodule Helpcenter.KnowledgeBase.Comment do
  use Ash.Resource,
    domain: Helpcenter.KnowledgeBase,
    data_layer: AshPostgres.DataLayer,
    extensions: [Helpcenter.Extensions.AshParental]

  postgres do
    table "comments"
    repo Helpcenter.Repo
  end

  actions do
    default_accept [:content, :article_id]
    defaults [:create, :read, :update, :destroy]
  end

  preparations do
    prepare Helpcenter.Preparations.SetTenant
  end

  changes do
    change Helpcenter.Changes.SetTenant
  end

  multitenancy do
    strategy :context
  end

  attributes do
    uuid_primary_key :id
    attribute :content, :string, allow_nil?: false
    timestamps()
  end

  relationships do
    belongs_to :article, Helpcenter.KnowledgeBase.Article do
      source_attribute :article_id
      allow_nil? false
    end
  end
end
