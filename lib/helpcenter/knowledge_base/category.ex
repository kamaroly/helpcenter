defmodule Helpcenter.KnowledgeBase.Category do
  use Ash.Resource,
    domain: Helpcenter.KnowledgeBase,
    data_layer: AshPostgres.DataLayer,
    # Tell Ash to broadcast/ Emit events via pubsub
    notifiers: Ash.Notifier.PubSub

  postgres do
    # <-- Tell Ash that this resource data is stored in a table named "categories"
    table "categories"
    # <-- Tell Ash that this resource access data storage via Helpcenter.Repo
    repo Helpcenter.Repo
  end

  actions do
    default_accept [:name, :slug, :description]
    defaults [:create, :read, :update, :destroy]

    read :most_recent do
      prepare Helpcenter.Preparations.LimitTo5
      prepare Helpcenter.Preparations.MonthToDate
      prepare Helpcenter.Preparations.OrderByMostRecent
    end

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

  # Confirm how Ash will wor
  pub_sub do
    # 1. Tell Ash to use HelpcenterWeb.Endpoint for publishing events
    module HelpcenterWeb.Endpoint

    # Prefix all events from this resource with category. This allows us
    # to subscribe only to events starting with "categories" in livew view
    prefix "categories"

    # Define event topic or names. Below configuration will be publishing
    # topic of this format whenever an action of update, create or delete
    # happens:
    #    "categories"
    #    "categories:UUID-PRIMARY-KEY-ID-OF-CATEGORY"
    #
    #  You can pass any other parameter available on resource like slug

    publish_all :update, [[:id, nil]]
    publish_all :create, [[:id, nil]]
    publish_all :destroy, [[:id, nil]]
  end

  changes do
    # Changes are run in a sequential order so the first thing we want is to set a tenant
    change Helpcenter.Changes.SetTenant
    change Helpcenter.Changes.Slugify
  end

  multitenancy do
    strategy :context
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
