defmodule PirateXchangeWeb.Schema.Queries.User do
  use Absinthe.Schema.Notation
  alias PirateXchangeWeb.Resolvers

  object :user_queries do
    @desc "Returns a user based on params"
    field :user, :user do
      arg :id, :id
      arg :email, :string

      resolve &Resolvers.User.find/2
    end
  end

end
