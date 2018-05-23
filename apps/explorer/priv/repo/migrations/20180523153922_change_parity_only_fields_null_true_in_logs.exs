defmodule Explorer.Repo.Migrations.RemoveParityOnlyFieldsFromLogs do
  use Ecto.Migration

  def change do
    alter table(:logs) do
      # Parity supplies it; Geth does not.
      modify(:type, :string, null: true)
    end
  end
end
