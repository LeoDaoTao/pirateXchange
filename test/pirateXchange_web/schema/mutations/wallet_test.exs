defmodule PirateXchangeWeb.Schema.Mutations.WalletTest do
  use PirateXchange.DataCase, async: true

  alias PirateXchange.Wallets
  alias PirateXchangeWeb.Schema

  @create_wallet_doc """
    mutation CreateWallet(
      $userId: ID!,
      $currency: Currency!,
      $integerAmount: Int!
    ) {

      createWallet(
        userId: $userId,
        currency: $currency,
        integerAmount: $integerAmount
      ) {
          userId
          currency
          integerAmount
        }
    }
  """

  @create_user_doc """
    mutation CreateUser($name: String!, $email: String!) {
      createUser(name: $name, email: $email){
        id
        name
        email
      }
    }
  """

  describe "@createWallet" do
    test "should create wallet for userId, currency, and integerAmount" do
      assert {:ok, %{data: user_data}} = Absinthe.run(@create_user_doc, Schema,
        variables: %{
          "name" => "Test Pirate",
          "email" => "pirate@arr.com"
        })

      assert {:ok, %{data: wallet_data}} = Absinthe.run(@create_wallet_doc, Schema,
        variables: %{
          "userId" => user_data["createUser"]["id"],
          "currency" => "PLN",
          "integerAmount" => 1000
        })

      assert {:ok, wallet} =
        Wallets.find(%{user_id: String.to_integer(user_data["createUser"]["id"]), currency: :PLN})

      assert wallet.user_id === String.to_integer(wallet_data["createWallet"]["userId"])
      assert wallet.currency === String.to_atom(wallet_data["createWallet"]["currency"])
      assert wallet.integer_amount === wallet_data["createWallet"]["integerAmount"]
    end

    test "should not create a wallet for user if currency already exists" do
      assert {:ok, %{data: user_data}} = Absinthe.run(@create_user_doc, Schema,
        variables: %{
          "name" => "Test Pirate",
          "email" => "pirate@arr.com"
        })

      assert {:ok, _data} = Absinthe.run(@create_wallet_doc, Schema,
        variables: %{
          "userId" => user_data["createUser"]["id"],
          "currency" => "PLN",
          "integerAmount" => 1000
        })

      assert {:ok, %{errors: [error]}} = Absinthe.run(@create_wallet_doc, Schema,
        variables: %{
          "userId" => user_data["createUser"]["id"],
          "currency" => "PLN",
          "integerAmount" => 1000
        })

      assert error.code === :internal_server_error
      assert error.message === "wallet exists"
    end
  end

end
