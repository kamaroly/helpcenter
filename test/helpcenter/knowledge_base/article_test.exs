defmodule Helpcenter.KnowledgeBase.ArticleTest do
  use HelpcenterWeb.ConnCase, async: false
  alias Helpcenter.KnowledgeBase.Category
  alias Helpcenter.KnowledgeBase.Article
  import CategoryCase
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
  end
end
