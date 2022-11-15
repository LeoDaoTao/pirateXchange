defmodule PirateXchangeWeb.Schema.Mutations.WalletTransferTest do
  use PirateXchange.DataCase, async: true

  alias PirateXchange.FxRates.FxRate
  alias PirateXchange.FxRates.FxRateCache
  alias PirateXchange.Wallets
  alias PirateXchange.Wallets.Wallet
  alias PirateXchangeWeb.Schema

  import PirateXchange.UserFixtures,
    only: [users: 1, wallets: 1, user_no_wallet: 1]

  @fx_rate %FxRate{from_currency: :USD, to_currency: :PLN, rate: "1.50"}

  @transfer_doc """
    mutation Transfer(
      $fromUserId: ID!,
      $fromCurrency: Currency!,
      $integerAmount: Int!,
      $toUserId: ID!,
      $toCurrency: Currency!
    ) {
      transfer(
        fromUserId: $fromUserId,
        fromCurrency: $fromCurrency,
        integerAmount: $integerAmount,
        toUserId: $toUserId,
        toCurrency: $toCurrency
      ) {
          fromUserId
          fromCurrency
          integerAmount
          toUserId
          toCurrency
        }
     }
  """

  describe "@transfer" do
    setup [:users, :user_no_wallet, :wallets]

    test "should transfer 100 USD from one user to 150 PLN to another user", ctx do
      assert :ok = FxRateCache.put_fx_rate(@fx_rate)
      assert {:ok, "1.50"} === FxRateCache.get_fx_rate(:USD, :PLN)

      assert {:ok, _data} = Absinthe.run(@transfer_doc, Schema,
        variables: %{
          "fromUserId" => Integer.to_string(ctx.user1.id),
          "fromCurrency" => "USD",
          "integerAmount" => 10_000,
          "toUserId" => Integer.to_string(ctx.user2.id),
          "toCurrency" => "PLN"
        })

      assert {:ok, %Wallet{currency: :USD, integer_amount: 0}} =
        Wallets.find_user_wallet(%{user_id: ctx.user1.id, currency: :USD})

      assert {:ok, %Wallet{currency: :PLN, integer_amount: 25_000}} =
        Wallets.find_user_wallet(%{user_id: ctx.user2.id, currency: :PLN})
    end

    test "should not tranfer if account balance is not sufficient", ctx do
      assert {:ok, %{errors: [error]}} = Absinthe.run(@transfer_doc, Schema,
        variables: %{
          "fromUserId" => Integer.to_string(ctx.user1.id),
          "fromCurrency" => "USD",
          "integerAmount" => 20_000,
          "toUserId" => Integer.to_string(ctx.user2.id),
          "toCurrency" => "PLN"
        })

      assert error.code === :internal_server_error
      assert error.message === "insufficient balance"
    end

    test "should return 'wallet from not found' if from wallet does not exist", ctx do
      assert {:ok, %{errors: [error]}} = Absinthe.run(@transfer_doc, Schema,
        variables: %{
          "fromUserId" => Integer.to_string(ctx.user_no_wallet.id),
          "fromCurrency" => "USD",
          "integerAmount" => 10_000,
          "toUserId" => Integer.to_string(ctx.user2.id),
          "toCurrency" => "PLN"
        })

      assert error.code === :not_found
      assert error.message === "wallet from not found"
    end

    test "should return 'wallet to not found' if to wallet does not exist", ctx do
      assert {:ok, %{errors: [error]}} = Absinthe.run(@transfer_doc, Schema,
        variables: %{
          "fromUserId" => Integer.to_string(ctx.user1.id),
          "fromCurrency" => "USD",
          "integerAmount" => 10_000,
          "toUserId" => Integer.to_string(ctx.user_no_wallet.id),
          "toCurrency" => "PLN"
        })

      assert error.code === :not_found
      assert error.message === "wallet to not found"
    end
  end
end
