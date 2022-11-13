defmodule PirateXchangeWeb.Resolvers.Wallet do
  alias PirateXchange.Wallets

  @spec find(map, Absinthe.Resolution.t) :: {:ok, [Wallet.t]}
                                            | {:error, ErrorMessage.t}
  def find(params, _resolution), do: Wallets.find(params)

  @spec all(map, Absinthe.Resolution.t) :: {:ok, Wallet.t}
                                            | {:error, ErrorMessage.t}
  def all(params, _resolution), do: {:ok, Wallets.all(params)}

  def create(params, _resolution), do: Wallets.create_wallet(params)
end
