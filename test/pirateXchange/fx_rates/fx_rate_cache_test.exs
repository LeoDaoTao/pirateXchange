defmodule PirateXchange.FxRates.FxRateCacheTest do
  use ExUnit.Case, async: true

  alias PirateXchange.FxRates.FxRate
  alias PirateXchange.FxRates.FxRateCache

  @fx_rate %FxRate{from_currency: :USD, to_currency: :PLN, rate: "2.22"}

  describe "put_fx_rate/2" do
    test "should store fx rate in cache and return :ok" do
      assert :ok = FxRateCache.put_fx_rate(@fx_rate)
    end

    test "should read fx rate in cache and return {:ok, String.t}" do
      assert :ok = FxRateCache.put_fx_rate(@fx_rate)

      assert {:ok, "2.22"} === FxRateCache.get_fx_rate(:USD, :PLN)
    end

    test "should expire cache and return {:error, :not_available}" do
      assert :ok = FxRateCache.put_fx_rate(@fx_rate)

      Process.sleep(100)

      assert {:error, :not_available} === FxRateCache.get_fx_rate(:USD, :PLN)
    end
  end
end
