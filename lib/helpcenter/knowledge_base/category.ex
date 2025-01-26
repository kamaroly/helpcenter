defmodule Helpcenter.KnowledgeBase.Category do
  use Ash.Resource,
    # <-- Tell Ash that this resource belongs to KnowledgeBase domain
    domain: Helpcenter.KnowledgeBase,
    data_layer: AshPostgres.DataLayer

  postgres do
    # <-- Tell Ash that this resource data is stored in a table named "categories"
    table "categories"
    # <-- Tell Ash that this resource access data storage via Helpcenter.Repo
    repo Helpcenter.Repo
  end

  actions do
    default_accept [:name, :slug, :description]
    defaults [:create, :read, :update, :destroy]

    create :create_with_article do
      description "Create a Category and an article under it"
      argument :article_attrs, :map, allow_nil?: false
      change manage_relationship(:article_attrs, :articles, type: :create)
    end

    update :add_article do
      description "Add an article under a specified category"
      require_atomic? false
      argument :article_attrs, :map, allow_nil?: false
      change manage_relationship(:article_attrs, :articles, type: :create)
    end
  end

  # Tell Ash what columns or attributes this resource has and their types and validations
  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false
    attribute :slug, :string
    attribute :description, :string, allow_nil?: true

    timestamps()
  end

  # Relationship Block. In this case this resource has many articles
  relationships do
    has_many :articles, Helpcenter.KnowledgeBase.Article do
      description "Relationship with the articles."

      # <-- Tell Ash that the articles table has a column named "category_id" that references this resource
      destination_attribute :category_id
    end
  end

  aggregates do
    count :article_count, :articles
  end
end
