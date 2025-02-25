defmodule Helpcenter.Accounts.User.Notifiers.CreatePersonalTeamNotification do
  use Ash.Notifier

  def notify(%Ash.Notifier.Notification{data: user, action: %{type: :create}}) do
    create_personal_team(user)
  end

  def notify(%Ash.Notifier.Notification{} = _notification), do: :ok

  defp create_personal_team(user) do
    team_count = Ash.count!(Helpcenter.Accounts.Team) + 1

    team_attrs = %{
      name: "Personal Team",
      domain: "personal_team_#{team_count}",
      owner_user_id: user.id
    }

    Ash.create!(Helpcenter.Accounts.Team, team_attrs)
  end
end
