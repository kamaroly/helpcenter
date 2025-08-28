defmodule HelpcenterWeb.Accounts.Users.UserInvitationsLiveTest do
  use HelpcenterWeb.ConnCase

  describe "User Invitations Live test" do
    test "User can list and accept invitation", %{conn: conn} do
      user = create_user()

      conn =
        conn
        |> login(user)
        |> get(~p"/accounts/users/invitations")

      assert html_response(conn, 200) =~ "Email"
      assert html_response(conn, 200) =~ "Team"
    end
  end
end
