defmodule PirateXchange.AccountsTest do
  use PirateXchange.DataCase

  alias PirateXchange.{
    Accounts,
    Accounts.User
  }

  @valid_user_params %{name: "Jack Sparrow", email: "sparrow@theblackperl.com"}
  @valid_user2_params %{name: "Blackbeard", email: "unshaven@queensrevenge.com"}
  @invalid_user_params %{name: nil, email: nil}

  describe "create_user/1" do
    test "should create a user with valid params" do
      assert {:ok, %User{name: "Jack Sparrow", email: "sparrow@theblackperl.com"}} =
        Accounts.create_user(@valid_user_params)

      [%User{}] = Repo.all(User)
    end

    test "should not create user with duplicate email" do
      assert {:ok, %User{name: "Jack Sparrow", email: "sparrow@theblackperl.com"}} =
        Accounts.create_user(@valid_user_params)

      assert {:error, %Ecto.Changeset{} = changeset} =
        Accounts.create_user(@valid_user_params)

      assert %{email: ["has already been taken"]} = errors_on(changeset)
    end

    test "should not create user with invalid params" do
      assert {:error, %Ecto.Changeset{} = changeset} =
        Accounts.create_user(@invalid_user_params)

      assert %{email: ["can't be blank"], name: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "all_users/0" do
    setup [:users]

    test "should return all users", %{users: users} do
      assert ^users = Accounts.all_users()
    end
  end

  describe "find_user/1" do
    setup [:user]

    test "should find a user by id", %{user: %{id: id}} do
      assert {:ok, %User{id: ^id}} = Accounts.find_user(%{id: id})
    end

    test "should find a user by email", %{user: %{email: email}} do
      assert {:ok, %User{email: ^email}} = Accounts.find_user(%{email: email})
    end
  end

  defp user(_ctx) do
    {:ok, user} = Accounts.create_user(@valid_user_params)
    %{user: user}
  end

  defp users(_ctx) do
    Accounts.create_user(@valid_user_params)
    Accounts.create_user(@valid_user2_params)
    %{users: Repo.all(User)}
  end
end
