defmodule PirateXchangeWeb.Resolvers.Wallet do
  alias PirateXchange.Wallets
  alias PirateXchange.Wallets.Transfer

  @spec find(map, Absinthe.Resolution.t) :: {:ok, Wallet.t} | {:error, String.t}
  def find(params, _resolution), do: Wallets.find(params)

  @spec all(map, Absinthe.Resolution.t) :: {:ok, [Wallet.t]} | {:error, String.t}
  def all(params, _resolution) do
    case Wallets.all(params) do
      []      -> {:error, "No wallets found for currency #{params.currency}"}
      wallets -> {:ok, wallets}
    end
  end

  @spec create(map, Absinthe.Resolution.t) :: {:ok, Wallet.t} | {:error, String.t}
  def create(params, _resolution), do: Wallets.create_wallet(params)

  @spec transfer(map, Absinthe.Resolution.t) :: {:ok, Wallet.t} | {:error, String.t}
  def transfer(params, _resolution) do
    transfer_data = %Transfer{
      from_user_id: String.to_integer(params.from_user_id),
      from_currency: params.from_currency,
      integer_amount: params.integer_amount,
      to_user_id: String.to_integer(params.to_user_id),
      to_currency: params.to_currency
    }

    Wallets.transfer(transfer_data)
  end
end
