# test/helpcenter/accounts/invitation_test.exs
defmodule Helpcenter.Accounts.InvitationTest do
  use HelpcenterWeb.ConnCase, async: false
  require Ash.Query

  defp create_group() do
    user = create_user()
    group_attrs = %{name: "Accountants", description: "Can manage billing in the system"}

    {:ok, _group} =
      Ash.create(
        Helpcenter.Accounts.Group,
        group_attrs,
        actor: user,
        load: [:permissions, :users],
        authorize?: false
      )
  end

  describe "Invitations test" do
    test "Team owner can invite a new user" do
      actor = create_user()
      group = create_group()

      invite_attributes = %{email: "john@example.com", group_id: group.id}

      Helpcenter.Accounts.Invitation
      |> Ash.Changeset.for_create(:create, invite_attributes, actor: actor)
      |> Ash.create!()
      |> dbg()
    end
  end
end
