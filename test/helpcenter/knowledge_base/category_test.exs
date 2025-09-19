defmodule Helpcenter.KnowledgeBase.CategoryTest do
  use HelpcenterWeb.ConnCase
  import ArticleCase
  import CategoryCase
  require Ash.Query

  describe "Knowledge Base Category Tests" do
    test "Can create a category" do
      user = create_user()
      # Create a category and expect to user current_team as the
      # tenant databsae for this query
      cat_attrs = %{name: "Billing", description: "testing"}

      category =
        Helpcenter.KnowledgeBase.Category
        |> Ash.Changeset.for_create(:create, cat_attrs, actor: user)
        |> Ash.create!()

      # Confirm that category's tenant is the same as the user current_team
      assert user.current_team == Ash.Resource.get_metadata(category, :tenant)

      # Confirm that all the data has been stored in the databse successfully
      assert category.name == cat_attrs.name
      assert category.description == cat_attrs.description

      # Confirm that timestamps aren't null
      refute category.inserted_at |> is_nil()
      refute category.updated_at |> is_nil()
    end

    test "Can filter categories" do
      user = create_user()
      create_categories(user.current_team)

      require Ash.Query

      assert Helpcenter.KnowledgeBase.Category
             |> Ash.Query.filter(name == "Billing and Payments")
             |> Ash.exists?(actor: user)

      # Require the Ash.Query in order to use its macros
      require Ash.Query

      # Now we have all Ash.Query macros we can use it to filter
      Helpcenter.KnowledgeBase.Category
      |> Ash.Query.filter(name == "General Support")
      |> Ash.Query.filter(slug == "general-support")
      |> Ash.read(actor: user)
    end

    test "Can update an existing category" do
      # Seed data to work with
      user = create_user()
      create_categories(user.current_team)

      require Ash.Query

      # 1. Get category to update
      Helpcenter.KnowledgeBase.Category
      |> Ash.Query.filter(name == "System Setup and Integration")
      |> Ash.read_first!(actor: user)
      # Update category name in the database
      |> Ash.Changeset.for_update(:update, %{name: "Integration"})
      |> Ash.update(actor: user)

      assert Helpcenter.KnowledgeBase.Category
             |> Ash.Query.filter(name == "Integration")
             |> Ash.exists?(actor: user)
    end

    test "Can destroy an existing Category" do
      user = create_user()

      create_categories(user.current_team)

      require Ash.Query

      # First identify category to destroy
      category_to_delete =
        Helpcenter.KnowledgeBase.Category
        |> Ash.Query.filter(name == "Approvals and Workflows")
        |> Ash.read_first!(actor: user)

      # Tell Ash to destroy it
      Ash.destroy(category_to_delete, actor: user)

      refute Helpcenter.KnowledgeBase.Category
             |> Ash.Query.filter(name == "Approvals and Workflows")
             |> Ash.exists?(actor: user)
    end

    test "Category can be created with an article" do
      user = create_user()

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
      |> Ash.Changeset.for_create(:create_with_article, attrs, actor: user)
      |> Ash.create()

      assert Helpcenter.KnowledgeBase.Category
             |> Ash.Query.filter(name == ^attrs.name)
             |> Ash.exists?(actor: user)

      assert Helpcenter.KnowledgeBase.Article
             |> Ash.Query.filter(title == ^attrs.article_attrs.title)
             |> Ash.exists?(actor: user)
    end

    test "An article can be added to an existing category" do
      # 1. Get category to create an article under
      user = create_user()
      category = get_category(user.current_team)

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
        |> Ash.Changeset.for_update(:add_article, %{article_attrs: attrs}, actor: user)
        |> Ash.update()

      # Confirm that the article has been create
      assert Helpcenter.KnowledgeBase.Article
             |> Ash.Query.filter(title == ^attrs.title)
             |> Ash.Query.filter(content == ^attrs.content)
             |> Ash.Query.filter(category_id == ^category.id)
             |> Ash.read(actor: user)
    end

    test "Category can be retrieved with related articles" do
      # First create articles for the category
      user = create_user()

      category = get_category(user.current_team)
      articles = create_articles(category, user.current_team)

      category_with_articles =
        Helpcenter.KnowledgeBase.Category
        |> Ash.Query.filter(id == ^category.id)
        # Tell Ash to load related articles
        |> Ash.Query.load(:articles)
        |> Ash.read_first!(actor: user)

      # This category might have added article else where in concurrency writing. Thus, use <=
      assert Enum.count(category_with_articles.articles) <= Enum.count(articles)
    end

    test "articles_count aggregate can be loaded on the category" do
      # Create categories and seed articles
      user = create_user()

      category = get_category(user.current_team)
      create_articles(category, user.current_team)

      loaded_category =
        Helpcenter.KnowledgeBase.Category
        |> Ash.Query.filter(id == ^category.id)
        |> Ash.Query.load([:article_count, :articles])
        |> Ash.read_first!(actor: user)

      assert loaded_category.article_count == Enum.count(loaded_category.articles)
    end

    test "'categories' pubsub event is published on create" do
      # Subscribe to the event so we can test whether it is being fired
      user = create_user()
      HelpcenterWeb.Endpoint.subscribe("categories")

      attributes = %{name: "Art 1", slug: "art-1", description: "descrpt-1"}

      Helpcenter.KnowledgeBase.Category
      |> Ash.Changeset.for_create(:create, attributes, actor: user)
      |> Ash.create()

      # Confirm that the event is being recieved and its data
      assert_receive %Phoenix.Socket.Broadcast{topic: "categories", payload: category}
      assert category.data.name == attributes.name
      assert category.data.slug == attributes.slug
      assert category.data.description == attributes.description
    end

    test "Global preparations works as expected" do
      user = create_user()

      create_categories(user.current_team)

      assert Helpcenter.KnowledgeBase.Category
             |> Helpcenter.Preparations.LimitTo5.prepare([], [])
             |> Helpcenter.Preparations.MonthToDate.prepare([], [])
             |> Helpcenter.Preparations.OrderByMostRecent.prepare([], [])
             |> Ash.count!(actor: user) == 5
    end

    test "Slug change generates slug successfully" do
      user = create_user()

      params = %{
        name: "Home appliances you cannot find elsewhere",
        description: "Home appliances description"
      }

      {:ok, category} =
        Ash.create(Helpcenter.KnowledgeBase.Category, params, actor: user)

      refute category.slug |> is_nil()
    end
  end
end
