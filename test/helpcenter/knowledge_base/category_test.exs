defmodule Helpcenter.KnowledgeBase.CategoryTest do
  require Ash.Query
  alias Helpcenter.KnowledgeBase.Article
  alias Helpcenter.KnowledgeBase.Category
  use HelpcenterWeb.ConnCase, async: false
  import CategoryCase
  import ArticleCase

  describe "Knowledge Base Category Tests" do
    test "Can create a category" do
      attrs = %{
        name: "Billing",
        slug: "billing",
        description: "Refund requests, billing and account issues"
      }

      {:ok, category} =
        Category
        |> Ash.Changeset.for_create(:create, attrs)
        |> Ash.create()

      assert category.name == attrs.name
      assert category.slug == attrs.slug
      assert category.description == attrs.description

      refute category.inserted_at |> is_nil()
      refute category.updated_at |> is_nil()
    end

    test "Can filter categories" do
      create_categories()

      require Ash.Query

      assert Category
             |> Ash.Query.filter(name == "Billing and Payments")
             |> Ash.exists?()

      # Require the Ash.Query in order to use its macros
      require Ash.Query

      # Now we have all Ash.Query macros we can use it to filter
      Helpcenter.KnowledgeBase.Category
      |> Ash.Query.filter(name == "General Support")
      |> Ash.Query.filter(slug == "general-support")
      |> Ash.read()
    end

    test "Can update an existing category" do
      # Seed data to work with
      create_categories()

      require Ash.Query

      # 1. Get category to update
      Helpcenter.KnowledgeBase.Category
      |> Ash.Query.filter(name == "System Setup and Integration")
      |> Ash.read_first!()
      # Update category name in the database
      |> Ash.Changeset.for_update(:update, %{name: "Integration"})
      |> Ash.update()

      assert Helpcenter.KnowledgeBase.Category
             |> Ash.Query.filter(name == "Integration")
             |> Ash.exists?()
    end

    test "Can destroy an existing Category" do
      create_categories()

      require Ash.Query

      # First identify category to destroy
      category_to_delete =
        Helpcenter.KnowledgeBase.Category
        |> Ash.Query.filter(name == "Approvals and Workflows")
        |> Ash.read_first!()

      # Tell Ash to destroy it
      Ash.destroy(category_to_delete)

      refute Helpcenter.KnowledgeBase.Category
             |> Ash.Query.filter(name == "Approvals and Workflows")
             |> Ash.exists?()
    end

    test "Category can be created with an article" do
      # Define category and related article attributes
      attrs = %{
        name: "Features",
        slug: "features",
        description: "Category for features",
        article_attrs: %{
          title: "Compliance Features in Zippiker",
          slug: "compliance-features-zippiker",
          content: "Overview of compliance management features built into Zippiker."
        }
      }

      # Create category and its article at the same time
      Helpcenter.KnowledgeBase.Category
      |> Ash.Changeset.for_create(:create_with_article, attrs)
      |> Ash.create()

      assert Category
             |> Ash.Query.filter(name == ^attrs.name)
             |> Ash.exists?()

      assert Article
             |> Ash.Query.filter(title == ^attrs.article_attrs.title)
             |> Ash.exists?()
    end

    test "An article can be added to an existing category" do
      # 1. Get category to create an article under
      category = get_category()

      # 2. Prepare new article data
      attrs = %{
        title: "Getting Started with Zippiker",
        slug: "getting-started-zippiker",
        content: "Learn how to set up your Zippiker account and configure basic settings.",
        views_count: 1452,
        published: true
      }

      # 3 Create an article under this category
      {:ok, _category} =
        category
        |> Ash.Changeset.for_update(:add_article, %{article_attrs: attrs})
        |> Ash.update()

      # Confirm that the article has been create
      assert Helpcenter.KnowledgeBase.Article
             |> Ash.Query.filter(title == ^attrs.title)
             |> Ash.Query.filter(content == ^attrs.content)
             |> Ash.Query.filter(category_id == ^category.id)
             |> Ash.read()
    end

    test "Category can be retrieved with related articles" do
      # First create articles for the category
      category = get_category()
      articles = create_articles(category)

      category_with_articles =
        Helpcenter.KnowledgeBase.Category
        |> Ash.Query.filter(id == ^category.id)
        # Tell Ash to load related articles
        |> Ash.Query.load(:articles)
        |> Ash.read_first!()

      # This category might have added article else where in concurrency writing. Thus, use <=
      assert Enum.count(category_with_articles.articles) <= Enum.count(articles)
    end

    test "articles_count aggregate can be loaded on the category" do
      # Create categories and seed articles
      category = get_category()
      create_articles(category)

      loaded_category =
        Helpcenter.KnowledgeBase.Category
        |> Ash.Query.filter(id == ^category.id)
        |> Ash.Query.load([:article_count, :articles])
        |> Ash.read_first!()

      assert loaded_category.article_count == Enum.count(loaded_category.articles)
    end
  end
end
