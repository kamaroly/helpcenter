defmodule HelpcenterWeb.Accounts.Users.UsersLiveTest do
  use HelpcenterWeb.ConnCase

  describe "UsersLive" do
    test "renders the users page", %{conn: conn} do
      user = create_user()

      conn =
        conn
        |> login(user)
        |> get(~p"/accounts/users")

      assert html_response(conn, 200) =~ "Users"
      assert html_response(conn, 200) =~ "Email"
      assert html_response(conn, 200) =~ "Team"
    end
  end
end
