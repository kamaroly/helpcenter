defmodule Helpcenter.Accounts do
  use Ash.Domain,
    otp_app: :helpcenter

  resources do
    resource Helpcenter.Accounts.Token
    resource Helpcenter.Accounts.User
  end
end
