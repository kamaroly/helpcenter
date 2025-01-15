defmodule Helpcenter.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      HelpcenterWeb.Telemetry,
      Helpcenter.Repo,
      {DNSCluster, query: Application.get_env(:helpcenter, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Helpcenter.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Helpcenter.Finch},
      # Start a worker by calling: Helpcenter.Worker.start_link(arg)
      # {Helpcenter.Worker, arg},
      # Start to serve requests, typically the last entry
      HelpcenterWeb.Endpoint,
      {AshAuthentication.Supervisor, [otp_app: :helpcenter]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Helpcenter.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HelpcenterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
