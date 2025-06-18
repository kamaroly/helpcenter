defmodule Helpcenter.Accounts.UserNotification do
  use Ash.Resource,
    domain: Helpcenter.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshOban]

  postgres do
    table "user_notifications"
    repo Helpcenter.Repo
  end

  oban do
    triggers do
      # Since our application is multitenant, we need to ensure that we specify the tenant
      # triggers are going to run for.
      list_tenants fn -> Helpcenter.Repo.all_tenants() end

      trigger :deliver do
        action :deliver
        queue :default
        worker_read_action :read
        actor_persister :none

        debug? true
        worker_module_name Helpcenter.Accounts.UserNotification.AshOban.Worker.Deliver
        scheduler_module_name Helpcenter.Accounts.UserNotification.AshOban.Scheduler.Deliver
      end
    end
  end

  actions do
    default_accept [:sender_user_id, :recipient_user_id, :subject, :body, :read_at, :status]
    defaults [:read, :create, :update, :destroy]

    create :send do
      description "Send a new user notification to the user"
      accept [:sender_user_id, :recipient_user_id, :subject, :body]
    end

    update :deliver do
      description "Mark a notification as delivered"
      change Helpcenter.Accounts.UserNotification.Changes.DeliverEmail
    end
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
    uuid_primary_key :id

    attribute :sender_user_id, :uuid do
      description "The user who sent the notification"
      allow_nil? true
    end

    attribute :recipient_user_id, :uuid do
      description "The user who received the notification"
      allow_nil? false
    end

    attribute :subject, :string do
      description "The subject of the notification"
      allow_nil? false
    end

    attribute :body, :string do
      description "The body of the notification"
      allow_nil? false
    end

    attribute :read_at, :datetime do
      description "The time a notification has been read"
      default nil
      allow_nil? true
    end

    attribute :status, :atom do
      description "The status of the notification"
      default :unread
      allow_nil? false
      constraints one_of: [:unread, :read, :archived]
    end

    attribute :processed, :boolean do
      description "Whether the notification has been processed"
      default false
      allow_nil? false
    end

    timestamps()
  end
end
