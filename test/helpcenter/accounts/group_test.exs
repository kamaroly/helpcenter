# test/helpcenter/accounts/group_test.exs
defmodule Helpcenter.Accounts.GroupTest do
  use HelpcenterWeb.ConnCase, async: false
  require Ash.Query

  describe "Access Group Tests" do
    test "Groups can be added to a tenant" do
      # Groups are specific to a tenant. So we need a tenant for group
      user = create_user()

      group_attrs = %{
        name: "Accountants",
        description: "Can manage billing in the system"
      }

      {:ok, _group} =
        Ash.create(
          Helpcenter.Accounts.Group,
          group_attrs,
          actor: user,
          load: [:permissions, :users],
          authorize?: false
        )

      assert Helpcenter.Accounts.Group
             |> Ash.Query.filter(name == ^group_attrs.name)
             |> Ash.Query.filter(description == ^group_attrs.description)
             |> Ash.exists?(actor: user)
    end
  end
end
