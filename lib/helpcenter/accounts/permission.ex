# lib/helpcenter/accounts/permission.ex
defmodule Helpcenter.Accounts.Permission do
  @doc """
  Get a list of maps of resources and their actions
  Example:
    iex> Helpcenter.Accounts.Permission.get_permissions()
    iex> [%{resource: Helpcenter.Accounts.GroupPermission, action: :create}]
  """

  def permissions() do
    get_all_domain_resources()
    |> Enum.map(&map_resource_actions/1)
    |> Enum.flat_map(& &1)
  end

  defp map_resource_action(action, resource) do
    %{action: action.name, resource: resource}
  end

  defp map_resource_actions(resource) do
    Ash.Resource.Info.actions(resource)
    |> Enum.map(&map_resource_action(&1, resource))
  end

  defp get_all_domain_resources() do
    Application.get_env(:helpcenter, :ash_domains)
    |> Enum.map(&Ash.Domain.Info.resources(&1))
    |> Enum.flat_map(& &1)
  end
end
