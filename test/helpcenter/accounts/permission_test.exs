# test/helpcenter/accounts/permission_test.exs
defmodule Helpcenter.Accounts.PermissionTest do
  use HelpcenterWeb.ConnCase, async: false
  require Ash.Query

  describe "Permission Resourc:" do
    test "Permission Can be Added" do
      perm_attr = %{action: "read", resource: "category"}
      {:ok, _perm} = Ash.create(Helpcenter.Accounts.Permission, perm_attr)

      assert Helpcenter.Accounts.Permission
             |> Ash.Query.filter(action == ^perm_attr.action)
             |> Ash.Query.filter(resource == ^perm_attr.resource)
             |> Ash.exists?()
    end
  end
end
