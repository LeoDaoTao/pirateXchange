defmodule PirateXchangeWeb.Schema.Queries.UserTotalWorth do
  use PirateXchange.DataCase, async: true

  alias PirateXchange.FxRates.FxRate
  alias PirateXchange.FxRates.FxRateCache
  alias PirateXchangeWeb.Schema

  import PirateXchange.UserFixtures, only: [users: 1, wallets: 1]

  @fx_rate_pln %FxRate{from_currency: :PLN, to_currency: :USD, rate: "1.50"}
  @fx_rate_usd %FxRate{from_currency: :USD, to_currency: :USD, rate: "1"}

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
    setup [:users, :wallets]

    test "should return a total worth for user in provided currency", ctx do
      assert :ok = FxRateCache.put_fx_rate(@fx_rate_pln)
      assert :ok = FxRateCache.put_fx_rate(@fx_rate_usd)

      assert {:ok, %{data: data}} = Absinthe.run(@user_total_worth_doc, Schema,
        variables: %{
          "userId" => ctx.user1.id,
          "currency" => "USD"
        }
      )

      assert data["userTotalWorth"]["integerAmount"] === 2500000
    end
  end
end
