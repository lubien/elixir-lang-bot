defmodule App.Telegram do
  def get_chat_id(update) do
    case update do
      %{inline_query: inline_query} when not is_nil(inline_query) ->
        inline_query.from.id
      %{callback_query: callback_query} when not is_nil(callback_query) ->
        callback_query.message.chat.id
      update ->
        update.message.chat.id
    end
  end
end
