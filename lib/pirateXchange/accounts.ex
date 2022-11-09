defmodule PirateXchange.Accounts do
  alias PirateXchange.Accounts.User
  alias PirateXchange.Accounts.Transfer
  alias EctoShorts.Actions

  @spec create_user(map) :: {:ok, User.t} | {:error, String.t}
  def create_user(params), do: Actions.create(User, params)

  @spec delete_user(integer) :: {:ok, User.t} | {:error, String.t}
  def delete_user(user_id), do: Actions.delete(User, user_id)

  @spec all_users() :: [User.t]
  def all_users(), do: Actions.all(User)

  @spec find_user(map) :: {:ok, User.t} | {:error, Ecto.Changeset.t}
  def find_user(params \\ %{}), do: Actions.find(User, params)

  @spec transfer(Transfer.t) :: {:ok, :transfer_successful} | {:error, :transfer_failed}
  defdelegate transfer(transfer), to: Transfer, as: :send
end
