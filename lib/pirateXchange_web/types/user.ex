defmodule PirateXchangeWeb.Types.User do
  use Absinthe.Schema.Notation
  alias PirateXchange.Wallets

  import Absinthe.Resolution.Helpers, only: [dataloader: 2]

  @desc "User with wallets"
  object :user do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :email, non_null(:string)

    field :wallets, list_of(:wallet),
      resolve: dataloader(Wallets, :wallets)
  end
end
