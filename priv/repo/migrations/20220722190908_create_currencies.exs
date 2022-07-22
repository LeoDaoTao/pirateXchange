defmodule PirateXchange.Repo.Migrations.CreateCurrencies do
  use Ecto.Migration

  def change do
    create table(:currencies) do
      add :code, :string, size: 3
      add :name, :text
    end

    create unique_index(:currencies, [:code])
  end
end
