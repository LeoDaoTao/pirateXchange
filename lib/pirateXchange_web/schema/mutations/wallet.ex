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

    @desc "transfers money from one wallet to another"
    field :transfer, :transfer do
      arg :from_user_id, non_null(:id)
      arg :from_currency, non_null(:currency)
      arg :integer_amount, non_null(:integer)
      arg :to_user_id, non_null(:id)
      arg :to_currency, non_null(:currency)

      resolve &Resolvers.Wallet.transfer/2
    end
  end
end
