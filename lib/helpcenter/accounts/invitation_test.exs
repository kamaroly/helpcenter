defmodule Helpcenter.Accounts.InvitationTest do
  use HelpcenterWeb.ConnCase
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

      # Confirm that user cannot decline an already accepted invitation
      {:error, %Ash.Error.Invalid{errors: errors}} =
        accepted_invitation
        |> Ash.Changeset.for_update(:decline, %{}, actor: actor)
        |> Ash.update()

      error = List.first(errors)
      assert error.field == :token
      assert error.message == "This invitation has already been accepted."
    end

    test "Invitation can be decline an invitation" do
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

      # Decline invitation
      declined_invitation =
        invitation
        |> Ash.Changeset.for_update(:decline, %{}, actor: actor)
        |> Ash.update!()

      assert declined_invitation.status == :declined
    end
  end
end
