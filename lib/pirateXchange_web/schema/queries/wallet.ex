defmodule PirateXchangeWeb.Schema.Queries.Wallet do
  use Absinthe.Schema.Notation

  alias PirateXchangeWeb.Resolvers

  object :wallet_queries do
    @desc "Wallets filtered by params"
    field :wallets, list_of(:wallet) do
      arg :currency, :currency
      arg :user_id, :id

      resolve &Resolvers.Wallet.all/2
    end

    @desc "Wallet by id or user_id and currency"
    field :wallet, :wallet do
      arg :id, :id
      arg :currency, :currency
      arg :user_id, :id

      resolve &Resolvers.Wallet.find/2
    end
  end
end
