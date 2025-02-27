defmodule Helpcenter.Accounts.Permission do
  use Ash.Resource,
    domain: Helpcenter.Accounts,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "permissions"
    repo Helpcenter.Repo
  end

  actions do
    default_accept [:action, :resource]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :action, :string do
      description "Action name or type on the resource to authorize"
      allow_nil? false
    end

    attribute :resource, :string do
      description "Resource this authorization is for"
      allow_nil? false
    end

    timestamps()
  end
end
