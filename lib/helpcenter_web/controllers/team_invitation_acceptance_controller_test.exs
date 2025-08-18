defmodule HelpcenterWeb.TeamInvitationAcceptanceControllerTEst do
  use HelpcenterWeb.ConnCase

  defp create_group!(actor) do
    group_attrs = %{name: "Accountants", description: "Can manage billing in the system"}

    Ash.create!(
      Helpcenter.Accounts.Group,
      group_attrs,
      actor: actor,
      authorize?: false
    )
  end

  describe "Team invitation acceptance controller" do
    test "User can accept an invitation", %{conn: conn} do
      # 1. Create auser
      # 2. Add user to the team
      # 3. Get the invitation token and send it in the URL
      # 4. Confirm the notifiaction flash
      # 5. Ensure that the user has been added to the team
      actor = create_user()
      group = create_group!(actor)
      invite_attributes = %{email: "john@example.com", group_id: group.id}

      invitation =
        Helpcenter.Accounts.Invitation
        |> Ash.Changeset.for_create(:create, invite_attributes, actor: actor)
        |> Ash.create!()

      conn =
        conn
        |> get(~p"/accounts/users/invitations/#{invitation.team}/#{invitation.token}/accept")

      assert redirected_to(conn) == ~p"/"

      # Confirm the invitation has been accepted
      require Ash.Query

      assert Helpcenter.Accounts.Invitation
             |> Ash.Query.filter(token == ^invitation.token)
             |> Ash.Query.filter(status == :accepted)
             |> Ash.exists?(actor: actor)
    end
  end
end
