defmodule Helpcenter.KnowledgeBase.ArticleTag do
  use Ash.Resource,
    domain: Helpcenter.KnowledgeBase,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "article_tags"
    repo Helpcenter.Repo
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :article, Helpcenter.KnowledgeBase.Article,
      attribute_type: :uuid,
      allow_nil?: false

    belongs_to :tag, Helpcenter.KnowledgeBase.Tag,
      attribute_type: :uuid,
      allow_nil?: false
  end
end
