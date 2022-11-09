defmodule PirateXchange.WalletsTest do
  use PirateXchange.DataCase

  import PirateXchange.UserFixtures

  alias PirateXchange.FxRates
  alias PirateXchange.FxRates.FxRate
  alias PirateXchange.FxRates.FxRateCache
  alias PirateXchange.Currencies.Money
  alias PirateXchange.Wallets
  alias PirateXchange.Wallets.Wallet

  @fx_rate_pln %FxRate{from_currency: :PLN, to_currency: :USD, rate: "1.50"}
  @fx_rate_usd %FxRate{from_currency: :USD, to_currency: :USD, rate: "1"}

  describe "create_wallet/1" do
    setup :user

    test "should create a valid wallet for user and currency, with $100 balance", %{user: user} do
      user_id = user.id
      assert {:ok, %Wallet{user_id: ^user_id, currency: :USD, integer_amount: 10_000}} =
        Wallets.create_wallet(%{user_id: user_id, currency: :USD, integer_amount: 10_000})

      assert [%Wallet{user_id: ^user_id, integer_amount: 10_000}] = Repo.all(Wallet)
    end

    test "should not create a wallet with invalid currency & return {:error, :currency_not_allowed}", %{user: user} do
      assert {:error, :currency_not_allowed} = Wallets.create_wallet(%{user_id: user.id, currency: :ARR, integer_amount: 1})
    end

    test "should not create a wallet with existing currency & return {:error, :wallet_exists}", %{user: user} do
      user_id = user.id
      assert {:ok, %Wallet{user_id: ^user_id, currency: :USD}} = Wallets.create_wallet(%{user_id: user.id, currency: :USD, integer_amount: 1})

      assert {:error, :wallet_exists} = Wallets.create_wallet(%{user_id: user.id, currency: :USD, integer_amount: 1})
    end
  end

  describe "find_user_wallet/1" do
    setup [:user, :user_no_wallet, :wallet]

    test "should find a user wallet", %{user: user, wallet: wallet} do
      user_id = user.id
      currency = wallet.currency

      assert {:ok, %Wallet{user_id: ^user_id, currency: :USD, integer_amount: 10_000}} =
        Wallets.find_user_wallet(%{user_id: user_id, currency: currency})
    end

    test "should return {:error, :wallet_not_found} for users with no wallets", %{user_no_wallet: user} do
      assert {:error, :wallet_not_found} = Wallets.find_user_wallet(%{user_id: user.id, currency: :USD})
    end
  end

  describe "find_user_wallets/1" do
    setup [:user, :user_no_wallet, :wallets]

    test "should return {:ok, [%Wallet{}]} for user with wallets", %{user: user, wallets: wallets} do
      assert {:ok, ^wallets} = Wallets.find_user_wallets(%{user_id: user.id})
    end

    test "shoud return {:error, :wallets_not_found} for user with no wallets", %{user_no_wallet: user} do
      assert {:error, :wallets_not_found} = Wallets.find_user_wallets(%{user_id: user.id})
    end
  end

  describe "user_total_worth/1" do
    setup [:user, :user_no_wallet, :user_deleted, :wallets]

    test "should return {:ok, %Money{}} total worth in target currency", %{user: user} do
      assert :ok = FxRateCache.put_fx_rate(@fx_rate_pln)
      assert :ok = FxRateCache.put_fx_rate(@fx_rate_usd)

      assert {:ok, "1.50"} === FxRateCache.get_fx_rate(:PLN, :USD)
      assert {:ok, "1"}    === FxRateCache.get_fx_rate(:USD, :USD)

      assert {:ok, %Money{code: :USD, amount: "25000.00"}} ===
        Wallets.user_total_worth(%{user_id: user.id, to_currency: :USD})
    end

    test "should return {:ok, %Money{code: :USD, amount: '0.00'}} if user has no wallets", %{user_no_wallet: user} do

      assert {:ok, %Money{code: :USD, amount: "0.00"}} ===
        Wallets.user_total_worth(%{user_id: user.id, to_currency: :USD})
    end

    test "should return {:error, :user_not_found} if user does not exist", %{user_deleted: user_deleted } do
      assert {:error, :user_not_found} ===
        Wallets.user_total_worth(%{user_id: user_deleted.id, to_currency: :USD})
    end

    test "should return {:error, :fx_rate_not_available} if fx rate is not available", %{user: user} do
      assert {:error, :fx_rate_not_available} ===
        Wallets.user_total_worth(%{user_id: user.id, to_currency: :ARR})
    end
  end
end
