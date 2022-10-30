defmodule PirateXchange.FxRates.FxRateTaskTest do
  use ExUnit.Case

  alias PirateXchange.FxRates.FxRateTask
  alias PirateXchange.FxRates.FxRateCache

  setup do
    start_supervised!({ConCache, name: :fx_test_cache, ttl_check_interval: 30, global_ttl: 1_000})
    bypass = Bypass.open()
    FxRateTask.start_link({:USD, :PLN}, :fx_test_cache, "http://localhost:#{bypass.port}/query")
    {:ok, bypass: bypass}
  end

  @ok_res ~s(
    {"Realtime Currency Exchange Rate":{"1. From_Currency Code":"USD","2. From_Currency Name":"US Dollar","3. To_Currency Code":"PLN","4. To_Currency Name":"Polish Zloty","5. Exchange Rate":"2.23","6. Last Refreshed":"2022-10-22 03:38:16.973344Z","7. Time Zone":"UTC","8. Bid Price":"2.23","9. Ask Price":"2.23"}}
  )

  describe "run/3" do
    test "shuld fetch the fx rate and store in FxRateCache", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, @ok_res)
      end)

      Process.sleep(20)

      assert {:ok, "2.23"} === FxRateCache.get_fx_rate(:USD, :PLN, :fx_test_cache)
    end
  end
end
