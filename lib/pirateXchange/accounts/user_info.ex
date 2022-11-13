defmodule PirateXchange.Accounts.UserInfo do
  alias PirateXchange.Currencies.Money
  alias PirateXchange.FxRates
  alias PirateXchange.Wallets

  @spec total_worth(%{user_id: pos_integer, currency: Currency.t}) :: {:ok, Money.t} | {:error, ErrorMessage.t}
  def total_worth(%{user_id: user_id, currency: currency}) do
    with {:wallets_exist?,  {:ok, wallets}}
            <- {:wallets_exist?, Wallets.find_user_wallets(%{user_id: user_id})},

         {:rate_available?, {:ok, total}}
            <- {:rate_available?, integer_total_in_currency(wallets, currency)} do

      {:ok, %Money{code: currency, amount: Money.to_pips(total)}}

    else
      {:wallets_exist?, %ErrorMessage{code: :not_found, message: "wallets not found"}}
        -> {:ok, %Money{code: currency, amount: "0.00"}}

      {:wallets_exist?,  %ErrorMessage{code: :not_found, message: "user not found"}}
        -> {:error, ErrorMessage.not_found("user not found")}

      {:rate_available?, %ErrorMessage{code: :internal_server_error, message: "fx rate not available"}}
        -> {:error, ErrorMessage.internal_server_error("fx rate not available")}
    end
  end

  defp integer_total_in_currency(wallets, to_currency) do
    Enum.reduce_while(wallets, {:ok, 0}, fn wallet, {:ok, acc} ->
      integer_amount = wallet.integer_amount
      from_currency = wallet.currency

      case FxRates.get(from_currency, to_currency) do
        {:ok, rate}
          -> {:cont, {:ok, acc + calculate_integer_amount(rate, integer_amount)}}

        {:error, %ErrorMessage{code: :internal_server_error, message: "fx rate not available"}}
          -> {:halt, ErrorMessage.internal_server_error("fx rate not available")}
      end
    end)
  end

  defp calculate_integer_amount(rate, integer_amount) do
    rate
    |> Money.string_to_integer_pips()
    |> Kernel.*(integer_amount)
  end
end
