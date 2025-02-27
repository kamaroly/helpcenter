# test/helpcenter/accounts/group_permission_test.exs
defmodule Helpcenter.Accounts.GroupPermissionTest do
  use HelpcenterWeb.ConnCase, async: false
  require Ash.Query

  describe "Access Group Permission Tests" do
    test "Permission can be added to a group" do
      # Prepare data
      perm_attr = %{action: "read", resource: "category"}
      permission = Ash.create!(Helpcenter.Accounts.Permission, perm_attr)

      user = create_user()
      group_attrs = %{name: "Accountants", description: "Can manage billing in the system"}
      group = Ash.create!(Helpcenter.Accounts.Group, group_attrs, actor: user)

      # Attempt to link group to permission
      group_perm_attrs = %{group_id: group.id, permission_id: permission.id}

      group_perm =
        Ash.create!(
          Helpcenter.Accounts.GroupPermission,
          group_perm_attrs,
          actor: user,
          load: [:group, :permission]
        )

      # Confirm that the association happened and in the right tenant
      assert user.current_team == Ash.Resource.get_metadata(group_perm, :tenant)
      assert group_perm.permission.id == permission.id
      assert group_perm.group.id == group.id
    end
  end
end
