defmodule PirateXchange.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  alias PirateXchange.FxRates.FxRateTask

  # ConCache Settigns
  @global_ttl PirateXchange.Config.global_ttl
  @ttl_check_interval PirateXchange.Config.ttl_check_interval
  @available_currencies PirateXchange.Config.available_currencies

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PirateXchange.Repo,
      PirateXchangeWeb.Telemetry,
      {Phoenix.PubSub, name: PirateXchange.PubSub},
      PirateXchangeWeb.Endpoint,
      {Absinthe.Subscription, [PirateXchangeWeb.Endpoint]},
      {ConCache,
         [
           name: :fx_rate_cache,
           global_ttl: @global_ttl,
           ttl_check_interval: @ttl_check_interval,
           touch_on_read: false
         ]}
    ] ++ start_fx_rate_tasks()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PirateXchange.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PirateXchangeWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  # start fx rate cache and updates via tasks
  # same currecy has exchange rate of "1"
  def start_fx_rate_tasks do
    for from_currency <- @available_currencies,
        to_currency   <- @available_currencies do
      FxRateTask.child_spec({from_currency, to_currency})
    end
  end
end
