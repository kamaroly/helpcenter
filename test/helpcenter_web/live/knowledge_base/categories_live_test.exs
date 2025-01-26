defmodule HelpcenterWeb.KnowledgeBase.CategoriesLiveTest do
  alias Helpcenter.KnowledgeBase.Category
  use Gettext, backend: HelpcenterWeb.Gettext
  use HelpcenterWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  import CategoryCase

  describe "Categories live test" do
    test "User can see a list of categories", %{conn: conn} do
      categories = create_categories()
      {:ok, _view, html} = live(conn, ~p"/categories")

      assert html =~ gettext("Categories")

      for category <- categories do
        assert html =~ category.name
      end
    end

    test "User can create category from the UI", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/categories")

      assert html =~ gettext("New Category")

      # Confirm that we can see the form for creating the category
      assert html =~ "form[name]"
      assert html =~ "form[description]"
      assert html =~ "submit"

      # Confirm that we can create a new category
      attributes = %{
        name: "Category 1",
        description: "Description of what Category 1 represents."
      }

      # Confirm that category form can be validated
      errored_html =
        view
        |> form("#category-form", form: %{name: ""})
        |> render_change()

      assert errored_html =~ "required"

      view
      |> form("#category-form", form: attributes)
      |> render_submit()

      # Confirm that changes were saved in the database
      require Ash.Query

      assert Category
             |> Ash.Query.filter(name == ^attributes.name)
             |> Ash.Query.filter(description == ^attributes.description)
             |> Ash.exists?()
    end

    test "User can edit an existing category", %{conn: conn} do
      category = get_category()
      {:ok, view, html} = live(conn, ~p"/categories")

      # Confirm that we can see edit button
      assert html =~ "edit-#{category.id}"

      # Confirm that we can click on the edit button
      view
      |> element("#edit-button-#{category.id}")
      |> render_click()
    end
  end
end
