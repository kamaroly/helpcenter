defmodule Helpcenter.KnowledgeBase.ArticleTest do
  use HelpcenterWeb.ConnCase, async: false
  alias Helpcenter.KnowledgeBase.ArticleTag
  alias Helpcenter.KnowledgeBase.Comment
  alias Helpcenter.KnowledgeBase.ArticleFeedback
  alias Helpcenter.KnowledgeBase.Category
  alias Helpcenter.KnowledgeBase.Article
  import CategoryCase
  import ArticleCase
  require Ash.Query

  describe "Article Tests" do
    test "Article can be created" do
      category = get_category()

      # Preparate attributes
      attrs = %{
        title: "Common Issues During Setup and How to Fix Them",
        slug: "setup-common-issues",
        content: "Troubleshooting guide for common challenges faced during initial setup.",
        category_id: category.id
      }

      # Create article and assign it to an existing category
      Article
      |> Ash.Changeset.for_create(:create, attrs)
      |> Ash.create()

      assert Article
             |> Ash.Query.filter(title == ^attrs.title)
             |> Ash.exists?()
    end

    test "Article and Category can be created at the same time" do
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
      |> Ash.Changeset.for_create(:create_with_category, attributes)
      |> Ash.create()

      assert Article
             |> Ash.Query.filter(title == ^attributes.title)
             |> Ash.exists?()

      assert Category
             |> Ash.Query.filter(name == ^attributes.category_attrs.name)
             |> Ash.Query.filter(slug == ^attributes.category_attrs.slug)
             |> Ash.Query.filter(description == ^attributes.category_attrs.description)
             |> Ash.exists?()
    end

    test "A comment can be added to an article" do
      article = get_article()
      attrs = %{content: "First article content you will see!"}

      {:ok, _article} =
        article
        |> Ash.Changeset.for_update(:add_comment, %{comment: attrs})
        |> Ash.update()

      assert Comment
             |> Ash.Query.filter(content == ^attrs.content)
             |> Ash.Query.filter(article_id == ^article.id)
             |> Ash.exists?()
    end

    test "A feedback can be added to an article" do
      article = get_article()
      attrs = %{feedback: "It came out earlier than needed", helpful: true}

      {:ok, _article} =
        article
        |> Ash.Changeset.for_update(:add_feedback, %{feedback: attrs})
        |> Ash.update()

      assert ArticleFeedback
             |> Ash.Query.filter(feedback == ^attrs.feedback)
             |> Ash.Query.filter(helpful == ^attrs.helpful)
             |> Ash.Query.filter(article_id == ^article.id)
             |> Ash.exists?()
    end

    test "An article can be created with tags" do
      attributes = %{
        title: "Common Issues During Setup and How to Fix Them",
        slug: "setup-common-issues",
        content: "Troubleshooting guide for common challenges faced during initial setup.",
        tags: [%{name: "issues"}, %{name: "solution"}]
      }

      {:ok, _article} =
        Helpcenter.KnowledgeBase.Article
        |> Ash.Changeset.for_create(:create_with_tags, attributes)
        |> Ash.create()

      assert Article
             |> Ash.Query.filter(title == ^attributes.title)
             |> Ash.exists?()

      assert ArticleTag
             |> Ash.Query.filter(article.title == ^attributes.title)
             |> Ash.Query.filter(tag.name == "issues")
             |> Ash.exists?()
    end
  end
end
