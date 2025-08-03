defmodule ChatApp.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :url, :string
    field :name, :string
    field :description, :string

    belongs_to :user, ChatApp.Accounts.User
    has_many :messages, ChatApp.Chat.Message

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:url, :name, :description, :user_id])
    |> validate_required([:url, :name, :user_id])
    |> validate_format(:url, ~r/^https?:\/\/[^\s]+/, message: "must be a valid URL")
    |> unique_constraint(:url)
    |> normalize_url()
  end

  defp normalize_url(changeset) do
    case get_change(changeset, :url) do
      nil -> changeset
      url -> put_change(changeset, :url, String.downcase(url))
    end
  end
end
