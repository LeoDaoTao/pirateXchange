defmodule PirateXchange.Wallets do
  alias EctoShorts.Actions
  alias PirateXchange.Accounts.User
  alias PirateXchange.Currencies.Currency
  alias PirateXchange.Currencies.Money
  alias PirateXchange.FxRates
  alias PirateXchange.Transactions.Transfer
  alias PirateXchange.Wallets
  alias PirateXchange.Wallets.Wallet

  @spec create_wallet(
    %{
      user_id: pos_integer,
      currency: Currency.t,
      integer_amount: integer
    }) :: {:ok, Wallet.t} | {:error, String.t}
  def create_wallet(%{user_id: user_id, currency: currency, integer_amount: integer_amount}) do
    with {:ok, res} <- Actions.create(Wallet, %{user_id: user_id, currency: currency, integer_amount: integer_amount})
    do
      {:ok, res}
    else
      {:error, %{errors: [currency: {"is invalid", _}]}}
        -> {:error, ErrorMessage.not_found("currency not supported")}

      {:error, %{errors: [unique_user_wallet: {"has already been taken", _}]}}
        -> {:error, ErrorMessage.internal_server_error("wallet exists")}
    end
  end

  @spec all(map) :: [Wallet.t]
  def all(params \\ %{}), do: Actions.all(Wallet, params)

  @spec find(map) :: {:ok, Wallet.t}
  def find(params \\ %{}), do: Actions.find(Wallet, params)

  @spec find_user_wallet(%{user_id: pos_integer, currency: Currency.t}) :: {:ok, Wallet.t}
                                                                           | {:error, ErrorMessage.t}
  def find_user_wallet(%{user_id: _user_id, currency: _currency} = params) do
    case Actions.find(Wallet, params) do
      {:ok, res} -> {:ok, res}
      {:error, _res} -> {:error, ErrorMessage.not_found("wallet not found")}
    end
  end

  @spec find_user_wallets(%{user_id: pos_integer}) :: {:ok, [Wallet.t]}
                                                      | {:error, ErrorMessage.t}
  def find_user_wallets(%{user_id: user_id}) do
    case Actions.find(User, id: user_id, preload: :wallets) do
      {:ok, %User{wallets: []}}                 -> {:error, ErrorMessage.not_found("wallets not found")}
      {:ok, %User{wallets: wallets}}            -> {:ok, wallets}
      {:error, %ErrorMessage{code: :not_found}} -> {:error, ErrorMessage.not_found("user not found")}
    end
  end

  @spec wallet_total(%{user_id: pos_integer, currency: Currency.t}) :: {:ok, map} | {:error, ErrorMessage.t}
  def wallet_total(%{user_id: user_id, currency: currency}) do
    with {:ok, wallets} <- find_user_wallets(%{user_id: user_id}),
         {:ok, total} <- total_in_currency(wallets, currency)

    do
      {:ok, %{user_id: user_id, currency: currency, integer_amount: total}}

    else
      {:error, %ErrorMessage{code: :not_found, message: "wallets not found"}}
        -> {:ok, %Money{code: currency, amount: "0.00"}}

      {:error, %ErrorMessage{code: :not_found, message: "user not found"}}
        -> {:error, ErrorMessage.not_found("user not found")}

      {:error, %ErrorMessage{code: :internal_server_error, message: "wallet total error, fx rate not available"}}
        -> {:error, ErrorMessage.internal_server_error("total worth error, fx rate not available")}
    end
  end

  def total_in_currency(wallets, to_currency) do
    Enum.reduce_while(wallets, {:ok, 0}, fn wallet, {:ok, acc} ->
      integer_amount = wallet.integer_amount
      from_currency = wallet.currency

      case FxRates.get(from_currency, to_currency) do
        {:ok, rate}
          -> {:cont, {:ok, acc + calculate_integer_amount(rate, integer_amount)}}

        {:error, %ErrorMessage{code: :internal_server_error, message: "fx rate not available"}}
          -> {:halt, {:error, ErrorMessage.internal_server_error("wallet total error, fx rate not available")}}
      end
    end)
  end

  @spec transfer(Transfer.t) :: {:ok, :transfer_successful} | {:error, ErrorMessage.t}
  defdelegate transfer(transfer), to: Transfer, as: :send

  defp calculate_integer_amount(rate, integer_amount) do
    rate
    |> Money.string_to_integer_pips()
    |> Kernel.*(integer_amount)
  end
end
