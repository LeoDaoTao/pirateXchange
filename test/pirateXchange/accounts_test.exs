defmodule PirateXchange.AccountsTest do
  use PirateXchange.DataCase

  alias PirateXchange.Accounts
  alias PirateXchange.Accounts.User
  alias PirateXchange.Accounts.Transfer
  alias PirateXchange.FxRates.FxRate
  alias PirateXchange.FxRates.FxRateCache
  alias PirateXchange.Wallets
  alias PirateXchange.Wallets.Wallet

  import PirateXchange.UserFixtures,
    only: [users: 1, user_params: 1, wallets: 1, user_no_wallet: 1]

  @fx_rate %FxRate{from_currency: :USD, to_currency: :PLN, rate: "1.50"}
  @bad_fx_rate %FxRate{from_currency: :USD, to_currency: :PLN, rate: nil}

  describe "create_user/1" do
    setup :user_params

    test "should create a user with valid params",
      %{user_params: %{name: name, email: email}} do

      assert {:ok, %User{name: ^name, email: ^email}} =
        Accounts.create_user(%{name: name, email: email})

      assert [%User{name: ^name, email: ^email}] = Repo.all(User)
    end

    test "should not create user with duplicate email",
      %{user_params: %{name: name, email: email}} do

      assert {:ok, %User{name: ^name, email: ^email}} =
        Accounts.create_user(%{name: name, email: email})

      assert {:error, %Ecto.Changeset{} = changeset} =
        Accounts.create_user(%{name: name, email: email})

      assert %{email: ["has already been taken"]} = errors_on(changeset)
    end

    test "should not create user with invalid params" do
      assert {:error, %Ecto.Changeset{} = changeset} =
        Accounts.create_user(%{})

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
    setup :users

    test "should find a user by id", ctx do
      id = ctx.user1.id
      assert {:ok, %User{id: ^id}} = Accounts.find_user(%{id: id})
    end

    test "should find a user by email", ctx do
      email = ctx.user1.email
      assert {:ok, %User{email: ^email}} = Accounts.find_user(%{email: email})
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

      assert {:ok, :transfer_successful} === Accounts.transfer(transfer)

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

      assert {:error, %ErrorMessage{code: :internal_server_error, message: "insufficient balance"}}
        === Accounts.transfer(transfer)
    end

    test "should return {:error, :wallet_from_not_found} if from wallet does not exist", ctx do
      transfer = %Transfer{
        from_user_id: ctx.user_no_wallet.id,
        from_currency: :USD,
        integer_amount: 10000,
        to_user_id: ctx.user2.id,
        to_currency: :PLN
      }

      assert{:error, %ErrorMessage{code: :not_found, message: "wallet from not found"}}
        === Accounts.transfer(transfer)
    end

    test "should return {:error, :wallet_to_not_found} if to wallet does not exist", ctx do
      transfer = %Transfer{
        from_user_id: ctx.user1.id,
        from_currency: :USD,
        integer_amount: 10000,
        to_user_id: ctx.user_no_wallet.id,
        to_currency: :PLN
      }

      assert{:error, %ErrorMessage{code: :not_found, message: "wallet to not found"}}
        === Accounts.transfer(transfer)
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

      assert{:error, %ErrorMessage{code: :internal_server_error, message: "fx rate not available"}}
        === Accounts.transfer(transfer)
    end
  end
end
