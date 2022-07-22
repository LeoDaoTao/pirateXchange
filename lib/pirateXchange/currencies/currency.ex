defmodule PirateXchange.Currencies.Currency do
  use Ecto.Schema
  import Ecto.Changeset

  schema "currencies" do
    field :code, :string
    field :name, :string
  end

  @doc false
  def changeset(currency, attrs) do
    currency
    |> cast(attrs, [:code, :name])
    |> validate_required([:code, :name])
  end
end
