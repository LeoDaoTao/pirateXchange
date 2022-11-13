defmodule PirateXchangeWeb.Schema.Mutations.UserTest do
  use PirateXchange.DataCase, async: true

  alias PirateXchange.Accounts
  alias PirateXchangeWeb.Schema

  @create_user_doc """
    mutation CreateUser($name: String!, $email: String!) {
      createUser(name: $name, email: $email){
        id
        name
        email
      }
    }
  """

  describe "@createUser" do
    test "should create a user with provided name & email" do
      assert {:ok, %{data: data}} = Absinthe.run(@create_user_doc, Schema,
        variables: %{
          "name" => "Test Pirate",
          "email" => "pirate@arr.com"
        })

      assert {:ok, user} = Accounts.find_user(%{id: String.to_integer(data["createUser"]["id"])})
      assert user.name === data["createUser"]["name"]
      assert user.email === data["createUser"]["email"]
    end
  end

  @update_user_doc """
    mutation UpdateUser($id: ID!, $name: String, $email: String) {
      updateUser(id: $id, name: $name, email: $email){
        id
        name
        email
      }
    }
  """

  describe "@updateUser" do
    test "shuld update an existing user" do
      assert {:ok, user} = Accounts.create_user(%{name: "Jack", email: "jack@test.com"})

      assert {:ok, %{data: _data}} = Absinthe.run(@update_user_doc, Schema,
        variables: %{
          "id" => user.id,
          "name" => "Test Pirate",
          "email" => "pirate@arr.com"
        })

      assert {:ok, user} = Accounts.find_user(%{id: user.id})
      assert user.name === "Test Pirate"
      assert user.email === "pirate@arr.com"
    end
  end
end
