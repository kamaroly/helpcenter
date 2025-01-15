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
    # Use :string if short text; :text if your content might be large.
    attribute :content, :string
    attribute :views_count, :integer, default: 0
    attribute :published, :boolean, default: false

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :category, Helpcenter.KnowledgeBase.Category,
      allow_nil?: false,
      attribute_type: :uuid

    has_many :comments, Helpcenter.KnowledgeBase.Comment

    # Many-to-many relationship with Tag
    many_to_many :tags, Helpcenter.KnowledgeBase.Tag,
      through: Helpcenter.KnowledgeBase.ArticleTag,
      source_attribute_on_join_resource: :article_id,
      destination_attribute_on_join_resource: :tag_id

    has_many :article_feedbacks, Helpcenter.KnowledgeBase.ArticleFeedback
  end
end
