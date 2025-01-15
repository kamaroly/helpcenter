defmodule Helpcenter.KnowledgeBase.Article do
  use Ash.Resource,
    domain: Helpcenter.KnowledgeBase,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "articles"
    repo Helpcenter.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string, allow_nil?: false
    attribute :slug, :string
    attribute :content, :string
    attribute :views_count, :integer, default: 0
    attribute :published, :boolean, default: false

    timestamps()
  end

  relationships do
    belongs_to :category, Helpcenter.KnowledgeBase.Category do
      source_attribute :category_id
    end

    has_many :comments, Helpcenter.KnowledgeBase.Comment do
      destination_attribute :article_id
    end

    # Many-to-many relationship with Tag
    many_to_many :tags, Helpcenter.KnowledgeBase.Tag do
      through Helpcenter.KnowledgeBase.ArticleTag
      source_attribute_on_join_resource :article_id
      destination_attribute_on_join_resource :tag_id
    end

    has_many :article_feedbacks, Helpcenter.KnowledgeBase.ArticleFeedback do
      destination_attribute :article_id
    end
  end
end
