defmodule PirateXchange.FxRates.FxRateTest do
  use ExUnit.Case
  require Application

  alias PirateXchange.FxRates.FxRate

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  @ok_res ~s(
    {"Realtime Currency Exchange Rate":{"1. From_Currency Code":"USD","2. From_Currency Name":"US Dollar","3. To_Currency Code":"PLN","4. To_Currency Name":"Polish Zloty","5. Exchange Rate":"2.23","6. Last Refreshed":"2022-10-22 03:38:16.973344Z","7. Time Zone":"UTC","8. Bid Price":"2.23","9. Ask Price":"2.23"}}
 )

  @json_decoding_error_res "Arrgh"

  describe "get_rate/2" do
    test "should return a valid {:ok, %FxRate{}} tuple", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, @ok_res)
      end)

      assert {:ok, %FxRate{from_currency: :USD, to_currency: :PLN, rate: "2.23"}} ==
        FxRate.get_rate(:USD, :PLN, "http://localhost:#{bypass.port}/query")
    end

    test "should return {:error, :json_decoding_error} with json error", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, @json_decoding_error_res)
      end)

      assert {:error, :json_decoding_error} ==
        FxRate.get_rate(:USD, :PLN, "http://localhost:#{bypass.port}/query")
    end

    test "should return {:ok, %FxRate{..., rate: '1'}} when same currency provided" do
      assert {:ok, %FxRate{from_currency: :USD, to_currency: :USD, rate: "1"}} ==
        FxRate.get_rate(:USD, :USD)
    end

    test "should return {:error, :econnrefused} on api timeout", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, :econnrefused} ==
        FxRate.get_rate(:USD, :PLN, "http://localhost:#{bypass.port}/query")
    end
  end
end
