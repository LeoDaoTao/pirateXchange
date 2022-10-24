defmodule PirateXchange.FxRates.FxRateApiTest do
  use ExUnit.Case

  alias PirateXchange.FxRates.FxRateApi

  @ok_res {:ok,
 %{
   body: "{\"Realtime Currency Exchange Rate\":{\"5. Exchange Rate\":\"2.8\"}}",
   status_code: 200
 }}

  @error_res_garbage_body {:ok,
 %{
   body: "garbage",
   status_code: 200
 }}

  describe "get_rate/3" do
    test "should return exchange rate {:ok, rate} tuple" do
      assert FxRateApi.get_rate(:USD, :PLN, @ok_res) ==
        {:ok, "2.8"}
    end

    test "should return {:error, :json_decoding_error} for garbage body return" do
      assert FxRateApi.get_rate(:USD, :PLN, @error_res_garbage_body) ==
        {:error, :json_decoding_error}
    end

    test "should return {:error, :unknown_error} for unexpected errors" do
      assert FxRateApi.get_rate(:USD, :PLN, "whoopsie") ==
        {:error, :unknown_error}
    end
  end
end
