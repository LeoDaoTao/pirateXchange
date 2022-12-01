import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :pirateXchange, PirateXchange.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "piratexchange_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# Application Configuration (Test Env)
config :pirateXchange,
  available_currencies: [:USD, :EUR, :PLN, :CAD],
  fx_api_url: "http://localhost:4001/query",
  fx_rate_cache: :fx_rate_cache_test,
  ttl_check_interval: 10_000,
  fx_rate_refresh_interval: 10_000


# We don't run a server during test. If one is required,
# you can enable the server option below.
config :pirateXchange, PirateXchangeWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "9/wMifRQVRlZ7ZxMzq9q52iVV1I1xheosxoOTKaERV8LeL/oILpqGRlTGjjQr5WD",
  server: false

# In test we don't send emails.
config :pirateXchange, PirateXchange.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
