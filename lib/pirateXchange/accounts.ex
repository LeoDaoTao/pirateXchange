defmodule PirateXchange.Accounts do
  alias PirateXchange.Accounts.User
  alias EctoShorts.Actions

  @spec create_user(map) :: {:ok, User.t} | {:error, String.t}
  def create_user(params), do: Actions.create(User, params)

  @spec all_users() :: [User.t]
  def all_users(), do: Actions.all(User)

  @spec find_user(map) :: {:ok, User.t} | {:error, Ecto.Changeset.t}
  def find_user(params), do: Actions.find(User, params)
end
