defmodule PirateXchange.FxRates.FxRateCacheTest do
  use ExUnit.Case, async: true

  alias PirateXchange.FxRates.FxRate
  alias PirateXchange.FxRates.FxRateCache

  @fx_rate %FxRate{from_currency: :USD, to_currency: :PLN, rate: "1.50"}
  @fx_rate_same_curency %FxRate{from_currency: :USD, to_currency: :USD, rate: "1.00"}

  describe "put_fx_rate/2" do
    test "should store fx rate in cache and return :ok" do
      assert :ok = FxRateCache.put_fx_rate(@fx_rate)
    end

    test "should read fx rate in cache and return {:ok, String.t}" do
      assert :ok = FxRateCache.put_fx_rate(@fx_rate)

      assert {:ok, "1.50"} === FxRateCache.get_fx_rate(:USD, :PLN)
    end

    test "should return rate 1.00 for same currency" do
      assert :ok = FxRateCache.put_fx_rate(@fx_rate_same_curency)

      assert {:ok, "1.00"} === FxRateCache.get_fx_rate(:USD, :USD)
    end
  end
end
