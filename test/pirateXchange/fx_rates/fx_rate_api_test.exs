defmodule PirateXchange.FxRates.FxRateApiTest do
  use ExUnit.Case

  alias PirateXchange.BypassHelper
  alias PirateXchange.FxRates.FxRate
  alias PirateXchange.FxRates.FxRateApi

  setup do
    {:ok, bypass: Bypass.open()}
  end

  @ok_res ~s(
    {"Realtime Currency Exchange Rate":{"1. From_Currency Code":"USD","2. From_Currency Name":"US Dollar","3. To_Currency Code":"PLN","4. To_Currency Name":"Polish Zloty","5. Exchange Rate":"2.23","6. Last Refreshed":"2022-10-22 03:38:16.973344Z","7. Time Zone":"UTC","8. Bid Price":"2.23","9. Ask Price":"2.23"}}
 )

  @json_decoding_error_res "Arrgh"

  describe "get_rate/2" do
    test "should return a valid {:ok, %FxRate{}} tuple", ctx do
      BypassHelper.bypass_expect(@ok_res, ctx.bypass)

      assert {:ok, %FxRate{from_currency: :USD, to_currency: :PLN, rate: "2.23"}} ===
        FxRateApi.get_rate(:USD, :PLN, "http://localhost:#{ctx.bypass.port}/query")
    end

    test "should return 'json decoding error' with json error", ctx do
      BypassHelper.bypass_expect(@json_decoding_error_res, ctx.bypass)

      assert {:error, %ErrorMessage{code: :internal_server_error, message: "json decoding error"}} ===
        FxRateApi.get_rate(:USD, :PLN, "http://localhost:#{ctx.bypass.port}/query")
    end

    test "should return {:ok, %FxRate{..., rate: '1.00'}} when same currency provided" do
      assert {:ok, %FxRate{from_currency: :USD, to_currency: :USD, rate: "1.00"}} ===
        FxRateApi.get_rate(:USD, :USD)
    end

    test "should return 'fx rate server timeout'on api timeout", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %ErrorMessage{code: :gateway_timeout, message: "fx rate server timeout"}} ===
        FxRateApi.get_rate(:USD, :PLN, "http://localhost:#{bypass.port}/query")
    end
  end
end
