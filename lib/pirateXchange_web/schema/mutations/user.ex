defmodule PirateXchangeWeb.Schema.Mutations.User do
  use Absinthe.Schema.Notation
  alias PirateXchangeWeb.Resolvers

  object :user_mutations do
    @desc "Create a user"
    field :create_user, :user do
      arg :name, non_null(:string)
      arg :email, non_null(:string)

      resolve &Resolvers.User.create_user/2
    end

    @desc "Updates a user"
    field :update_user, :user do
      arg :id, non_null(:id)
      arg :name, :string
      arg :email, :string

      resolve &Resolvers.User.update_user/2
    end
  end
end
