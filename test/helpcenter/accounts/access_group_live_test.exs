defmodule Helpcenter.Accounts.AccessGroupLiveTest do
  use HelpcenterWeb.ConnCase, async: false
  import AuthCase

  describe "User Access Group Test:" do
    test "All actions can be listed for permissions" do
      assert Helpcenter.permissions() |> is_list()
    end

    test "Group form renders successfully" do
      user = create_user()

      assigns = %{
        actor: user,
        group_id: nil,
        id: Ash.UUIDv7.generate()
      }

      html = render_component(HelpcenterWeb.Accounts.Groups.GroupForm, assigns)

      # Confirm that all necessary fields are there
      assert html =~ "access-group-modal-button"
      assert html =~ "form[name]"
      assert html =~ "form[description]"
      assert html =~ gettext("Submit")
    end

    test "Existing group renders successfully with the component" do
      user = create_user()
      group = get_group(user)

      assigns = %{
        actor: user,
        group_id: group.id,
        id: Ash.UUIDv7.generate()
      }

      html = render_component(HelpcenterWeb.Accounts.Groups.GroupForm, assigns)

      # Confirm that all necessary fields are there
      assert html =~ "access-group-modal-button"
      assert html =~ "form[name]"
      assert html =~ "form[description]"
      assert html =~ gettext("Submit")

      # Confirm that group data is visible in the form

      assert html =~ group.name
      assert html =~ group.description
    end

    test "Guest cannot access /accounts/groups", %{conn: conn} do
      assert conn
             |> live(~p"/accounts/groups")
             |> follow_redirect(conn, "/sign-in")
    end

    test "User can list existing access groups form", %{conn: conn} do
      user = create_user()
      groups = get_groups(user)

      {:ok, _view, html} =
        conn
        |> login(user)
        |> live(~p"/accounts/groups")

      # Confirm that user can see the button to add a group form
      assert html =~ "access-group-modal-button"

      # Confirm that all groups ares listed
      for group <- groups do
        assert html =~ group.name
        assert html =~ group.description
      end
    end

    test "User can create a new access group form", %{conn: conn} do
      user = create_user()

      {:ok, view, _html} =
        conn
        |> login(user)
        |> live(~p"/accounts/groups")

      attrs = %{name: "Support", description: "Customer support representative"}

      # Form can be validated
      assert view
             |> form("#access-group-form", form: attrs)
             |> render_change()

      #  Form can be submitted
      assert view
             |> form("#access-group-form", form: attrs)
             |> render_submit()

      # Confirm that data was actually stores data
      require Ash.Query

      assert Helpcenter.Accounts.Group
             |> Ash.Query.filter(name == ^attrs.name)
             |> Ash.Query.filter(description == ^attrs.description)
             |> Ash.exists?(actor: user)
    end
  end
end
