defmodule PirateXchange.AccountsTest do
  use PirateXchange.DataCase

  alias PirateXchange.Accounts
  alias PirateXchange.Accounts.User
  alias PirateXchange.Accounts.Transfer
  alias PirateXchange.FxRates
  alias PirateXchange.FxRates.FxRate
  alias PirateXchange.FxRates.FxRateCache
  alias PirateXchange.Wallets
  alias PirateXchange.Wallets.Wallet

  import PirateXchange.UserFixtures

  @user_params %{name: "Jack Sparrow", email: "sparrow@theblackperl.com"}
  @user2_params %{name: "Blackbeard", email: "unshaven@queensrevenge.com"}
  @invalid_user_params %{name: "", email: ""}

  @fx_rate %FxRate{from_currency: :USD, to_currency: :PLN, rate: "1.50"}
  @bad_fx_rate %FxRate{from_currency: :USD, to_currency: :PLN, rate: nil}

  describe "create_user/1" do
    test "should create a user with valid params" do
      assert {:ok, %User{name: "Jack Sparrow", email: "sparrow@theblackperl.com"}} =
        Accounts.create_user(@user_params)

      [%User{}] = Repo.all(User)
    end

    test "should not create user with duplicate email" do
      assert {:ok, %User{name: "Jack Sparrow", email: "sparrow@theblackperl.com"}} =
        Accounts.create_user(@user_params)

      assert {:error, %Ecto.Changeset{} = changeset} =
        Accounts.create_user(@user_params)

      assert %{email: ["has already been taken"]} = errors_on(changeset)
    end

    test "should not create user with invalid params" do
      assert {:error, %Ecto.Changeset{} = changeset} =
        Accounts.create_user(@invalid_user_params)

      assert %{email: ["can't be blank"], name: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "all_users/0" do
    setup :users

    test "should return all users", %{users: users} do
      assert ^users = Accounts.all_users()
    end
  end

  describe "find_user/1" do
    setup :user

    test "should find a user by id", %{user: user} do
      id = user.id
      assert {:ok, %User{id: ^id}} = Accounts.find_user(%{id: id})
    end

    test "should find a user by email", %{user: %{email: email}} do
      assert {:ok, %User{email: ^email}} = Accounts.find_user(%{email: email})
    end
  end

  describe "transfer/1" do
    setup [:user, :user2, :user_no_wallet, :wallets, :wallets2]

    test "should transfer 100.00 USD from one user to 150.00 PLN to another user", %{user: user, user2: user2} do
      transfer = %Transfer{
        from_user_id: user.id,
        from_currency: :USD,
        integer_amount: 10000,
        to_user_id: user2.id,
        to_currency: :PLN
      }

      assert :ok = FxRateCache.put_fx_rate(@fx_rate)

      assert {:ok, "1.50"} === FxRateCache.get_fx_rate(:USD, :PLN)

      assert {:ok, :transfer_successful} === Accounts.transfer(transfer)

      assert {:ok, %Wallet{currency: :USD, integer_amount: 0}} =
        Wallets.find_user_wallet(%{user_id: user.id, currency: :USD})

      assert {:ok, %Wallet{currency: :PLN, integer_amount: 25_000}} =
        Wallets.find_user_wallet(%{user_id: user2.id, currency: :PLN})
    end

    test "should not transfer if account balance is not sufficient", %{user: user, user2: user2} do
      transfer = %Transfer{
        from_user_id: user.id,
        from_currency: :USD,
        integer_amount: 20000,
        to_user_id: user2.id,
        to_currency: :PLN
      }

      assert :ok = FxRateCache.put_fx_rate(@fx_rate)

      assert {:ok, "1.50"} === FxRateCache.get_fx_rate(:USD, :PLN)

      assert {:error, :insufficient_balance} === Accounts.transfer(transfer)
    end

    test "should return {:error, :wallet_from_not_found} if from wallet does not exist", %{user_no_wallet: user, user2: user2} do
      transfer = %Transfer{
        from_user_id: user.id,
        from_currency: :USD,
        integer_amount: 10000,
        to_user_id: user2.id,
        to_currency: :PLN
      }

      assert{:error, :wallet_from_not_found} === Accounts.transfer(transfer)
    end

    test "should return {:error, :wallet_to_not_found} if to wallet does not exist", %{user: user, user_no_wallet: user2} do
      transfer = %Transfer{
        from_user_id: user.id,
        from_currency: :USD,
        integer_amount: 10000,
        to_user_id: user2.id,
        to_currency: :PLN
      }

      assert{:error, :wallet_to_not_found} === Accounts.transfer(transfer)
    end

    test "should return {:error, :fx_rate_not_available} if fx rate is not available", %{user: user, user2: user2} do
      transfer = %Transfer{
        from_user_id: user.id,
        from_currency: :USD,
        integer_amount: 10000,
        to_user_id: user2.id,
        to_currency: :PLN
      }

      assert :ok = FxRateCache.put_fx_rate(@bad_fx_rate)

      assert{:error, :fx_rate_not_available} === Accounts.transfer(transfer)
    end
  end
end
