defmodule PirateXchange.Schema.WalletTest do
  use PirateXchange.DataCase, async: true

  alias PirateXchange.Wallets
  alias PirateXchangeWeb.Schema

  import PirateXchange.UserFixtures,
    only: [users: 1, wallets: 1]

  @wallet_by_params_doc """
    query Wallet($currency: Currency, $userId: ID!) {
      wallet(userId: $userId, currency: $currency) {
        currency
        integerAmount
        userId
      }
    }
  """

  @wallet_by_wallet_id_doc """
    query Wallet($id: ID!) {
      wallet(id: $id) {
        id
        userId
        currency
        integerAmount
      }
    }
  """

  describe "@wallet" do
    setup [:users, :wallets]

    test "should return a valid wallet for user_id & currency", ctx do
      {:ok, wallet} = Wallets.find_user_wallet(%{user_id: ctx.user1.id, currency: :PLN})

      assert {:ok, %{data: data}} = Absinthe.run(@wallet_by_params_doc, Schema,
        variables: %{
          "userId" => ctx.user1.id,
          "currency" => "PLN"
        })

      assert data["wallet"]["userId"] === "#{ctx.user1.id}"
      assert data["wallet"]["integerAmount"] === wallet.integer_amount
    end

    test "should return a valid wallet for wallet id", ctx do
      {:ok, wallet} = Wallets.find_user_wallet(%{user_id: ctx.user1.id, currency: :PLN})

      assert {:ok, %{data: data}} = Absinthe.run(@wallet_by_wallet_id_doc, Schema,
        variables: %{"id" => wallet.id})

      assert data["wallet"]["id"] === "#{wallet.id}"
    end
  end

  @wallets_by_params_doc """
    query Wallets($currency: Currency, $userId: ID) {
      wallets(currency: $currency, userId: $userId) {
        id
        currency
        integerAmount
        userId
      }
    }
  """
  describe "@wallets" do
    setup [:users, :wallets]

    test "should return all wallets for a provided currency" do
      wallets = Wallets.all(%{currency: :PLN})

      assert {:ok, %{data: data}} = Absinthe.run(@wallets_by_params_doc, Schema,
        variables: %{"currency" => "PLN"})

      assert data["wallets"] === convert_wallet_struct(wallets)
    end

    test "should return all wallets for user id", ctx do
      wallets = Wallets.all(%{user_id: ctx.user1.id})

      assert {:ok, %{data: data}} = Absinthe.run(@wallets_by_params_doc, Schema,
        variables: %{"userId" => ctx.user1.id})

      assert data["wallets"] === convert_wallet_struct(wallets)
    end
  end

  defp convert_wallet_struct(wallets) do
    Enum.map(wallets, fn wallet ->
      %{
        "currency" => Atom.to_string(wallet.currency),
        "id" => "#{wallet.id}",
        "integerAmount" => wallet.integer_amount,
        "userId" => "#{wallet.user_id}"
      }
    end)
  end
end
