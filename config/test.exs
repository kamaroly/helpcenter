import Config
config :helpcenter, Oban, testing: :manual
config :helpcenter, token_signing_secret: "eEDPOnkZl5Qv+3SbqpbbmRoZeyjgYKp6"
config :ash, disable_async?: true

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :helpcenter, Helpcenter.Repo,
  username: "postgres",
  password: "ikijumba",
  hostname: "localhost",
  database: "helpcenter_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :helpcenter, HelpcenterWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "6PDHd+7lZTjSsqZNoz3TFNacwgz9YAtQ2dq7W0kHYJzAAsvaRH30b0PsFKBKsEZ4",
  server: false

# Do NOT set this value for production
config :bcrypt_elixir, log_rounds: 1

# In test we don't send emails
config :helpcenter, Helpcenter.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
