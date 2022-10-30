defmodule PirateXchange.Repo.Migrations.CreateWallets do
  use Ecto.Migration

  def change do
    create table(:wallets) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :currency, :string
      add :integer_amount, :integer
    end

    create index(:wallets, [:user_id])
    create index(:wallets, [:currency])
    create unique_index(:wallets, [:user_id, :currency], name: :unique_wallet_index)
  end
end
