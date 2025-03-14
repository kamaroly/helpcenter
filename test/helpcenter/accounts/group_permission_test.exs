# test/helpcenter/accounts/group_permission_test.exs
defmodule Helpcenter.Accounts.GroupPermissionTest do
  use HelpcenterWeb.ConnCase, async: false
  require Ash.Query

  describe "Access Group Permission Tests" do
    test "Permission can be added to a group" do
      # Prepare data
      user = create_user()
      group_attrs = %{name: "Accountants", description: "Can manage billing in the system"}
      group = Ash.create!(Helpcenter.Accounts.Group, group_attrs, actor: user)

      perm_attr = %{
        group_id: group.id,
        resource: Helpcenter.KnowledgeBase.Category,
        action: :read
      }

      group_perm =
        Ash.create!(Helpcenter.Accounts.GroupPermission, perm_attr, actor: user, load: [:group])

      # Confirm that the association happened and in the right tenant
      assert user.current_team == Ash.Resource.get_metadata(group_perm, :tenant)

      # Confirm group is associated with the permission
      assert group_perm.group.id == group.id
      assert group_perm.group.name == group_attrs.name
      assert group_perm.group.description == group_attrs.description

      # Confirm the permission is associated with the group
      assert group_perm.resource |> String.to_existing_atom() == Helpcenter.KnowledgeBase.Category
      assert group_perm.action |> String.to_existing_atom() == :read
    end
  end
end
