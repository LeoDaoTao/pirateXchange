defmodule PirateXchange.FxRates.FxRateTask do
  use Task, restart: :permanent
  require Logger

  alias PirateXchange.FxRates.FxRate
  alias PirateXchange.FxRates.FxRateApi
  alias PirateXchange.FxRates.FxRateCache
  alias PirateXchange.SubscriptionPublisher, as: Publish

  @cache_name PirateXchange.Config.fx_rate_cache
  @fx_api_url PirateXchange.Config.fx_api_url
  @fx_rate_refresh_interval PirateXchange.Config.fx_rate_refresh_interval

  @typep currency :: PirateXchange.Currencies.Currency.t

  @spec start_link({currency, currency}, atom) :: {:ok, pid}
  def start_link({from_currency, to_currency}, cache_name \\ @cache_name, url \\ @fx_api_url) do
    Task.start_link(__MODULE__, :run, [from_currency, to_currency, cache_name, url])
  end

  @spec child_spec({currency, currency}) :: Supervisor.child_spec
  def child_spec({from_currency, to_currency}) do
    %{
      id: "fx_rate_#{from_currency}_#{to_currency}",
      start: {__MODULE__, :start_link, [{from_currency, to_currency}]}
    }
  end

  def run(from_currency, to_currency, cache_name \\ @cache_name, url \\ @fx_api_url) do
    case FxRateApi.get_rate(from_currency, to_currency, url) do
      {:ok, rate = %FxRate{}} ->
        FxRateCache.put_fx_rate(rate, cache_name)
        Publish.fx_rate_change(rate)

      {:error, error} ->
        Logger.error(error)
    end

    Process.sleep(@fx_rate_refresh_interval)
    run(from_currency, to_currency, cache_name)
  end
end
