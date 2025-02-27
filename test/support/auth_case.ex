defmodule AuthCase do
  require Ash.Query

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
    # Create a user and the person team automatically.
    # The person team will be the tenant for the query
    user_params = %{
      email: "john.tester@example.com",
      password: "12345678",
      password_confirmation: "12345678"
    }

    Ash.create!(
      Helpcenter.Accounts.User,
      user_params,
      action: :register_with_password,
      authorize?: false
    )

    # Reload the user with current_team set
    Helpcenter.Accounts.User
    |> Ash.Query.filter(email == ^user_params.email)
    |> Ash.read_first!(authorize?: false)
  end
end
