defmodule PirateXchangeWeb.Resolvers.UserTotalWorth do
  alias PirateXchange.Accounts

  def get(params, _resolution) do
    {:ok, %{amount: amount}} = Accounts.user_total_worth(params)
    {:ok, %{
      amount: amount,
      currency: params.currency,
      user_id: params.user_id}
    }
  end
end
