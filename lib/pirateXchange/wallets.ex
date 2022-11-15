defmodule PirateXchange.Wallets do
  alias EctoShorts.Actions
  alias PirateXchange.Accounts.User
  alias PirateXchange.Currencies.Currency
  alias PirateXchange.Wallets.Wallet
  alias PirateXchange.Wallets.Transfer

  @spec create_wallet(%{user_id: pos_integer, curreny: Currency.t, integer_amount: integer}) :: {:ok, Wallet.t} | {:error, String.t}
  def create_wallet(%{user_id: user_id, currency: currency, integer_amount: integer_amount}) do
    res = Actions.create(Wallet, %{user_id: user_id, currency: currency, integer_amount: integer_amount})

    case(res) do
      {:ok, res} -> {:ok, res}
      {:error, error} -> format_errors(error)
    end
  end

  @spec all(map) :: [Wallet.t]
  def all(params \\ %{}), do: Actions.all(Wallet, params)

  @spec find(map) :: {:ok, Wallet.t}
  def find(params \\ %{}), do: Actions.find(Wallet, params)

  @spec find_user_wallet(%{user_id: pos_integer, currency: Currency.t}) :: {:ok, Wallet.t} | ErrorMessage.t
  def find_user_wallet(%{user_id: _user_id, currency: _currency} = params) do
    case Actions.find(Wallet, params) do
      {:ok, res} -> {:ok, res}
      {:error, _res} -> ErrorMessage.not_found("wallet not found")
    end
  end

  @spec find_user_wallets(%{user_id: pos_integer}) :: {:ok, [Wallet.t]} | ErrorMessage.t
  def find_user_wallets(%{user_id: user_id}) do
    case Actions.find(User, id: user_id, preload: :wallets) do
      {:ok, %User{wallets: []}}                 -> ErrorMessage.not_found("wallets not found")
      {:ok, %User{wallets: wallets}}            -> {:ok, wallets}
      {:error, %ErrorMessage{code: :not_found}} -> ErrorMessage.not_found("user not found")
    end
  end

  @spec transfer(Transfer.t) :: {:ok, :transfer_successful} | {:error, ErrorMessage.t}
  defdelegate transfer(transfer), to: Transfer, as: :send

  defp format_errors(changeset) do
    case errors(changeset) do
      %{currency: ["is invalid"]} -> {:error, ErrorMessage.not_found("currency not supported")}
      %{unique_user_wallet: ["has already been taken"]} -> {:error, ErrorMessage.internal_server_error("wallet exists")}
    end
  end

  defp errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn
      {msg, _opts} -> msg
    end)
  end
end
