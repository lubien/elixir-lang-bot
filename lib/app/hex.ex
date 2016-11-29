defmodule App.Hex do
  require Logger

  @endpoint "https://hex.pm/api"

  # Public API

  def packages(search, sort \\ "downloads") do
    url = @endpoint <> "/packages"

    action = fn ->
      HTTPoison.get url, [{"Accept", "application/json"}], params: [search: search, sort: sort]
    end

    process_request(action)
  end

  def package_to_inline_query_result(package) do
    url = String.replace package["url"], "/api", ""
    name = package["name"]
    description = get_in(package, ["meta", "description"])
    github = get_in(package, ["meta", "links", "github"]) ||
             get_in(package, ["meta", "links", "GitHub"])
    image = if not is_nil(github) do
      owner = github
      |> String.split("/")
      |> Enum.at(3)

      "https://github.com/#{owner}.png"
    else
      nil
    end

    hex_link = {"Hex Package", url}
    links = if not is_nil(github) do
      github_link = {"GitHub Repo", github}

      [github_link, hex_link]
    else
      [hex_link]
    end

    # I've choosen to use HTML in this case because sometimes
    # there is text that mess with Telegram's markdown parser.
    message = """
    <b>#{HtmlEntities.encode name}</b>
    <i>#{HtmlEntities.encode description}</i>
    #{links
      |> Enum.map(fn {title, url} ->
        "<a href='#{url}'>#{title}</a>"
      end)
      |> Enum.join(" | ")}
    """

    %Nadia.Model.InlineQueryResult.Article{
      id: url,
      title: name,
      description: description,
      thumb_url: image,
      input_message_content: %{
        message_text: message,
        parse_mode: "html"
      }
    }
  end

  # Private API

  defp process_request(action) do
    action.()
    case action.() do
      {:ok, %{status_code: 429, headers: headers}} ->
        get_rate_limit(headers)
        |> wait_rate_time_limit

        process_request(action)
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, Poison.decode! body}
      {:error, err} ->
        Logger.log :error, "Hex request error"
        Logger.log :error, err
        {:error, err}
    end
  end

  defp get_rate_limit(headers) do
    headers
    |> Enum.find(fn
      {"X-Ratelimit-Reset", value} -> value
      _ -> false
    end)
    |> elem(1)
  end

  defp wait_rate_time_limit(reset_time) do
    reset_time = String.to_integer reset_time
    now = Calendar.DateTime.now!("UTC")
          |> Calendar.DateTime.Format.unix

    :timer.sleep (reset_time - now) * 1000
  end
end
