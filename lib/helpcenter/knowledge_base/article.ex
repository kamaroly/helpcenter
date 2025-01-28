defmodule Helpcenter.KnowledgeBase.Article do
  require Ash.Resource.Change.Builtins

  use Ash.Resource,
    domain: Helpcenter.KnowledgeBase,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "articles"
    repo Helpcenter.Repo

    # 1. Tell Ash what happens in the case a category related to this article is deleted
    references do
      reference :category, on_delete: :nilify
    end
  end

  actions do
    default_accept [
      :title,
      :slug,
      :content,
      :views_count,
      :published,
      # <-- Added for category relationsihp
      :category_id
    ]

    defaults [:create, :read, :update]

    create :create_with_category do
      description "Create an article and its category at the same time"
      argument :category_attrs, :map, allow_nil?: false
      change manage_relationship(:category_attrs, :category, type: :create)
    end

    create :create_with_comment do
      description "Create article with a comment."
      argument :comment, :map, allow_nil?: false
      change manage_relationship(:comment, :comments, type: :create)
    end

    create :create_with_tags do
      description "Create an article with tags"
      argument :tags, {:array, :map}, allow_nil?: false

      change manage_relationship(:tags, :tags,
               on_no_match: :create,
               on_match: :ignore,
               on_missing: :create
             )
    end

    update :add_comment do
      description "Add a comment to an article"
      require_atomic? false
      argument :comment, :map, allow_nil?: false
      change manage_relationship(:comment, :comments, type: :create)
    end

    update :add_feedback do
      description "Add a feedback to an article"
      require_atomic? false
      argument :feedback, :map, allow_nil?: false
      change manage_relationship(:feedback, :feedbacks, type: :create)
    end

    destroy :destroy do
      description "Destroy article and its comments"

      # Make this action primary. It can be called with Ash.destroy without
      # having to mention the action to use
      primary? true
      require_atomic? false

      # Before this action is executed, we'll need to delete corresponding
      # comments
      change before_action(fn changeset, context ->
               # We need Ash.Query to allow filtering
               require Ash.Query

               # Find all comments related to this article
               %Ash.BulkResult{status: :success} =
                 Helpcenter.KnowledgeBase.Comment
                 |> Ash.Query.filter(article_id == ^changeset.data.id)
                 |> Ash.read!()

                 #  Bulk delete all comments related to this article
                 |> Ash.bulk_destroy(:destroy, condition = %{}, batch_size: 100)

               changeset
             end)
    end
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
      # category_id can be null when there is no related category
      allow_nil? true
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

    has_many :feedbacks, Helpcenter.KnowledgeBase.ArticleFeedback do
      destination_attribute :article_id
    end
  end
end
