defmodule Airtable do
  use HTTPoison.Base

  def fetch_records(table_name) do
     records = build_url(table_name)
       |> Airtable.get
       |> handle_response
     {:ok, records}
  end

  def build_url(table) do
    base = Application.get_env(:airtable, :base)
    "https://api.airtable.com/v0/#{base}/#{table}"
  end


  defp process_request_headers(headers) do
    api_key = Application.get_env(:airtable, :api_key)
    Enum.into(headers, [{"Authorization", "Bearer " <> api_key}])
  end

  defp handle_response(response) do
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Poison.decode!(body)
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        raise "Airtable error: status code #{status_code}"
      {:error, %HTTPoison.Error{reason: reason}} ->
        raise "HTTP error: " <> reason
      end
  end


end

defmodule Airtable.Record do
  use ExConstructor

  defstruct [id: "", fields: %{}, created_time: ""]
end
