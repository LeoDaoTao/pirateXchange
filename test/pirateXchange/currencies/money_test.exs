defmodule PirateXchange.Currencies.MoneyTest do
  use ExUnit.Case

  alias PirateXchange.Currencies.Money

  describe "add/2" do
    test "should add two Money values of the same currency" do
      assert Money.add(
        %Money{code: :usd, amount: "1.00"},
        %Money{code: :usd, amount: "2.00"}
      ) ===
        %Money{code: :usd, amount: "3.00"}

      assert Money.add(
        %Money{code: :cdn, amount: "1.12"},
        %Money{code: :cdn, amount: "2.56"}
      ) ===
        %Money{code: :cdn, amount: "3.68"}
    end

    test "shuld return 2 digit pip value even if 2 digit pips where not supplied" do
      assert Money.add(
        %Money{code: :usd, amount: "1.0"},
        %Money{code: :usd, amount: "2.00"}
      ) ===
        %Money{code: :usd, amount: "3.00"}

      assert Money.add(
        %Money{code: :cdn, amount: "1.00"},
        %Money{code: :cdn, amount: "2.0"}
      ) ===
        %Money{code: :cdn, amount: "3.00"}

      assert Money.add(
        %Money{code: :pln, amount: "1.00"},
        %Money{code: :pln, amount: "2.0"}
      ) ===
        %Money{code: :pln, amount: "3.00"}

      assert Money.add(
        %Money{code: :pln, amount: "1.32"},
        %Money{code: :pln, amount: "2.33"}
      ) ===
        %Money{code: :pln, amount: "3.65"}

      assert Money.add(
        %Money{code: :usd, amount: "1"},
        %Money{code: :usd, amount: "2"}
      ) ===
        %Money{code: :usd, amount: "3.00"}
    end
  end
end
