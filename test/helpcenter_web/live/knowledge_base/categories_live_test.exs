defmodule HelpcenterWeb.KnowledgeBase.CategoriesLiveTest do
  use Gettext, backend: HelpcenterWeb.Gettext
  use HelpcenterWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  import CategoryCase
  require Ash.Query

  describe "Categories live test" do
    test "Guest cannot access /categories", %{conn: conn} do
      assert conn
             |> live(~p"/categories")
             |> follow_redirect(conn, "/sign-in")
    end

    test "User can see a list of categories", %{conn: conn} do
      user = create_user()
      categories = create_categories(user.current_team)

      {:ok, _view, html} =
        conn
        |> login(user)
        |> live(~p"/categories")

      assert html =~ gettext("Categories")

      for category <- categories do
        assert html =~ category.name
      end
    end

    test "User can edit an existing category", %{conn: conn} do
      user = create_user()
      category = get_category(user.current_team)

      {:ok, view, _html} =
        conn
        |> login(user)
        |> live(~p"/categories")

      # Confirm that we can click on the edit button
      assert view
             |> element("#edit-button-#{category.id}")
             |> render_click()
             |> follow_redirect(conn, ~p"/categories/#{category.id}")
    end

    test "User can go to the new category form page from the list", %{conn: conn} do
      user = create_user()

      {:ok, view, _html} =
        conn
        |> login(user)
        |> live(~p"/categories")

      assert view
             |> element("#create-category-button")
             |> render_click()
             |> follow_redirect(conn, ~p"/categories/create")
    end

    test "User should be able to delete an existing category", %{conn: conn} do
      user = create_user()
      category = get_category(user.current_team)

      {:ok, view, html} =
        conn
        |> login(user)
        |> live(~p"/categories")

      # Confirm category existing on the page
      assert html =~ category.name

      # Attempt destroy
      view
      |> element("#delete-button-#{category.id}")
      |> render_click()

      # Confirm category is destroyed
      refute Helpcenter.KnowledgeBase.Category
             |> Ash.Query.filter(id == ^category.id)
             |> Ash.exists?(actor: user)
    end

    test "User can create category from the UI", %{conn: conn} do
      user = create_user()
      category = get_category(user.current_team)

      {:ok, view, html} =
        conn
        |> login(user)
        |> live(~p"/categories/#{category.id}")

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
             |> Ash.exists?(actor: user)
    end
  end
end
