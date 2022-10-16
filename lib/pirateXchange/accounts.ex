defmodule PirateXchange.Accounts do
  alias PirateXchange.Accounts.User
  alias EctoShorts.Actions

  def create_user(params) do
    case Actions.create(User, params) do
      {:error, msg} -> {:error, msg}
      res           -> res
    end
  end
end
