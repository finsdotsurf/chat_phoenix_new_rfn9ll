defmodule ChatApp.Repo.Migrations.AddRoomIdToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :room_id, references(:rooms, on_delete: :delete_all), null: false
    end

    create index(:messages, [:room_id])
    create index(:messages, [:room_id, :inserted_at])
  end
end
