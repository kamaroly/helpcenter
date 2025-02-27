defmodule Helpcenter.Accounts.Team.Changes.SetOwnerCurrentTeam do
  use Ash.Resource.Change

  def change(changeset, _team, _context) do
    Ash.Changeset.after_action(changeset, &set_owner_current_team/2)
  end

  defp set_owner_current_team(_changeset, team) do
    opts = [authorize?: false]

    {:ok, _user} =
      Helpcenter.Accounts.User
      |> Ash.get!(team.owner_user_id, opts)
      |> Ash.Changeset.for_update(:set_current_team, %{team: team.domain})
      |> Ash.update(opts)

    {:ok, team}
  end
end
