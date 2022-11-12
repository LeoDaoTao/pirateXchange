defmodule PirateXchange.Wallets.Wallet do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @typep currency :: PirateXchange.Currencies.Currency.t
  @type t :: %__MODULE__{
    id: pos_integer,
    currency: currency,
    integer_amount: integer,
    user_id: pos_integer
  }

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

  def from(query \\ __MODULE__), do: from(query, as: :wallet)

  @spec by_user_id(non_neg_integer) :: Ecto.Query.t
  def by_user_id(query \\ from(), user_id) do
    where(query, user_id: ^user_id)
  end

  @spec by_currency(non_neg_integer) :: Ecto.Query.t
  def by_currency(query \\ from(), currency) do
    where(query, currency: ^currency)
  end

  @spec by_user_id_and_currency(Ecto.Queryable.t, non_neg_integer, currency) :: Ecto.Query.t
  def by_user_id_and_currency(query \\ __MODULE__, user_id, currency) do
    query
    |> by_user_id(user_id)
    |> by_currency(currency)
  end

  def lock_wallet(query \\ Wallet), do: lock(query, "FOR UPDATE NOWAIT")
end
