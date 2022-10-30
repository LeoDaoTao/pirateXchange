defmodule PirateXchange.Wallets.Wallet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "wallets" do
    belongs_to :user, PirateXchange.Accounts.User

    field :currency, Ecto.Enum, values: PirateXchange.Currencies.available()
    field :integer_amount, :integer
  end

  @required_params [:user_id, :currency, :integer_amount]

  @doc false
  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, @required_params)
    |> validate_required(@required_params)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:unique_user_wallet, name: :unique_wallet_index)
  end

  def create_changeset(params \\ %{}), do: changeset(%__MODULE__{}, params)
end
