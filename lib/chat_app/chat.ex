defmodule ChatApp.Chat do
  @moduledoc """
  The Chat context.
  """

  import Ecto.Query, warn: false
  alias ChatApp.Repo

  alias ChatApp.Chat.Message
  alias ChatApp.Chat.Room

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_messages do
    Repo.all(Message)
  end

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns the list of rooms.
  """
  def list_rooms do
    Repo.all(Room)
  end

  @doc """
  Gets a single room by URL.
  """
  def get_room_by_url(url) do
    normalized_url = String.downcase(url)
    Repo.get_by(Room, url: normalized_url)
  end

  @doc """
  Creates a room.
  """
  def create_room(attrs \\ %{}) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets messages for a specific room.
  """
  def list_messages_for_room(room_id) do
    from(m in Message, where: m.room_id == ^room_id, order_by: [asc: m.inserted_at])
    |> Repo.all()
  end
end
