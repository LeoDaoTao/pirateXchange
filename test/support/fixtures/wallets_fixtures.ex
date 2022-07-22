defmodule PirateXchange.WalletsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PirateXchange.Wallets` context.
  """

  @doc """
  Generate a wallet.
  """
  def wallet_fixture(attrs \\ %{}) do
    {:ok, wallet} =
      attrs
      |> Enum.into(%{
        balance: 42
      })
      |> PirateXchange.Wallets.create_wallet()

    wallet
  end
end
