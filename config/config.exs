# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :pirateXchange,
  ecto_repos: [PirateXchange.Repo]

# Configures the endpoint
config :pirateXchange, PirateXchangeWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: PirateXchangeWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: PirateXchange.PubSub,
  live_view: [signing_salt: "mKRzdbVy"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :pirateXchange, PirateXchange.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

#EctoShorts config
config :ecto_shorts,
  repo: PirateXchange.Repo,
  error_module: EctoShorts.Actions.Error

# Application Configuration
config :pirateXchange,
  available_currencies: [:USD, :EUR, :PLN, :CAD],
  fx_api_url: "http://localhost:4001/query",
  fx_rate_cache: :fx_rate_cache,
  global_ttl: 1000,
  ttl_check_interval: 1000,
  fx_rate_refresh_interval: 1000

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
#Configure auto test runner for dev
if config_env() == :dev do
  config :mix_test_watch, clear: true
end
