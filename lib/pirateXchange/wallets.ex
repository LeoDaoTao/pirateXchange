defmodule PirateXchange.Wallets do
  alias EctoShorts.Actions
  alias PirateXchange.Accounts.User
  alias PirateXchange.Currencies.Currency
  alias PirateXchange.Currencies.Money
  alias PirateXchange.FxRates
  alias PirateXchange.Wallets.Wallet

  @spec create_wallet(%{user_id: pos_integer, curreny: Currency.t, integer_amount: integer}) :: {:ok, Wallet.t} | {:error, String.t}
  def create_wallet(%{user_id: user_id, currency: currency, integer_amount: integer_amount}) do
    res = Actions.create(Wallet, %{user_id: user_id, currency: currency, integer_amount: integer_amount})

    case(res) do
      {:ok, res} -> {:ok, res}
      {:error, res} -> format_errors(res)
    end
  end

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

  @spec user_total_worth(%{user_id: pos_integer, to_currency: Currency.t}) :: {:ok, Money.t}
                                                                              | {:error, :user_not_found}
                                                                              | {:error, :fx_rate_not_available}
  def user_total_worth(%{user_id: user_id, to_currency: to_currency}) do
    with {:wallets_exist?,  {:ok, wallets}}
            <- {:wallets_exist?, find_user_wallets(%{user_id: user_id})},

         {:rate_available?, {:ok, total}}
            <- {:rate_available?, integer_total_in_currency(wallets, to_currency)} do

      {:ok, %Money{code: to_currency, amount: Money.to_pips(total)}}

    else
      {:wallets_exist?,  {:error, :wallets_not_found}}
        -> {:ok,    %Money{code: to_currency, amount: "0.00"}}

      {:wallets_exist?,  {:error, :user_not_found}}
        -> {:error, :user_not_found}

      {:rate_available?, {:error, :fx_rate_not_available}}
        -> {:error, :fx_rate_not_available}
    end
  end

  defp integer_total_in_currency(wallets, to_currency) do
    Enum.reduce_while(wallets, {:ok, 0}, fn wallet, {:ok, acc} ->
      integer_amount = wallet.integer_amount
      from_currency = wallet.currency

      case FxRates.get(from_currency, to_currency) do
        {:ok, rate} -> {:cont, {:ok, acc + calculate_integer_amount(rate, integer_amount)}}
        {:error, :fx_rate_not_available} -> {:halt, {:error, :fx_rate_not_available}}
      end
    end)
  end

  defp calculate_integer_amount(rate, integer_amount) do
    rate
    |> Money.string_to_integer_pips()
    |> Kernel.*(integer_amount)
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
