defmodule ChatApp.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :url, :string, null: false
      add :name, :string, null: false
      add :description, :text
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:rooms, [:url])
    create index(:rooms, [:user_id])
    create index(:rooms, [:inserted_at])
  end
end
