defmodule HelpcenterWeb.KnowledgeBase.CreateCategoryLiveTest do
  use Gettext, backend: HelpcenterWeb.Gettext
  use HelpcenterWeb.ConnCase, async: false
  alias Helpcenter.KnowledgeBase.Category
  import Phoenix.LiveViewTest
  import CategoryCase

  describe "New Category" do
    test "User can create category from the UI", %{conn: conn} do
      category = get_category()
      {:ok, view, html} = live(conn, ~p"/categories/#{category.id}")

      # Confirm category is rendered successfully
      assert html =~ category.name
      assert html =~ category.description

      # Confirm that we can see the form for creating the category
      assert html =~ "form[name]"
      assert html =~ "form[description]"
      assert html =~ "submit"

      # Confirm that we can create a new category
      attributes = %{
        name: "#{category.name} updated",
        description: "#{category.description} updated."
      }

      # Confirm that category form can be validated
      errored_html =
        view
        |> form("#category-form-#{category.id}", form: %{name: ""})
        |> render_change()

      assert errored_html =~ "required"

      view
      |> form("#category-form-#{category.id}", form: attributes)
      |> render_submit()

      # Confirm that changes were saved in the database
      require Ash.Query

      assert Category
             |> Ash.Query.filter(name == ^attributes.name)
             |> Ash.Query.filter(description == ^attributes.description)
             |> Ash.exists?()
    end
  end
end
