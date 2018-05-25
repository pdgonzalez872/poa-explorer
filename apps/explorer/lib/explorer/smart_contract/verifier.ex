defmodule Explorer.SmartContract.Verifier do
  @moduledoc """
  Module responsible to verify the Smart Contract.

  Given a contract source code the bytecode will be generated  and matched
  against the existing Creation Address Bytecode, if it matches the contract is
  then Verified.
  """

  alias Explorer.Chain
  alias Explorer.SmartContract.Solidity.CodeCompiler

  def evaluate_authenticity(_, %{"name" => "", "contract_code" => ""}) do
    {:error, %{name: "can't be blank", contract_code: "can't be blank"}}
  end

  def evaluate_authenticity(address_hash, %{"name" => name, "contract_code" => contract_code}) do
    solc_output = CodeCompiler.run(name, contract_code)["contracts"][name][name]

    generated_bytecode = extract_bytecode(solc_output["evm"]["bytecode"]["object"])

    "0x" <> blockchain_bytecode =
      address_hash
      |> Chain.smart_contract_bytecode()
      |> extract_bytecode

    if generated_bytecode == blockchain_bytecode do
      {:ok, %{abi: solc_output["abi"]}}
    else
      {:error, %{generated_bytecode: generated_bytecode, blockchain_bytecode: blockchain_bytecode}}
    end
  end

  @doc """
  In order to discover the bytecode we need to remove the `swarm source` from
  the hash.

  `64` characters to the left of `0029` are the `swarm source`. The rest on
  the left is the `bytecode` to be validated.
  """
  def extract_bytecode(code) do
    {bytecode, _swarm_source} =
      code
      |> String.split("0029")
      |> List.first()
      |> String.split_at(-64)

    bytecode
  end
end
