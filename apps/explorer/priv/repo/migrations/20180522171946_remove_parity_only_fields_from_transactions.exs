defmodule Explorer.Repo.Migrations.RemoveParityOnlyFieldsFromTransactions do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      remove(:public_key)
      remove(:standard_v)
    end
  end
end
