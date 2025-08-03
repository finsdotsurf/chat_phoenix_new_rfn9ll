defmodule ChatApp.Repo.Migrations.AddRoomIdToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      # Make room_id nullable to avoid issues when adding to existing tables.
      # We can handle populating it later if needed.
      add :room_id, references(:rooms, on_delete: :delete_all)
    end

    create index(:messages, [:room_id])
    create index(:messages, [:room_id, :inserted_at])
  end
end
