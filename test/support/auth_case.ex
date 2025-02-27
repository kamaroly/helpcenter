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
    count = System.unique_integer([:monotonic, :positive])

    team_domain = "team_#{count}"
    user_params = %{email: "john.tester_#{count}@example.com", current_team: team_domain}
    user = Ash.Seed.seed!(Helpcenter.Accounts.User, user_params)

    # Create a new team for the user
    team_attrs = %{name: "Team #{count}", domain: team_domain, owner_user_id: user.id}
    team = Ash.Seed.seed!(Helpcenter.Accounts.Team, team_attrs)

    Ash.Seed.seed!(Helpcenter.Accounts.UserTeam, %{user_id: user.id, team_id: team.id})

    # Return created team
    user
  end
end
