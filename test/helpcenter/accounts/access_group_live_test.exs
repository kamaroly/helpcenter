defmodule Helpcenter.Accounts.AccessGroupLiveTest do
  use HelpcenterWeb.ConnCase, async: false

  describe "User Access Group Test:" do
    test "All actions can be listed for permissions" do
      assert Helpcenter.permissions() |> is_list()
    end
  end
end
