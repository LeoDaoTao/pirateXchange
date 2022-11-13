defmodule PirateXchange.FxRates.FxRateCache do
  alias PirateXchange.FxRates.FxRate
  alias PirateXchange.Currencies.Currency

  @typep currency :: Currency.t

  @cache_name Application.get_env(:pirateXchange, :fx_rate_cache)

  @spec put_fx_rate(FxRate.t) :: :ok
  @spec put_fx_rate(FxRate.t, atom) :: :ok
  def put_fx_rate(
    %FxRate{
      from_currency: from_currency,
      to_currency: to_currency,
      rate: rate},
    cache_name \\ @cache_name) do
      ConCache.put(cache_name, to_key(from_currency, to_currency), rate)
  end

  @spec get_fx_rate(currency, currency, atom) :: {:ok, String.t} | ErrorMessage.t
  def get_fx_rate(from_currency, to_currency, cache_name \\ @cache_name) do
    case ConCache.get(cache_name, to_key(from_currency, to_currency)) do
      nil  -> {:error, ErrorMessage.internal_server_error("fx rate not available")}
      rate -> {:ok, rate}
    end
  end

  defp to_key(from_currency, to_currency) do
    "#{from_currency}|#{to_currency}"
  end
end
