defmodule Helpcenter.Notifications.UserNotification do
  use Ash.Resource,
    domain: Helpcenter.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshOban]

  postgres do
    table "user_notifications"
    repo Helpcenter.Repo
  end

  # ================================================================
  # Ash Oban configuration to add background jobs for your resource.
  # ================================================================
  oban do
    triggers do
      # Since our application is multitenant, we need to tell ash tenants to run this trigger for
      # triggers are going to run for.
      list_tenants fn -> Helpcenter.Repo.all_tenants() end

      trigger :deliver do
        action :deliver_notification # > The action on this resource to be triggered
        queue :default # > Oban queue name in which the job will be placed
        worker_read_action :read # > The action the job will use to read data

        debug? true # > Enable debug for testing and development purposes
        worker_module_name Helpcenter.Notifications.UserNotification.AshOban.Worker.Deliver
        scheduler_module_name Helpcenter.Notifications.UserNotification.AshOban.Scheduler.Deliver
      end
    end
  end

  # ================================================================
  # End of Ash Oban configuration
  # ================================================================

  actions do
    default_accept [:sender_user_id, :recipient_user_id, :subject, :body, :read_at, :status]
    defaults [:read, :create, :update, :destroy]

    create :send do
      description "Send a new user notification to the user"
      accept [:sender_user_id, :recipient_user_id, :subject, :body]
    end

    update :deliver_notification do
      description "Mark a notification as delivered"
      change Helpcenter.Accounts.UserNotification.Changes.DeliverEmail
    end
  end
  # ... other definitions...
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
