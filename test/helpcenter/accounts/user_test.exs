defmodule Helpcenter.Accounts.UserTest do
  use HelpcenterWeb.ConnCase, async: false
  require Ash.Query

  describe "User tests:" do
    test "User creation - creates personal team automatically" do
      # Create a new user
      user_params = %{email: "john.tester@example.com"}
      user = Ash.create!(Helpcenter.Accounts.User, user_params, authorize?: false)

      # New User should have a personal team created for them automatically
      team_count = Ash.count!(Helpcenter.Accounts.Team) + 1
      personal_team = "personal_team_#{team_count}"

      # Confirm that the new user has a personal team created for them automatically
      assert Helpcenter.Accounts.User
             |> Ash.Query.filter(id == ^user.id)
             |> Ash.Query.filter(email == user_params.email)
             |> Ash.Query.filter(current_team == ^personal_team)
             |> Ash.read_first(authorize?: false)
    end
  end
end
