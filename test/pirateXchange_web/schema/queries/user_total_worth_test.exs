defmodule PirateXchangeWeb.Schema.Queries.UserTotalWorth do
  use PirateXchange.DataCase, async: true

  alias PirateXchangeWeb.Schema

  import PirateXchange.UserFixtures, only: [users: 1, wallets: 1]
  import PirateXchange.FxRateFixtures, only: [fx_rates: 1]

  @user_total_worth_doc """
    query UserTotalWorth($userId: ID!, $currency: Currency!) {
      userTotalWorth(userId: $userId, currency: $currency) {
        userId
        currency
        integerAmount
      }
    }
  """
  describe "@userTotalWorth" do
    setup [:users, :wallets, :fx_rates]

    test "should return a total worth for user in provided currency", ctx do
      assert {:ok, %{data: data}} = Absinthe.run(@user_total_worth_doc, Schema,
        variables: %{
          "userId" => ctx.user1.id,
          "currency" => "USD"
        }
      )

      assert data["userTotalWorth"]["integerAmount"] === 2_500_000
    end
  end
end
