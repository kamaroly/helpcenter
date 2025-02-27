defmodule Helpcenter.KnowledgeBase.ArticleTest do
  alias Helpcenter.KnowledgeBase.ArticleFeedback
  use HelpcenterWeb.ConnCase, async: false
  alias Helpcenter.KnowledgeBase.ArticleTag
  alias Helpcenter.KnowledgeBase.Comment
  alias Helpcenter.KnowledgeBase.Category
  alias Helpcenter.KnowledgeBase.Article
  import CategoryCase
  import ArticleCase
  require Ash.Query

  describe "Article Tests" do
    test "Article can be created" do
      user = create_user()
      category = get_category(user.current_team)

      # Preparate attributes
      attrs = %{
        title: "Common Issues During Setup and How to Fix Them",
        slug: "setup-common-issues",
        content: "Troubleshooting guide for common challenges faced during initial setup.",
        category_id: category.id
      }

      # Create article and assign it to an existing category
      Article
      |> Ash.Changeset.for_create(:create, attrs, actor: user)
      |> Ash.create()

      assert Article
             |> Ash.Query.filter(title == ^attrs.title)
             |> Ash.exists?(actor: user)
    end

    test "Article and Category can be created at the same time" do
      user = create_user()

      attributes = %{
        title: "Common Issues During Setup and How to Fix Them",
        slug: "setup-common-issues",
        content: "Troubleshooting guide for common challenges faced during initial setup.",
        category_attrs: %{
          name: "Troubleshooting",
          slug: "troubleshooting",
          description: "Diagnose and fix identified issues"
        }
      }

      Helpcenter.KnowledgeBase.Article
      |> Ash.Changeset.for_create(:create_with_category, attributes, actor: user)
      |> Ash.create()

      assert Article
             |> Ash.Query.filter(title == ^attributes.title)
             |> Ash.exists?(actor: user)

      assert Category
             |> Ash.Query.filter(name == ^attributes.category_attrs.name)
             |> Ash.Query.filter(slug == ^attributes.category_attrs.slug)
             |> Ash.Query.filter(description == ^attributes.category_attrs.description)
             |> Ash.exists?(actor: user)
    end

    test "A comment can be added to an article" do
      user = create_user()
      article = get_article(user.current_team)
      attrs = %{content: "First article content you will see!"}

      {:ok, _article} =
        article
        |> Ash.Changeset.for_update(:add_comment, %{comment: attrs}, actor: user)
        |> Ash.update()

      assert Comment
             |> Ash.Query.filter(content == ^attrs.content)
             |> Ash.Query.filter(article_id == ^article.id)
             |> Ash.exists?(actor: user)
    end

    test "A feedback can be added to an article" do
      user = create_user()
      article = get_article(user.current_team)
      attrs = %{feedback: "It came out earlier than needed", helpful: true}

      {:ok, _article} =
        article
        |> Ash.Changeset.for_update(:add_feedback, %{feedback: attrs}, actor: user)
        |> Ash.update()

      assert ArticleFeedback
             |> Ash.Query.filter(feedback == ^attrs.feedback)
             |> Ash.Query.filter(helpful == ^attrs.helpful)
             |> Ash.Query.filter(article_id == ^article.id)
             |> Ash.exists?(actor: user)
    end

    test "An article can be created with tags" do
      user = create_user()
      category = get_category(user.current_team)

      attributes = %{
        title: "Common Issues During Setup and How to Fix Them",
        slug: "setup-common-issues",
        content: "Troubleshooting guide for common challenges faced during initial setup.",
        category_id: category.id,
        tags: [%{name: "issues"}, %{name: "solution"}]
      }

      {:ok, _article} =
        Helpcenter.KnowledgeBase.Article
        |> Ash.Changeset.for_create(:create_with_tags, attributes, actor: user)
        |> Ash.create()

      assert Article
             |> Ash.Query.filter(title == ^attributes.title)
             |> Ash.exists?(actor: user)

      assert ArticleTag
             |> Ash.Query.filter(article.title == ^attributes.title)
             |> Ash.Query.filter(tag.name == "issues")
             |> Ash.exists?(actor: user)
    end

    test "Articles can be filtered by their tags" do
      user = create_user()
      create_articles(user.current_team)
      category = get_category(user.current_team)

      attributes = %{
        title: "Common Issues During Setup and How to Fix Them",
        slug: "setup-common-issues",
        content: "Troubleshooting guide for common challenges faced during initial setup.",
        category_id: category.id,
        tags: [%{name: "issues"}, %{name: "solution"}]
      }

      # Add article with tags
      {:ok, _article} =
        Helpcenter.KnowledgeBase.Article
        |> Ash.Changeset.for_create(:create_with_tags, attributes, actor: user)
        |> Ash.create()

      assert Helpcenter.KnowledgeBase.Category
             |> Ash.Query.filter(articles.tags.name == "issues")
             |> Ash.exists?(actor: user)
    end
  end
end
