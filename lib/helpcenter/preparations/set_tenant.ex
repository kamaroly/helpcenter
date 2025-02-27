defmodule Helpcenter.Preparations.SetTenant do
  @moduledoc """
  Sets user current_team on a preparation as the tenant for change query
  if the tenant is not already provided
  """
  use Ash.Resource.Preparation

  @doc """
  Set tenant on preparations
  1. If both tenant and actor are not provide, ignore and continue
  2. If tenant is not provided, but actor is provided, the use current_team user
  3. If none of the above conditions are met, ignore and contineu
  """
  def prepare(query, _opts, %{tenant: nil, actor: nil} = _context), do: query

  def prepare(query, _opts, %{tenant: nil, actor: actor} = _context) do
    Ash.Query.set_tenant(query, actor.current_team)
  end

  def prepare(query, _opts, _context), do: query
end
