defmodule PirateXchange.AccountsTest do
  use PirateXchange.DataCase

  alias PirateXchange.Accounts
  alias PirateXchange.Accounts.User

  import PirateXchange.UserFixtures,
    only: [users: 1, user_params: 1]

  describe "create_user/1" do
    setup :user_params

    test "should create a user with valid params",
      %{user_params: %{name: name, email: email}} do

      assert {:ok, %User{name: ^name, email: ^email}} =
        Accounts.create_user(%{name: name, email: email})

      assert [%User{name: ^name, email: ^email}] = Repo.all(User)
    end

    test "should not create user with duplicate email",
      %{user_params: %{name: name, email: email}} do

      assert {:ok, %User{name: ^name, email: ^email}} =
        Accounts.create_user(%{name: name, email: email})

      assert {:error, %Ecto.Changeset{} = changeset} =
        Accounts.create_user(%{name: name, email: email})

      assert %{email: ["has already been taken"]} = errors_on(changeset)
    end

    test "should not create user with invalid params" do
      assert {:error, %Ecto.Changeset{} = changeset} =
        Accounts.create_user(%{})

      assert %{email: ["can't be blank"], name: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "all_users/0" do
    setup :users

    test "should return all users", %{users: users} do
      assert ^users = Accounts.all_users()
    end
  end

  describe "find_user/1" do
    setup :users

    test "should find a user by id", ctx do
      id = ctx.user1.id
      assert {:ok, %User{id: ^id}} = Accounts.find_user(%{id: id})
    end

    test "should find a user by email", ctx do
      email = ctx.user1.email
      assert {:ok, %User{email: ^email}} = Accounts.find_user(%{email: email})
    end
  end
end
