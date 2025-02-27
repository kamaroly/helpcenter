defmodule AuthCase do
  def login(conn, user) do
    case AshAuthentication.Jwt.token_for_user(user, %{}, domain: Helpcenter.Accounts) do
      {:ok, token, _claims} ->
        conn
        |> Phoenix.ConnTest.init_test_session(%{})
        |> Plug.Conn.put_session(:user_token, token)

      {:error, reason} ->
        raise "Failed to generate token: #{inspect(reason)}"
    end
  end

  def create_user() do
    user_params = %{email: "john.tester@example.com"}
    Ash.create!(Helpcenter.Accounts.User, user_params, authorize?: false)
  end
end
