# test/helpcenter/accounts/access_group_live_test.exs
defmodule Helpcenter.Accounts.AccessGroupLiveTest do
  use HelpcenterWeb.ConnCase, async: false
  import AuthCase

  describe "User Access Group Test:" do
    test "All actions can be listed for permissions" do
      assert Helpcenter.permissions()
             |> is_list()
    end

    # test/helpcenter/accounts/access_group_live_test.exs
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

      # Confirm that all necessary fields are visible
      assert html =~ "access-group-modal-button"
      assert html =~ "form[name]"
      assert html =~ "form[description]"
      assert html =~ gettext("Submit")

      # Confirm that group data is visible in the form
      assert html =~ group.name
      assert html =~ group.description
    end

    test "Guests should be redirected to login while accessing /accounts/groups", %{conn: conn} do
      assert conn
             |> live(~p"/accounts/groups")
             |> follow_redirect(conn, "/sign-in")
    end

    test "Access groups can be listed", %{conn: conn} do
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

    test "Access Group can be created", %{conn: conn} do
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

    test "Access group can be edited", %{conn: conn} do
      user = get_user()
      group = get_group(user)

      {:ok, view, html} =
        conn
        |> login(user)
        |> live(~p"/accounts/groups")

      # confirm that the group is visible on the page
      assert html =~ group.name
      assert html =~ group.description
      assert html =~ ~p"/accounts/groups/#{group.id}/permissions"

      # Confirm user can click on the link to group edit
      assert view
             |> element("#edit-access-group-#{group.id}")
             |> render_click()

      # Confirm that edit group page display the group details
      {:ok, _edit_view, edit_html} =
        conn
        |> login(user)
        |> live(~p"/accounts/groups/#{group.id}/permissions")

      assert edit_html =~ group.name
      assert edit_html =~ group.description

      # Confirm that user can see all permissions in the app listed
      for perm <- Helpcenter.permissions() do
        assert edit_html =~ "form[#{perm.resource}][#{perm.action}]"
      end
    end
  end
end
