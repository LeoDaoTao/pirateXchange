defmodule PirateXchange.Accounts.User do
  alias PirateXchange.Wallets.Wallet
  use Ecto.Schema
  import Ecto.Changeset

  @required_params [:name, :email]

  @type t :: %__MODULE__{
    id: pos_integer,
    name: String.t,
    email: String.t,
  }

  schema "users" do
    field :name,  :string
    field :email, :string

    has_many :wallets, Wallet
  end


  @spec changeset(t, map) :: Ecto.Changeset.t
  def changeset(user, params \\ %{}) do
    user
    |> cast(params, @required_params)
    |> cast_assoc(:wallets)
    |> validate_required(@required_params)
    |> unique_constraint(:email)
  end

  @spec create_changeset() :: Ecto.Changeset.t
  @spec create_changeset(map) :: Ecto.Changeset.t
  def create_changeset(params \\ %{}), do: changeset(%__MODULE__{}, params)
end
