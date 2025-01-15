defmodule Helpcenter.Secrets do
  use AshAuthentication.Secret

  def secret_for([:authentication, :tokens, :signing_secret], Helpcenter.Accounts.User, _opts) do
    Application.fetch_env(:helpcenter, :token_signing_secret)
  end
end
