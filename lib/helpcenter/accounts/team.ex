defmodule Helpcenter.Accounts.Team do
  require Ash.Resource.Change.Builtins

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

  code_interface do
    # the action open can be omitted because it matches the function name
    define :by_domain, args: [:domain], action: :by_domain
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
    default_accept [:name, :domain, :description, :owner_user_id]
    defaults [:read]

    create :create do
      primary? true
      change Helpcenter.Accounts.Team.Changes.AssociateUserToTeam
      change Helpcenter.Accounts.Team.Changes.SetOwnerCurrentTeamAfterCreate
    end

    read :by_domain do
      description "This action is used to read a team by its domain"
      filter expr(domain == ^arg(:domain))
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
      description "Team or organisation name"
    end

    attribute :domain, :string do
      allow_nil? false
      public? true
      description "Domain name of the team or organisation"
    end

    attribute :description, :string, allow_nil?: true, public?: true

    timestamps()
  end

  identities do
    identity :unique_domain, [:domain] do
      description "Identity to find a team by its domain"
    end
  end

  relationships do
    belongs_to :owner, Helpcenter.Accounts.User do
      source_attribute :owner_user_id
    end

    many_to_many :users, Helpcenter.Accounts.User do
      through Helpcenter.Accounts.UserTeam
      source_attribute_on_join_resource :team_id
      destination_attribute_on_join_resource :user_id
    end
  end
end
