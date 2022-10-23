defmodule PirateXchange.Wallets.Wallet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "wallets" do
    belongs_to :user, PirateXchange.Accounts.User
    #TODO: Figure out how deleting a currency in config affects db enums
    field :currency, Ecto.Enum, values: PirateXchange.Currencies.available()
    field :amount_in_cents, :integer
    field :default, :boolean
  end

  @doc false
  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, [:amount_in_cents])
    |> validate_required([:amount_in_cents])
  end
end
