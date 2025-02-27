defmodule Helpcenter.Changes.SetTenant do
  use Ash.Resource.Change

  # If tenant and actor are nil, then skipp this.
  def change(changeset, _opts, %{tenant: nil, actor: nil} = context) do
    dbg(context)
    changeset
  end

  # # Only set tenant if it's not already set and actor is available
  def change(
        changeset,
        _opts,
        %{tenant: nil, actor: actor} = %Ash.Resource.Change.Context{} = context
      ) do
    dbg(context)
    Ash.Changeset.set_tenant(changeset, actor.current_team)
  end

  # for any other matching conditions don't set the tenant
  def change(changeset, _opts, context) do
    dbg(context)
    changeset
  end
end
