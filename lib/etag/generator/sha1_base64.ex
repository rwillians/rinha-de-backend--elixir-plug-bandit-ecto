defmodule ETag.Generator.SHA1Base64 do
  @moduledoc """
  Mesma coisa que `ETag.Generator.SHA1`, porém, retorna a hash codificada em
  base64 (para economizar algums bytes de largura de banda).
  """

  @behaviour ETag.Generator

  import :crypto, only: [hash: 2]
  import Base, only: [encode64: 1]

  @impl true
  def generate(nil), do: nil
  def generate(content), do: hash(:sha, content) |> encode64()
end
