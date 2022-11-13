defmodule PirateXchange.FxRates do
  alias PirateXchange.Currencies.Currency
  alias PirateXchange.FxRates.FxRateCache

  @opaque currency :: Currency.t

  @cache_name :fx_rate_cache

  @spec get(currency, currency, atom) :: {:ok, String.t} | {:error, ErrorMessage.t}
  defdelegate get(from_currency, to_currency, cache_name \\ @cache_name),
                  to: FxRateCache, as: :get_fx_rate
end
