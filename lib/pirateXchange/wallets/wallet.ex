defmodule PirateXchange.Wallets.Wallet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "wallets" do
    belongs_to :user, PirateXchange.Accounts.User
    belongs_to :currency, PirateXchange.Currencies.Currency
    field :balance, :integer
    field :default, :boolean
  end

  @doc false
  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, [:balance])
    |> validate_required([:balance])
  end
end
