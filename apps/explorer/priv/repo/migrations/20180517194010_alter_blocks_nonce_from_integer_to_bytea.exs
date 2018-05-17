defmodule Explorer.Repo.Migrations.AlterBlocksNonceFromIntegerToBytea do
  use Ecto.Migration

  def change do
    execute("ALTER TABLE blocks ALTER COLUMN nonce TYPE bytea USING decode(lpad(to_hex(nonce), 16, '0'), 'hex')")
  end
end
