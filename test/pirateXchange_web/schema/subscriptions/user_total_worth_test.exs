defmodule PirateXchangeWeb.Schema.Subscriptions.UserTotalWorthTest do
  use PirateXchangeWeb.SubscriptionCase

  alias PirateXchange.FxRates.FxRate
  alias PirateXchange.FxRates.FxRateCache
  alias PirateXchangeWeb.Schema

  import PirateXchange.UserFixtures,
    only: [users: 1, wallets: 1]

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
  @total_worth_change_doc """
    subscription TotalWorthChange($userId: ID!, $currency: Currency!) {
      totalWorthChange(userId: $userId, currency: $currency) {
        userId
        currency
        integerAmount
      }
   }
  """

  describe "@totalWorthChange" do
    setup [:users, :wallets]

    test "shuld broadcast user total worth change when transfer is successful", ctx do
      ref = push_doc(ctx.socket, @total_worth_change_doc, variables: %{
        "userId" => to_string(ctx.user1.id),
        "currency" => "USD"
      })

      assert_reply ref, :ok, %{subscriptionId: subscription_id}


      ref = push_doc(ctx.socket, @transfer_doc, variables: %{
        "fromUserId" => to_string(ctx.user1.id),
        "fromCurrency" => "USD",
        "integerAmount" => 10000,
        "toUserId" => to_string(ctx.user2.id),
        "toCurrency" => "PLN"
        })

      assert_reply ref, :ok, reply

      assert %{
               data: %{
                 "transfer" => %{
                   "fromUserId" => to_string(ctx.user1.id),
                   "fromCurrency" => "USD",
                   "integerAmount" => 10000,
                   "toUserId" => to_string(ctx.user2.id),
                   "toCurrency" => "PLN"
                 }
               }
             } === reply


      assert_push "subscription:data", reply

      user_id = to_string(ctx.user1.id)
      assert %{
        subscriptionId: ^subscription_id,
        result: %{
          data: %{
            "totalWorthChange" => %{
              "userId" => ^user_id,
              "currency" => "USD"
            }
          }
        }
      } = reply
    end
  end
end
