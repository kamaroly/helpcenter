defmodule HelpcenterWeb.KnowledgeBase.CategoriesLiveTest do
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

    test "User can edit an existing category", %{conn: conn} do
      category = get_category()
      {:ok, view, _html} = live(conn, ~p"/categories")

      # Confirm that we can click on the edit button
      assert view
             |> element("#edit-button-#{category.id}")
             |> render_click()
             |> follow_redirect(conn, ~p"/categories/#{category.id}")
    end

    test "User can go to the new category form page from the list", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/categories")

      assert view
             |> element("#create-category-button")
             |> render_click()
             |> follow_redirect(conn, ~p"/categories/create")
    end
  end
end
