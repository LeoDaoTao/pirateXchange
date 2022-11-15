defmodule PirateXchangeWeb.Schema.Subscriptions.UserTotalWorth do
  use Absinthe.Schema.Notation

  object :total_worth_subscriptions do
    @desc "Broadcasts user total worth"
    field :total_worth_change, :user_total_worth do
      arg :user_id, non_null(:id)
      arg :currency, non_null(:currency)

      config fn args, _ctx ->
        {:ok, topic: "user_id:#{args.user_id}|currency:#{args.currency}"}
      end
    end
  end
end
