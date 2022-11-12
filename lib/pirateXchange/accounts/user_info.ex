defmodule PirateXchange.Accounts.UserInfo do
  alias PirateXchange.Currencies.Money
  alias PirateXchange.FxRates
  alias PirateXchange.Wallets

  @spec total_worth(%{user_id: pos_integer, currency: Currency.t}) :: {:ok, Money.t}
                                                                      | {:error, :user_not_found}
                                                                      | {:error, :fx_rate_not_available}
  def total_worth(%{user_id: user_id, currency: currency}) do
    with {:wallets_exist?,  {:ok, wallets}}
            <- {:wallets_exist?, Wallets.find_user_wallets(%{user_id: user_id})},

         {:rate_available?, {:ok, total}}
            <- {:rate_available?, integer_total_in_currency(wallets, currency)} do

      {:ok, %Money{code: currency, amount: Money.to_pips(total)}}

    else
      {:wallets_exist?,  {:error, :wallets_not_found}}
        -> {:ok, %Money{code: currency, amount: "0.00"}}

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
end
