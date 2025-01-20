defmodule Helpcenter.KnowledgeBase.CategoryTest do
  require Ash.Query
  alias Helpcenter.KnowledgeBase.Category
  use HelpcenterWeb.ConnCase, async: false
  import CategoryCase

  describe "Knowledge Base Category Tests" do
    test "User can create a category" do
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

    test "User can filter categories" do
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

    test "User can update an existing category" do
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

    test "User can destroy an existing Category" do
      create_categories()

      require Ash.Query

      category_to_delete =
        Helpcenter.KnowledgeBase.Category
        |> Ash.Query.filter(name == "Approvals and Workflows")
        |> Ash.read_first!()

      Ash.destroy(category_to_delete)

      refute Helpcenter.KnowledgeBase.Category
             |> Ash.Query.filter(name == "Approvals and Workflows")
             |> Ash.exists?()
    end
  end
end
