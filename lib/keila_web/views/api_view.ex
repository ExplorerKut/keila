defmodule KeilaWeb.ApiView do
  use KeilaWeb, :view
  alias Keila.Pagination
  import KeilaWeb.ApiNormalizer.SchemaMapper

  def render("contacts.json", %{contacts: contacts = %Pagination{}}) do
    %{
      "meta" => %{
        "page" => contacts.page,
        "pageCount" => contacts.page_count,
        "count" => contacts.count
      },
      "data" => Enum.map(contacts.data, &contact_data/1)
    }
  end

  def render("contact.json", %{contact: contact}) do
    %{
      "data" => contact_data(contact)
    }
  end

  def render("campaigns.json", %{campaigns: campaigns = %Pagination{}}) do
    %{
      "meta" => %{
        "page" => campaigns.page,
        "pageCount" => campaigns.page_count,
        "count" => campaigns.count
      },
      "data" => Enum.map(campaigns.data, &campaign_data/1)
    }
  end

  def render("campaign.json", %{campaign: campaign}) do
    %{"data" => campaign_data(campaign)}
  end

  def render("segments.json", %{segments: segments = %Pagination{}}) do
    %{
      "meta" => %{
        "page" => segments.page,
        "pageCount" => segments.page_count,
        "count" => segments.count
      },
      "data" => Enum.map(segments.data, &segment_data/1)
    }
  end

  def render("segment.json", %{segment: segment}) do
    %{"data" => segment_data(segment)}
  end

  def render("errors.json", %{errors: errors}) do
    %{
      "errors" => Enum.map(errors, &error_object/1)
    }
  end

  defp contact_data(contact) do
    %{
      "id" => contact.id,
      "firstName" => contact.first_name,
      "lastName" => contact.last_name,
      "email" => contact.email,
      "insertedAt" => contact.inserted_at,
      "updatedAt" => contact.updated_at,
      "data" => contact.data
    }
  end

  defp campaign_data(campaign) do
    %{
      "id" => campaign.id,
      "senderId" => campaign.sender_id,
      "segmentId" => campaign.segment_id,
      "subject" => campaign.subject,
      "textBody" => campaign.text_body,
      "insertedAt" => campaign.inserted_at,
      "updatedAt" => campaign.updated_at,
      "sentAt" => campaign.sent_at,
      "scheduledFor" => campaign.scheduled_for,
      "settings" => %{
        "type" => campaign.settings.type
      }
    }
  end

  defp segment_data(segment) do
    %{
      "id" => segment.id,
      "name" => segment.name,
      "insertedAt" => segment.inserted_at,
      "updatedAt" => segment.updated_at,
      "filter" => segment.filter
    }
  end

  defp error_object(error) do
    error_object(error[:title], error[:detail])
    |> Map.put_new_lazy("status", fn -> error |> Keyword.fetch!(:status) |> to_string() end)
  end

  defp error_object(title, detail = %Jason.DecodeError{}) do
    title = title || "Invalid JSON"
    detail = Jason.DecodeError.message(detail)
    %{"title" => title, "detail" => detail}
  end

  defp error_object(title, changeset = %Ecto.Changeset{}) do
    {field, {message, _}} = changeset.errors |> List.first()
    field_name = to_camel_case(changeset.data, field)

    %{
      "title" => title || "Validation failed",
      "detail" => message,
      "pointer" => "/data/attributes/#{field_name}"
    }
  end

  defp error_object(title, detail) when is_binary(title) and is_binary(detail),
    do: %{"title" => title, "detail" => detail}

  defp error_object(title, nil) when is_binary(title), do: %{"title" => title}
  defp error_object(nil, detail) when is_binary(detail), do: %{"detail" => detail}
end