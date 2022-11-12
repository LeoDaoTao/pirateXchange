defmodule PirateXchangeWeb.Router do
  use PirateXchangeWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :api

    forward "/graphql", Absinthe.Plug,
      schema: PirateXchangeWeb.Schema

    if Mix.env() === :dev do
      forward "/graphiql", Absinthe.Plug.GraphiQL,
        schema: PirateXchangeWeb.Schema,
        interface: :playground
    end
  end
end
