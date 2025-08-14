defmodule Helpcenter.Accounts.InvitationTest do
  use HelpcenterWeb.ConnCase, async: false
  require Ash.Query

  defp create_group!(actor) do
    group_attrs = %{name: "Accountants", description: "Can manage billing in the system"}

    Ash.create!(
      Helpcenter.Accounts.Group,
      group_attrs,
      actor: actor,
      authorize?: false
    )
  end

  describe "Invitations test" do
    test "Team owner can invite a new user" do
      actor = create_user()
      group = create_group!(actor)
      invite_attributes = %{email: "john@example.com", group_id: group.id}

      invitation =
        Helpcenter.Accounts.Invitation
        |> Ash.Changeset.for_create(:create, invite_attributes, actor: actor)
        |> Ash.create!()

      assert invitation.status == :pending
      assert invitation.email == invite_attributes.email
      assert invitation.group_id == group.id

      # Accept invitation
      accepted_invitation =
        invitation
        |> Ash.Changeset.for_update(:accept, %{}, actor: actor)
        |> Ash.update!()

      assert accepted_invitation.status == :accepted
      assert accepted_invitation.email == invite_attributes.email
      assert accepted_invitation.group_id == group.id
    end
  end
end
