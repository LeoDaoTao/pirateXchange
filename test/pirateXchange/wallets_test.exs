defmodule PirateXchange.WalletsTest do
  use PirateXchange.DataCase

  import PirateXchange.WalletsFixtures

  alias PirateXchange.Wallets
  alias PirateXchange.Wallets.Wallet

  @valid_user_params %{name: "Jack Sparrow", email: "sparrow@theblackperl.com"}
  @invalid_user_params %{name: nil, email: nil}

  describe "create_wallet/2" do
    setup :user

    test "should create a valid wallet for user and currency, with 0 balance", %{user: user} do
      user_id = user.id
      assert {:ok, %Wallet{user_id: ^user_id, currency: :USD}} = Wallets.create_wallet(user, :USD)

      assert [%Wallet{user_id: ^user_id, integer_amount: 0}] = Repo.all(Wallet)
    end

    test "should create a valid wallet for user and currency, with $100 balance", %{user: user} do
      user_id = user.id
      assert {:ok, %Wallet{user_id: ^user_id, currency: :USD, integer_amount: 10_000}} =
             Wallets.create_wallet(user, :USD, 10_000)

      assert [%Wallet{user_id: ^user_id, integer_amount: 10_000}] = Repo.all(Wallet)
    end

    test "should not create a wallet with invalid currency & return {:error, 'Currency not allowed'}", %{user: user} do
      assert {:error, "Currency not allowed"} = Wallets.create_wallet(user, :ARR)
    end

    test "should not create a wallet with existing currency & return {:error, 'Wallet already exists'}", %{user: user} do
      user_id = user.id
      assert {:ok, %Wallet{user_id: ^user_id, currency: :USD}} = Wallets.create_wallet(user, :USD)

      assert {:error, "Wallet already exists"} = Wallets.create_wallet(user, :USD)
    end
  end
end
