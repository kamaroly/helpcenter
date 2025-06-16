defmodule Helpcenter.Accounts.UserNotification do
  use Ash.Resource,
    domain: Helpcenter.Accounts,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "user_notifications"
    repo Helpcenter.Repo
  end

  actions do
    default_accept [:sender_user_id, :recipient_user_id, :subject, :body, :read_at, :status]

    create :send do
      description "Send a new user notification to the user"
      accept [:sender_user_id, :recipient_user_id, :subject, :body]
      change Helpcenter.Accounts.UserNotification.Changes.SendEmail
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

    timestamps()
  end
end
