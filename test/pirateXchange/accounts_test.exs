defmodule PirateXchange.AccountsTest do
  use PirateXchange.DataCase

  alias PirateXchange.{
    Accounts,
    Accounts.User
  }

  @valid_user_params %{name: "Jack Sparrow", email: "sparrow@theblackperl.com"}
  @invalid_user_params %{name: nil, email: nil}

  describe "create_user/1" do
    test "creates a user with valid params" do
      assert {:ok, %User{name: "Jack Sparrow", email: "sparrow@theblackperl.com"}} =
        Accounts.create_user(@valid_user_params)

      [%User{}] = Repo.all(User)
    end

    test "does not create user with duplicate email" do
      assert {:ok, %User{name: "Jack Sparrow", email: "sparrow@theblackperl.com"}} =
        Accounts.create_user(@valid_user_params)

      assert {:error, %Ecto.Changeset{} = changeset} =
        Accounts.create_user(@valid_user_params)

      assert %{email: ["has already been taken"]} == errors_on(changeset)
    end

    test "does not create user with invalid params" do
      assert {:error, %Ecto.Changeset{} = changeset} =
        Accounts.create_user(@invalid_user_params)

      assert %{email: ["can't be blank"], name: ["can't be blank"]} == errors_on(changeset)
    end
  end

end
