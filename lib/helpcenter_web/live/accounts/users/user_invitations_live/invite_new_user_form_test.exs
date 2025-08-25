defmodule HelpcenterWeb.Accounts.Users.UserInvitationsLive.InviteNewUserFormTest do
  use HelpcenterWeb.ConnCase
  alias HelpcenterWeb.Accounts.Users.UserInvitationsLive.InviteNewUserForm

  defp create_group!(actor) do
    group_attrs = %{name: "Accountants", description: "Can manage billing in the system"}

    Ash.create!(
      Helpcenter.Accounts.Group,
      group_attrs,
      actor: actor,
      authorize?: false
    )
  end

  describe "Invite New User Form" do
    test "Invite user form renders successfully" do
      assigns = %{id: Ash.UUIDv7.generate(), actor: create_user()}
      html = render_component(InviteNewUserForm, assigns)

      assert html =~ "email"
      assert html =~ "group_id"
      assert html =~ "Invite User"
      assert html =~ "Invite a new member to your team"
    end

    test "New user can be invited successfully", %{conn: conn} do
      user = create_user()
      group = create_group!(user)

      {:ok, view, html} =
        conn
        |> login(user)
        |> live("/accounts/users/invitations")

      # Confirm invite user button is present
      assert html =~ "Invite a user"
      assert has_element?(view, "#invite-user-modal-button")

      # Confirm submitting the form works
      params = %{email: "tester@example.com", group_id: group.id}

      view
      |> form("#invite-user-modal form", form: params)
      |> render_submit()

      # Confirm that the invitation was created in the database
      require Ash.Query

      assert Helpcenter.Accounts.Invitation
             |> Ash.Query.filter(email == ^params.email)
             |> Ash.Query.filter(group_id == ^group.id)
             |> Ash.Query.filter(status == :pending)
             |> Ash.exists?(actor: user, authorize?: false)
    end
  end
end
