defmodule PirateXchange.Currencies.Money do
  @enforce_keys [:code, :amount_in_cents]
  defstruct [:code, :amount_in_cents]
end
