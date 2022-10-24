defmodule PirateXchange.FxRates.FxRatesTest do
  use ExUnit.Case

  alias PirateXchange.FxRates.FxRate

  describe "get_rate/2" do
    test "should return a valid {:ok, %FxRate{}} tuple" do
      assert FxRate.get_rate(:USD, :PLN) ==
        {:ok, %FxRate{
          from_currency: :USD,
          to_currency: :PLN,
          rate: "42.42"
          }
        }
    end
  end
end
