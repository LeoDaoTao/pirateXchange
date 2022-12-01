defmodule PirateXchange.FxRateFixtures do
  alias PirateXchange.FxRates.FxRate
  alias PirateXchange.FxRates.FxRateCache

  @fx_rate_pln %FxRate{from_currency: :PLN, to_currency: :USD, rate: "1.50"}
  @fx_rate_usd %FxRate{from_currency: :USD, to_currency: :USD, rate: "1.00"}

  def fx_rates(_ctx) do
    FxRateCache.put_fx_rate(@fx_rate_pln)
    FxRateCache.put_fx_rate(@fx_rate_usd)
  end
end
