defmodule PirateXchangeWeb.Publications.Publish do
  alias PirateXchange.Accounts
  alias PirateXchange.Currencies.Currency

  @spec user_total_worth(%{user_id: integer, currency: Currency.t}) :: {:ok, map}
                                                                       | {:error, ErrorMessage.t}
  def user_total_worth(%{user_id: user_id, currency: currency}) do
    with {:ok, total_worth} <-
      Accounts.user_total_worth(%{user_id: user_id, currency: currency})
    do
      Absinthe.Subscription.publish(PirateXchangeWeb.Endpoint, total_worth,
        total_worth_change: "user_id:#{user_id}|currency:#{currency}")

      {:ok, total_worth}
    else
      {:error, error} -> {:error, error}
    end
  end
end
