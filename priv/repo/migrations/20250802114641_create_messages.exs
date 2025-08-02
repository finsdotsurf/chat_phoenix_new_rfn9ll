defmodule ChatApp.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :text, null: false
      add :user_id, :integer, null: false
      add :username, :string, null: false

      timestamps()
    end

    create index(:messages, [:user_id])
    create index(:messages, [:inserted_at])
  end
end
