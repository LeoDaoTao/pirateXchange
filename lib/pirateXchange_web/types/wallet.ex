defmodule PirateXchangeWeb.Types.Wallet do
  use Absinthe.Schema.Notation

  @desc "User Wallet for a currency"
  object :wallet do
    field :id, non_null(:id)
    field :currency, non_null(:currency)
    field :integer_amount, non_null(:integer)
    field :user_id, non_null(:id)
  end
end
