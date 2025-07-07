defmodule Helpcenter.Accounts.Invitation.Changes.SetInvitationAttributes do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    changeset
    |> Ash.Changeset.before_transaction(fn changeset ->
      expires_at = DateTime.add(DateTime.utc_now(), 7, :day)

      changeset
      |> Ash.Changeset.force_change_attribute(:expires_at, expires_at)
      |> Ash.Changeset.force_change_attribute(:token, Ash.UUIDv7.generate())
      |> Ash.Changeset.force_change_attribute(:inviter_user_id, context.actor.id)
      |> Ash.Changeset.force_change_attribute(:team_id, context.actor.current_team_id)
    end)
  end

  @impl true
  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end
end
