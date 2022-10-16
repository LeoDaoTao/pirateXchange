defmodule PirateXchange.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :text, null: false
      add :email, :text, null: false
    end

    create unique_index(:users, [:email])
  end
end
