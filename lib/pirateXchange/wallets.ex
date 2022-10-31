defmodule PirateXchange.Wallets do
  alias PirateXchange.Accounts.User
  alias PirateXchange.Currencies.Currency
  alias PirateXchange.Wallets.Wallet
  alias EctoShorts.Actions

  @spec create_wallet(User.t, Currency.t, integer) :: {:ok, Wallet.t} | {:error, String.t}
  def create_wallet(user = %User{}, currency, integer_amount \\ 0) do
    res = Actions.create(Wallet, %{user_id: user.id, currency: currency, integer_amount: integer_amount})

    case(res) do
      {:ok, res} -> {:ok, res}
      {:error, res} -> format_errors(res)
    end
  end

  defp format_errors(changeset) do
    case errors(changeset) do
      %{currency: ["is invalid"]} -> {:error, "Currency not allowed"}
      %{unique_user_wallet: ["has already been taken"]} -> {:error, "Wallet already exists"}
    end
  end

  defp errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn
      {msg, _opts} -> msg
    end)
  end
end
