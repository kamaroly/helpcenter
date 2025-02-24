defmodule Helpcenter.Accounts.Team do
  use Ash.Resource,
    domain: Helpcenter.Accounts,
    data_layer: AshPostgres.DataLayer

  @doc """
  Tell ash to use domain as the tenant database prefix when we are using
  postgresql as the database, otherwise use the ID
  """
  defimpl Ash.ToTenant do
    def to_tenant(resource, %{:domain => domain, :id => id}) do
      if Ash.Resource.Info.data_layer(resource) == AshPostgres.DataLayer &&
           Ash.Resource.Info.multitenancy_strategy(resource) == :context do
        domain
      else
        id
      end
    end
  end

  postgres do
    table "teams"
    repo Helpcenter.Repo

    manage_tenant do
      template ["", :domain]
      create? true
      update? false
    end
  end

  actions do
    default_accept [:name, :domain, :description]
    defaults [:create, :read]
  end

  attributes do
    uuid_v7_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :domain, :string, allow_nil?: false, public?: true
    attribute :description, :string, allow_nil?: true, public?: true

    timestamps()
  end
end
