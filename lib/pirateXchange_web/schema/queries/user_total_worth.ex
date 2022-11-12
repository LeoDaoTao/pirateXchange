defmodule PirateXchangeWeb.Schema.Queries.UserTotalWorth do
  use Absinthe.Schema.Notation
  alias PirateXchangeWeb.Resolvers

  @desc "Returns total worth of a user in a specifc currency"
  object :user_total_worth_queries do
    field :user_total_worth, :user_total_worth do
      arg :user_id, non_null(:id)
      arg :currency, non_null(:currency)

      resolve &Resolvers.UserTotalWorth.get/2
    end
  end
end
