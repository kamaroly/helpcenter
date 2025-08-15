# lib/helpcenter/accounts/group.ex
defmodule Helpcenter.Accounts.Group do
  use Ash.Resource,
    domain: Helpcenter.Accounts,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "groups"
    repo Helpcenter.Repo
  end

  actions do
    default_accept [:name, :description]
    defaults [:create, :read, :update, :destroy]
  end

  code_interface do
    define :list_groups, action: :read
  end

  pub_sub do
    module HelpcenterWeb.Endpoint

    prefix "groups"

    publish_all :update, [[:id, nil]]
    publish_all :create, [[:id, nil]]
    publish_all :destroy, [[:id, nil]]
  end

  preparations do
    prepare Helpcenter.Preparations.SetTenant
  end

  changes do
    change Helpcenter.Changes.SetTenant
  end

  multitenancy do
    strategy :context
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :name, :string do
      description "Group name unique name"
      allow_nil? false
    end

    attribute :description, :string do
      description "Describes the intention of the group"
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    many_to_many :users, Helpcenter.Accounts.User do
      through Helpcenter.Accounts.UserGroup
      source_attribute_on_join_resource :group_id
      destination_attribute_on_join_resource :user_id
    end

    # lib/helpcenter/accounts/group.ex
    has_many :permissions, Helpcenter.Accounts.GroupPermission do
      description "List of permission assigned to this group"
      destination_attribute :group_id
    end
  end

  identities do
    identity :unique_name, [:name]
  end
end
