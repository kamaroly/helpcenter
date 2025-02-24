defmodule Helpcenter.Accounts.TeamTest do
  use HelpcenterWeb.ConnCase, async: false
  require Ash.Query

  describe "Team tests" do
    test "User team can be created" do
      user = create_user()
      # Create team under which category will be created
      team =
        Ash.create!(Helpcenter.Accounts.Team, %{
          name: "Team 1",
          domain: "team_1",
          owner_user_id: user.id
        })

      # Confirm team is created
      assert Helpcenter.Accounts.Team
             |> Ash.Query.filter(domain == ^team.domain)
             |> Ash.Query.filter(owner_user_id == ^team.owner_user_id)
             |> Ash.exists?()

      # Confirm the owner's current_team is set successfully

      assert Helpcenter.Accounts.User
             |> Ash.Query.filter(id == ^user.id)
             |> Ash.Query.filter(current_team == ^team.domain)
             |> Ash.exists?()
    end
  end
end
