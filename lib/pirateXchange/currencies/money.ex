defmodule PirateXchange.Currencies.Money do
  @enforce_keys [:code, :amount]
  defstruct(
    code: :USD,
    amount: "0.0000"
  )

  @type t :: %__MODULE__{
    code: atom,
    amount: String.t
  }

  #TODO: expand function to handle errors and adding
  #Money from different currencies at current FX rate
  #Do we need a third param if different currencies?
  #Possibly add a list of currencies
  #decide if we want to return a struct or :ok tuple
  @spec add(t, t) :: t | {:error, String.t}
  def add(%__MODULE__{code: code1, amount: amt1},
          %__MODULE__{code: code2, amount: amt2})
      when code1 === code2 do
        %__MODULE__{code: code1, amount: add_two_money_amounts(amt1, amt2)}
  end

  #convert integer pips to decimal pips in string form
  #for display use only
  #will work with all curriecies except JPY, which uses
  #a two digit pip format instead of a 4 digit pip
  @spec to_pips(integer) :: String.t
  defp to_pips(amount) do
    amount
    |> Kernel./(10_000)
    |> :erlang.float_to_binary(decimals: 4)
  end

  @spec string_to_integer_pips(String.t) :: integer
  defp string_to_integer_pips(numeric_string) do
    numeric_string
    |> ensure_decimal_point()
    |> ensure_4_pips()
    |> String.replace(".", "")
    |> String.to_integer
  end

  @spec add_two_money_amounts(String.t, String.t) :: String.t
  defp add_two_money_amounts(amt1, amt2) do
    to_pips(string_to_integer_pips(amt1) + string_to_integer_pips(amt2))
  end

  @spec ensure_decimal_point(String.t) :: String.t
  defp ensure_decimal_point(numeric_string) do
    case String.contains?(numeric_string, ".") do
      true -> numeric_string
      _    -> numeric_string <> ".0000"
    end
  end

  @spec ensure_4_pips(String.t) :: String.t
  defp ensure_4_pips(numeric_string) do
    [whole, decimal] = String.split(numeric_string, ".")
    "#{whole}.#{ensure_4_digits(decimal)}"
  end

  #if used in production it should have proper rounding
  @spec ensure_4_digits(String.t) :: String.t
  defp ensure_4_digits(numeric_string) do
    numeric_string
    |> String.slice(0..3)
    |> String.pad_trailing(4, "0")
  end
end
