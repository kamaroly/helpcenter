import Config

# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix assets.deploy` task,
# which you should run after static files are built and
# before starting your production server.
config :helpcenter, HelpcenterWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {0, 0, 0, 0}, port: 4005],
  secret_key_base: System.get_env("SECRET_KEY_BASE_HELPCENTER"),
  server: true,
  # or your domain
  url: [host: "0.0.0.0"],
  http: [port: 4005],
  # check_origin: ["http://localhost:4005", "http://127.0.0.1:4005"]
  check_origin: false

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Helpcenter.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
