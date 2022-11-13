defmodule PirateXchange.Accounts.UserInfoTest do
  use PirateXchange.DataCase

  import PirateXchange.UserFixtures, only: [users: 1, user_no_wallet: 1, user_deleted: 1, wallets: 1]

  alias PirateXchange.Accounts
  alias PirateXchange.Currencies.Money
  alias PirateXchange.FxRates.FxRate
  alias PirateXchange.FxRates.FxRateCache

  @fx_rate_pln %FxRate{from_currency: :PLN, to_currency: :USD, rate: "1.50"}
  @fx_rate_usd %FxRate{from_currency: :USD, to_currency: :USD, rate: "1"}

  describe "total_worth/1" do
    setup [:users, :user_no_wallet, :user_deleted, :wallets]

    test "should return {:ok, %Money{}} total worth in target currency", ctx do
      assert :ok = FxRateCache.put_fx_rate(@fx_rate_pln)
      assert :ok = FxRateCache.put_fx_rate(@fx_rate_usd)

      assert {:ok, "1.50"} === FxRateCache.get_fx_rate(:PLN, :USD)
      assert {:ok, "1"}    === FxRateCache.get_fx_rate(:USD, :USD)

      assert {:ok, %Money{code: :USD, amount: "25000.00"}} ===
        Accounts.user_total_worth(%{user_id: ctx.user1.id, currency: :USD})
    end

    test "should return {:ok, %Money{code: :USD, amount: '0.00'}} if user has no wallets", ctx do

      assert {:ok, %Money{code: :USD, amount: "0.00"}} ===
        Accounts.user_total_worth(%{user_id: ctx.user_no_wallet.id, currency: :USD})
    end

    test "should return {:error, :user_not_found} if user does not exist", %{user_deleted: user_deleted } do
      assert {:error, %ErrorMessage{code: :not_found, message: "user not found"}} ===
        Accounts.user_total_worth(%{user_id: user_deleted.id, currency: :USD})
    end

    test "should return {:error, :fx_rate_not_available} if fx rate is not available", ctx do
      assert {:error, %ErrorMessage{code: :internal_server_error, message: "fx rate not available"}} ===
        Accounts.user_total_worth(%{user_id: ctx.user1.id, currency: :ARR})
    end
  end


end
