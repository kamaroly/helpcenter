defmodule Helpcenter.Accounts.TeamTest do
  use HelpcenterWeb.ConnCase, async: false
  require Ash.Query

  describe "Team tests" do
    test "User team can be created" do
      user = create_user()

      # Create a new team for the user
      team_attrs = %{name: "Team 1", domain: "team_1", owner_user_id: user.id}
      {:ok, team} = Ash.create(Helpcenter.Accounts.Team, team_attrs)

      # New team should be created successfully
      assert Helpcenter.Accounts.Team
             |> Ash.Query.filter(domain == ^team.domain)
             |> Ash.Query.filter(owner_user_id == ^team.owner_user_id)
             |> Ash.exists?()

      # New team should be set as the current team on the owner
      assert Helpcenter.Accounts.User
             |> Ash.Query.filter(id == ^user.id)
             |> Ash.Query.filter(current_team == ^team.domain)
             #  User resource has special policies for authorizations. We are skipping authorization by setting it to false
             |> Ash.exists?(authorize?: false)

      # New team should be added to the teams list of the owner
      assert Helpcenter.Accounts.User
             |> Ash.Query.filter(id == ^user.id)
             |> Ash.Query.filter(teams.id == ^team.id)
             |> Ash.exists?(authorize?: false)
    end
  end
end
