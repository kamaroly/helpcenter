defmodule Helpcenter.Accounts.User.Changes.CreatePersonalTeam do
  use Ash.Resource.Change

  def change(%Ash.Changeset{action_type: :create} = changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, &create_personal_team/2)
  end

  def change(changeset, _opts, _context), do: changeset

  def atomic(changeset, _opts, _context), do: {:ok, changeset}

  defp create_personal_team(_changeset, user) do
    team_count = Ash.count!(Helpcenter.Accounts.Team) + 1

    team_attrs = %{
      name: "Personal Team",
      domain: "personal_team_#{team_count}",
      owner_user_id: user.id
    }

    Ash.create(Helpcenter.Accounts.Team, team_attrs)
  end
end
