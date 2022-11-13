defmodule PirateXchange.WalletsTest do
  use PirateXchange.DataCase

  import PirateXchange.UserFixtures,
    only: [users: 1, wallets: 1, user_no_wallet: 1]

  alias PirateXchange.Wallets
  alias PirateXchange.Wallets.Transfer
  alias PirateXchange.Wallets.Wallet
  alias PirateXchange.FxRates.FxRate
  alias PirateXchange.FxRates.FxRateCache

  @fx_rate %FxRate{from_currency: :USD, to_currency: :PLN, rate: "1.50"}
  @bad_fx_rate %FxRate{from_currency: :USD, to_currency: :PLN, rate: nil}

  describe "create_wallet/1" do
    setup :users

    test "should create a valid wallet for user and currency, with $100 balance", ctx do
      user_id = ctx.user1.id
      assert {:ok, %Wallet{user_id: ^user_id, currency: :USD, integer_amount: 10_000}} =
        Wallets.create_wallet(%{user_id: user_id, currency: :USD, integer_amount: 10_000})

      assert [%Wallet{user_id: ^user_id, integer_amount: 10_000}] = Repo.all(Wallet)
    end

    test "should not create a wallet with invalid currency & return 'currency_not_allowed'", ctx do
      assert {:error, %ErrorMessage{code: :not_found, message: "currency not allowed"}}
        Wallets.create_wallet(%{user_id: ctx.user1.id, currency: :ARR, integer_amount: 1})
    end

    test "should not create a wallet with existing currency & return 'wallet_exists'", ctx do
      user_id = ctx.user1.id
      assert {:ok, %Wallet{user_id: ^user_id, currency: :USD}} =
        Wallets.create_wallet(%{user_id: ctx.user1.id, currency: :USD, integer_amount: 1})

      assert {:error, %ErrorMessage{code: :internal_server_error, message: "wallet exists"}} =
        Wallets.create_wallet(%{user_id: ctx.user1.id, currency: :USD, integer_amount: 1})
    end
  end

  describe "all/1" do
    setup [:users, :wallets]

    test "should return a list of Wallets for given currency" do
      #IO.inspect wallets = Wallets.all(%{currency: :PLN})
      #IO.inspect ctx.wallets
    end
  end

  describe "find_user_wallet/1" do
    setup [:users, :user_no_wallet, :wallets]

    test "should find a user wallet", ctx do
      user_id = ctx.user1.id

      assert {:ok, %Wallet{user_id: ^user_id, currency: :USD, integer_amount: 10_000}} =
        Wallets.find_user_wallet(%{user_id: user_id, currency: :USD})
    end

    test "should return {:error, :wallet_not_found} for users with no wallets", ctx do
      assert %ErrorMessage{code: :not_found, message: "wallet not found"} =
        Wallets.find_user_wallet(%{user_id: ctx.user_no_wallet.id, currency: :USD})
    end
  end

  describe "find_user_wallets/1" do
    setup [:users, :user_no_wallet, :wallets]

    test "should return {:ok, [%Wallet{}]} for user with wallets", ctx do
      wallets = ctx.user1_wallets
      assert {:ok, ^wallets} =
        Wallets.find_user_wallets(%{user_id: ctx.user1.id})
    end

    test "shoud return {:error, :wallets_not_found} for user with no wallets", ctx do
      assert %ErrorMessage{code: :not_found, message: "wallets not found"} =
        Wallets.find_user_wallets(%{user_id: ctx.user_no_wallet.id})
    end
  end

  describe "transfer/1" do
    setup [:users, :user_no_wallet, :wallets]

    test "should transfer 100.00 USD from one user to 150.00 PLN to another user",
      ctx do
      transfer = %Transfer{
        from_user_id: ctx.user1.id,
        from_currency: :USD,
        integer_amount: 10000,
        to_user_id: ctx.user2.id,
        to_currency: :PLN
      }

      assert :ok = FxRateCache.put_fx_rate(@fx_rate)

      assert {:ok, "1.50"} === FxRateCache.get_fx_rate(:USD, :PLN)

      assert {:ok, :transfer_successful} === Wallets.transfer(transfer)

      assert {:ok, %Wallet{currency: :USD, integer_amount: 0}} =
        Wallets.find_user_wallet(%{user_id: ctx.user1.id, currency: :USD})

      assert {:ok, %Wallet{currency: :PLN, integer_amount: 25_000}} =
        Wallets.find_user_wallet(%{user_id: ctx.user2.id, currency: :PLN})
    end

    test "should not transfer if account balance is not sufficient", ctx do
      transfer = %Transfer{
        from_user_id: ctx.user1.id,
        from_currency: :USD,
        integer_amount: 20000,
        to_user_id: ctx.user2.id,
        to_currency: :PLN
      }

      assert :ok = FxRateCache.put_fx_rate(@fx_rate)

      assert {:ok, "1.50"} === FxRateCache.get_fx_rate(:USD, :PLN)

      assert {:error, %ErrorMessage{code: :internal_server_error, message: "insufficient balance"}} ===
        Wallets.transfer(transfer)
    end

    test "should return 'wallet from not found' if from wallet does not exist", ctx do
      transfer = %Transfer{
        from_user_id: ctx.user_no_wallet.id,
        from_currency: :USD,
        integer_amount: 10000,
        to_user_id: ctx.user2.id,
        to_currency: :PLN
      }

      assert {:error, %ErrorMessage{code: :not_found, message: "wallet from not found"}} ===
        Wallets.transfer(transfer)
    end

    test "should return 'wallet to not found'if to wallet does not exist", ctx do
      transfer = %Transfer{
        from_user_id: ctx.user1.id,
        from_currency: :USD,
        integer_amount: 10000,
        to_user_id: ctx.user_no_wallet.id,
        to_currency: :PLN
      }

      assert {:error, %ErrorMessage{code: :not_found, message: "wallet to not found"}} ===
        Wallets.transfer(transfer)
    end

    test "should return {:error, :fx_rate_not_available} if fx rate is not available", ctx do
      transfer = %Transfer{
        from_user_id: ctx.user1.id,
        from_currency: :USD,
        integer_amount: 10000,
        to_user_id: ctx.user2.id,
        to_currency: :PLN
      }

      assert :ok = FxRateCache.put_fx_rate(@bad_fx_rate)

      assert {:error, %ErrorMessage{code: :internal_server_error, message: "fx rate not available"}} ===
        Wallets.transfer(transfer)
    end
  end
end
