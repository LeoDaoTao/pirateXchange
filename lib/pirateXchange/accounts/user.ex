defmodule PirateXchange.Accounts.User do
  alias __MODULE__
  use Ecto.Schema
  import Ecto.{Changeset, Query}

  schema "users" do
    field :name, :string
  end

  @available_params [:name]

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, @available_params)
    |> validate_required([:name])
  end

  def create_changeset(params \\ %{}), do: changeset(%__MODULE__{}, params)

  def from(query \\ User), do: from(query, as: :user)

  def by_id(query \\ from(), id), do: where(query, id: ^id)
end
