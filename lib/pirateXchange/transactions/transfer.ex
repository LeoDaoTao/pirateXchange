defmodule PirateXchange.Transactions.Transfer do
  alias ErrorMessage
  alias PirateXchange.Currencies.Currency
  alias PirateXchange.FxRates
  alias PirateXchange.Repo
  alias PirateXchange.Wallets.Wallet

  @enforce_keys [
    :from_user_id,
    :from_currency,
    :integer_amount,
    :to_user_id,
    :to_currency
  ]

  defstruct [
    :from_user_id,
    :from_currency,
    :integer_amount,
    :to_user_id,
    :to_currency
  ]

  @type t :: %__MODULE__{
    from_user_id: non_neg_integer,
    from_currency: Currency.t,
    integer_amount: non_neg_integer,
    to_user_id: non_neg_integer,
    to_currency: Currency.t
  }

  @spec send(t) :: {:ok, :transfer_successful} | {:error, ErrorMessage.t}
  def send(%__MODULE__{} = transfer) do
    res = Ecto.Multi.new()
    |> Ecto.Multi.put(:transfer, transfer)
    |> Ecto.Multi.one(:from_wallet, &retrieve_from_wallet/1)
    |> Ecto.Multi.one(:to_wallet, &retrieve_to_wallet/1)
    |> Ecto.Multi.run(:verify_from_wallet, &verify_from_wallet/2)
    |> Ecto.Multi.run(:verify_to_wallet, &verify_to_wallet/2)
    |> Ecto.Multi.run(:verify_balance, &verify_balance/2)
    |> Ecto.Multi.run(:fx_rate, &get_fx_rate/2)
    |> Ecto.Multi.run(:fx_amount, &fx_amount/2)
    |> Ecto.Multi.update(:debit_wallet, &debit_wallet/1)
    |> Ecto.Multi.update(:credit_wallet, &credit_wallet/1)
    |> Repo.transaction()

    case res do
      {:ok, %{transfer: transfer}}
        -> {:ok, transfer}

      {:error, _function, error, _} ->
        {:error, error}
    end
  end

  defp retrieve_from_wallet(%{transfer: transfer}) do
      Wallet
      |> Wallet.by_user_id_and_currency(transfer.from_user_id, transfer.from_currency)
      |> Wallet.lock_wallet()
  end

  defp retrieve_to_wallet(%{transfer: transfer}) do
      Wallet
      |> Wallet.by_user_id_and_currency(transfer.to_user_id, transfer.to_currency)
      |> Wallet.lock_wallet()
  end

  defp verify_from_wallet(_multi, %{from_wallet: %Wallet{}}) do
    {:ok, true}
  end

  defp verify_from_wallet(_multi, %{from_wallet: _}) do
    {:error, ErrorMessage.not_found("wallet from not found")}
  end

  defp verify_to_wallet(_multi, %{to_wallet: %Wallet{}}) do
    {:ok, true}
  end

  defp verify_to_wallet(_multi, %{to_wallet: _, transfer: transfer}) do
    {:error, ErrorMessage.not_found("wallet to not found", %{
                          to_user_id: transfer.to_user_id,
                          to_currency: transfer.to_currency
                       })
    }
  end

  defp verify_balance(_multi, %{from_wallet: balance, transfer: transfer}) do
    case balance.integer_amount >= transfer.integer_amount do
      true -> {:ok, true}
         _ -> {:error, ErrorMessage.internal_server_error("insufficient balance")}
    end
  end

  defp get_fx_rate(_multi, %{transfer: transfer}) do
    case FxRates.get(transfer.from_currency, transfer.to_currency) do
      {:ok, rate} -> {:ok, String.to_float(rate)}
      _error      -> {:error, ErrorMessage.internal_server_error("fx rate not available")}
    end
  end

  defp fx_amount(_multi, %{transfer: transfer, fx_rate: fx_rate}) do
    {:ok, round(transfer.integer_amount * fx_rate)}
  end

  defp debit_wallet(%{from_wallet: from_wallet, transfer: transfer}) do
    Ecto.Changeset.change(from_wallet, integer_amount: from_wallet.integer_amount - transfer.integer_amount)
  end

  defp credit_wallet(%{to_wallet: to_wallet, fx_amount: fx_amount}) do
    Ecto.Changeset.change(to_wallet, integer_amount: to_wallet.integer_amount + fx_amount)
  end
end
