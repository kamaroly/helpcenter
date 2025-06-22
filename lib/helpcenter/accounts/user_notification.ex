# lib/helpcenter/accounts/user_notification.ex
defmodule Helpcenter.Accounts.UserNotification do
  use Ash.Resource,
    domain: Helpcenter.Accounts,
    data_layer: AshPostgres.DataLayer,
    # > Add Ash Oban extension for background jobs
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
      # > Ensure this trigger runs for all tenants.
      list_tenants fn -> Helpcenter.Repo.all_tenants() end

      trigger :send do
        # Enable debug logging for testing
        debug? true
        # Specify the queue to use for this trigger
        queue :default
        # Action on this resource that is run when the trigger is invoked
        action :send

        trigger_once? true
        # The action on this resource that is used to retrieve data to work with
        # on this resource. In this case, we want to read unprocessed notifications.
        # check in the actions block for the `unprocessed` action.
        worker_read_action :unprocessed

        # The worker module that will process the job automatically added for you by the Ash Oban extension.
        # You can also specify a custom worker module if needed. It is based on action name
        worker_module_name Helpcenter.Accounts.UserNotification.AshOban.Worker.Send
        scheduler_module_name Helpcenter.Accounts.UserNotification.AshOban.Scheduler.Send
      end
    end
  end

  actions do
    default_accept [:sender_user_id, :recipient_user_id, :subject, :body, :read_at, :status]
    defaults [:read, :create, :update, :destroy]

    update :send do
      description "Send a new user notification to the user"
      change Helpcenter.Accounts.UserNotification.Changes.DeliverEmail
    end

    read :unprocessed do
      description "Read unprocessed notifications"
      filter expr(processed == false)
      prepare build(limit: 100, load: :recipient)
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

  relationships do
    belongs_to :sender, Helpcenter.Accounts.User do
      description "The user who sent the notification"
      source_attribute :recipient_user_id
    end

    belongs_to :recipient, Helpcenter.Accounts.User do
      description "The user who received the notification"
      source_attribute :recipient_user_id
    end
  end
end
