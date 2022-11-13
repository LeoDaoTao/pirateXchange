defmodule PirateXchangeWeb.Resolvers.UserTotalWorth do
  alias PirateXchange.Accounts

  def get(params, _resolution) do
    Accounts.user_total_worth(params)
  end
end
