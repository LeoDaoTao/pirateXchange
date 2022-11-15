defmodule PirateXchangeWeb.Schema.Subscriptions.FxRateChangeTest do
  use PirateXchangeWeb.SubscriptionCase

  alias PirateXchange.FxRates.FxRate
  alias PirateXchange.FxRates.FxRateCache
  alias PirateXchangeWeb.Publications.Publish

  import PirateXchange.UserFixtures,
    only: [users: 1, wallets: 1]

  @fx_rate %FxRate{from_currency: :USD, to_currency: :PLN, rate: "1.50"}

  @fx_rate_change_subscription_doc """
    subscription FxRateChange($currency: Currency){
    fxRateChange(currency: $currency){
      fromCurrency
      toCurrency
      rate
    }
  }
  """

  describe "@fxRateChange" do
    test "should broadcast fx rate change for specific currency", ctx do
      ref = push_doc(ctx.socket, @fx_rate_change_subscription_doc, variables: %{
        "currency" => "USD"
      })

      assert_reply ref, :ok, %{subscriptionId: subscription_id}

      assert :ok = Publish.fx_rate_change(@fx_rate)

      assert_push "subscription:data", reply

      IO.inspect reply

      assert %{
        subscriptionId: ^subscription_id,
        result: %{
          data: %{
            "fxRateChange" => %{
              "fromCurrency" => "USD",
              "toCurrency" => "PLN",
              "rate" => "1.50"
            }
          }
        }
      } = reply
    end
  end
end
