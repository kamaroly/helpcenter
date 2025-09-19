# lib/helpcenter/accounts/invitation/changes/set_invitation_attributes.ex
defmodule Helpcenter.Accounts.Invitation.Changes.SetInvitationAttributes do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    Ash.Changeset.before_transaction(changeset, &set_attributes(&1, context))
  end

  @impl true
  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end

  defp set_attributes(changeset, context) do
    expires_at = DateTime.add(DateTime.utc_now(), 30, :day)

    changeset
    |> Ash.Changeset.force_change_attribute(:expires_at, expires_at)
    |> Ash.Changeset.force_change_attribute(:team, changeset.tenant)
    |> Ash.Changeset.force_change_attribute(:token, Ash.UUIDv7.generate())
    |> Ash.Changeset.force_change_attribute(:team, context.actor.current_team)
    |> Ash.Changeset.force_change_attribute(:inviter_user_id, context.actor.id)
  end
end
