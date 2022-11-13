defmodule PirateXchangeWeb.Types.UserTotalWorth do
  use Absinthe.Schema.Notation

  @desc "User Total Worth"
  object :user_total_worth do
    field :user_id, non_null(:id)
    field :currency, non_null(:currency)
    field :integer_amount, non_null(:integer)
  end
end
