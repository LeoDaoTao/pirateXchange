defmodule PirateXchangeWeb.Resolvers.Wallet do
  alias PirateXchange.Wallets
  alias PirateXchange.Wallets.Transfer

  @spec find(map, Absinthe.Resolution.t) :: {:ok, [Wallet.t]} | {:error, String.t}
  def find(params, _resolution) do
    case Wallets.find(params) do
      {:ok, wallet} -> {:ok, wallet}

      {:error, %ErrorMessage{code: :not_found}} ->
        {:error, "User #{params.user_id} does not have a wallet for currency #{params.currency}"}
    end
  end

  @spec all(map, Absinthe.Resolution.t) :: {:ok, [Wallet.t]} | {:error, String.t}
  def all(params, _resolution) do
    case Wallets.all(params) do
      []      -> {:error, "No wallets found for currency #{params.currency}"}
      wallets -> {:ok, wallets}
    end
  end

  @spec create(map, Absinthe.Resolution.t) :: {:ok, Wallet.t} | {:error, String.t}
  def create(params, resolution) do
    case Wallets.create_wallet(params) do
      {:ok, res} ->
        {:ok, res}

      {:error, %ErrorMessage{code: :internal_server_error, message: "wallet exists"}} ->
        {:error, "Wallet #{params.currency} for user #{params.user_id} exists"}

      {:error, %ErrorMessage{code: :not_found, message: "currency not supported"}} ->
        {:error, "Currency #{params.currency} is not supported"}
    end
  end

  @spec transfer(map, Absinthe.Resolution.t) :: {:ok, Wallet.t} | {:error, String.t}
  def transfer(params, _resolution) do
    transfer_data = %Transfer{
      from_user_id: String.to_integer(params.from_user_id),
      from_currency: params.from_currency,
      integer_amount: params.integer_amount,
      to_user_id: String.to_integer(params.to_user_id),
      to_currency: params.to_currency
    }

    case Wallets.transfer(transfer_data) do
      {:ok, :transfer_successful} ->
        {:ok,
          %{
            from_user_id: params.from_user_id,
            from_currency: params.from_currency,
            integer_amount: params.integer_amount,
            to_user_id: params.to_user_id,
            to_currency: params.to_currency
          }
        }

      {:error, %ErrorMessage{code: :not_found, message: "wallet from not found"} } ->
        {:error, "User #{params.to_user_id} does not have a wallet for currency #{params.from_currency}"}

      {:error, %ErrorMessage{code: :not_found, message: "wallet to not found"}} ->
        {:error, "User #{params.to_user_id} does not have a wallet for currency #{params.to_currency}"}
    end
  end
end
