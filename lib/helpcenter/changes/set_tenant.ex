defmodule Helpcenter.Changes.SetTenant do
  @moduledoc """
  Sets user current_team on the changeset as the tenant for change query
  if the tenant is not already provided
  """

  use Ash.Resource.Change

  @doc """
  Set tenant on the changes
  1. If both tenant and actor are not provide, ignore and continue
  2. If tenant is not provided, but actor is provided, the use current_team user
  3. If none of the above conditions are met, ignore and contineu
  """
  def change(changeset, _opts, %{tenant: nil, actor: nil} = _context), do: changeset

  def change(changeset, _opts, %{tenant: nil, actor: actor} = _context) do
    Ash.Changeset.set_tenant(changeset, actor.current_team)
  end

  def change(changeset, _opts, _context), do: changeset

  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end
end
