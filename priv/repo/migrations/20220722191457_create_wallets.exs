defmodule PirateXchange.Repo.Migrations.CreateWallets do
  use Ecto.Migration

  def change do
    create table(:wallets) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :currency_id, references(:currencies, on_delete: :delete_all)
      add :balance, :integer
      add :default, :boolean, default: false, null: false
    end

    create index(:wallets, [:user_id])
    create index(:wallets, [:currency_id])
  end
end
