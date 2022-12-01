defmodule PirateXchange.Accounts.UserInfoTest do
  use PirateXchange.DataCase

  import PirateXchange.UserFixtures,
    only: [users: 1, user_no_wallet: 1, user_deleted: 1, wallets: 1]

  import PirateXchange.FxRateFixtures,
    only: [fx_rates: 1]

  alias PirateXchange.Accounts
  alias PirateXchange.Currencies.Money

  describe "total_worth/1" do
    setup [:users, :user_no_wallet, :user_deleted, :wallets, :fx_rates]

    test "should return {:ok, %{user_id:, currency:, integer_amount:}} total worth in target currency", ctx do
      assert {:ok, %{user_id: ctx.user1.id, currency: :USD, integer_amount: 2_500_000}} ===
        Accounts.user_total_worth(%{user_id: ctx.user1.id, currency: :USD})
    end

    test "should return {:ok, %Money{code: :USD, amount: '0.00'}} if user has no wallets", ctx do

      assert {:ok, %Money{code: :USD, amount: "0.00"}} ===
        Accounts.user_total_worth(%{user_id: ctx.user_no_wallet.id, currency: :USD})
    end

    test "should return 'user not found error' if user does not exist", %{user_deleted: user_deleted } do
      assert {:error, %ErrorMessage{code: :not_found, message: "user not found"}} ===
        Accounts.user_total_worth(%{user_id: user_deleted.id, currency: :USD})
    end

    test "should return 'total worth error' if fx rate is not available", ctx do
      assert {:error, %ErrorMessage{code: :internal_server_error, message: "total worth error, fx rate not available"}} ===
        Accounts.user_total_worth(%{user_id: ctx.user1.id, currency: :ARR})
    end
  end
end
