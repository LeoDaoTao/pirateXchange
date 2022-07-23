defmodule PirateXchange.Currencies.Money do
  @enforce_keys [:code, :amount]
  defstruct [:code, :amount]
end
