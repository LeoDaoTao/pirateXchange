defmodule PirateXchange.CurrenciesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PirateXchange.Currencies` context.
  """

  @doc """
  Generate a currency.
  """
  def currency_fixture(attrs \\ %{}) do
    {:ok, currency} =
      attrs
      |> Enum.into(%{
        code: "some code",
        name: "some name"
      })
      |> PirateXchange.Currencies.create_currency()

    currency
  end
end
