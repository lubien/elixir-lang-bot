defmodule App.Commands do
  use App.Commander

  message do
    send_message "Sorry, there are no current commands in this bot"
  end
end
