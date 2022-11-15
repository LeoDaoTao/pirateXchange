defmodule PirateXchangeWeb.Publications.Publish do
  alias PirateXchange.Accounts
  alias PirateXchange.Currencies.Currency
  alias PirateXchange.FxRates.FxRate

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

  @spec fx_rate_change(FxRate.t) :: :ok
  def fx_rate_change(%FxRate{} = fx_rate) do
    unless fx_rate.from_currency === fx_rate.to_currency do
      Absinthe.Subscription.publish(PirateXchangeWeb.Endpoint, fx_rate,
        fx_rate_change: "fx_rate_change:#{fx_rate.from_currency}")

      Absinthe.Subscription.publish(PirateXchangeWeb.Endpoint, fx_rate,
        fx_rate_change: "fx_rate_change:all")
    end
  end
end
