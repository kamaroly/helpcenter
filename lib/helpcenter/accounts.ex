# lib/helpcenter/accounts.ex
defmodule Helpcenter.Accounts do
  use Ash.Domain, otp_app: :helpcenter

  resources do
    #  the rest of the domain resources

    resource Helpcenter.Accounts.UserNotification do
      define :notify, action: :create
    end
  end
end
