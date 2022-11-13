defmodule PirateXchangeWeb.Types.Transfer do
  use Absinthe.Schema.Notation

  @desc "Transfer between two wallets"
  object :transfer do
    field :from_user_id, non_null(:id)
    field :from_currency, non_null(:currency)
    field :integer_amount, non_null(:integer)
    field :to_user_id, non_null(:id)
    field :to_currency, non_null(:currency)
  end
end
