defmodule PirateXchange.Wallets do
  alias EctoShorts.Actions
  alias PirateXchange.Accounts.User
  alias PirateXchange.Currencies.Currency
  alias PirateXchange.Wallets.Wallet

  @spec create_wallet(%{user_id: pos_integer, curreny: Currency.t, integer_amount: integer}) :: {:ok, Wallet.t} | {:error, String.t}
  def create_wallet(%{user_id: user_id, currency: currency, integer_amount: integer_amount}) do
    res = Actions.create(Wallet, %{user_id: user_id, currency: currency, integer_amount: integer_amount})

    case(res) do
      {:ok, res} -> {:ok, res}
      {:error, res} -> format_errors(res)
    end
  end

  #TODO add test
  @spec all(map) :: [Wallet.t]
  def all(params \\ %{}), do: Actions.all(Wallet, params)

  #TODO add test
  @spec find(map) :: {:ok, Wallet.t}
  def find(params \\ %{}), do: Actions.find(Wallet, params)

  @spec find_user_wallet(%{user_id: pos_integer, currency: Currency.t}) :: {:ok, Wallet.t}
                                                                           | {:error, :wallet_not_found}
  def find_user_wallet(params = %{user_id: _user_id, currency: _currency}) do
    case Actions.find(Wallet, params) do
      {:ok, res} -> {:ok, res}
      {:error, _res} -> {:error, :wallet_not_found}
    end
  end

  @spec find_user_wallets(%{user_id: pos_integer}) :: {:ok, [Wallet.t]}
                                                      | {:error, :wallets_not_found}
                                                      | {:error, :user_not_found}
  def find_user_wallets(%{user_id: user_id}) do
    case Actions.find(User, id: user_id, preload: :wallets) do
      {:ok, %User{wallets: []}}                 -> {:error, :wallets_not_found}
      {:ok, %User{wallets: wallets}}            -> {:ok, wallets}
      {:error, %ErrorMessage{code: :not_found}} -> {:error, :user_not_found}
    end
  end

  defp format_errors(changeset) do
    case errors(changeset) do
      %{currency: ["is invalid"]} -> {:error, :currency_not_allowed}
      %{unique_user_wallet: ["has already been taken"]} -> {:error, :wallet_exists}
    end
  end

  defp errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn
      {msg, _opts} -> msg
    end)
  end
end
