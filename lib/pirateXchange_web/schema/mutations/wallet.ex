defmodule PirateXchangeWeb.Schema.Mutations.Wallet do
  use Absinthe.Schema.Notation
  alias PirateXchangeWeb.Resolvers

  object :wallet_mutations do
    @desc "creates a wallet for a user"
    field :create_wallet, :wallet do
      arg :user_id, non_null(:id)
      arg :currency, non_null(:currency)
      arg :integer_amount, non_null(:integer), default_value: 0

      resolve &Resolvers.Wallet.create/2
    end
  end

end
