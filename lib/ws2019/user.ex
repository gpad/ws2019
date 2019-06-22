defmodule Ws2019.User do
  defstruct [:id, :name, :age, :tags]

  def new(opts \\ []) do
    %__MODULE__{
      id: UUID.uuid4(),
      name: Keyword.get(opts, :name, "name-#{UUID.uuid4()}"),
      age: Keyword.get(opts, :age),
      tags: Keyword.get(opts, :tags, [])
    }
  end

  def add_tag(%__MODULE__{} = user, tag) when is_atom(tag) do
    %{user | tags: [tag | user.tags]}
  end

  def remove_tag(%__MODULE__{tags: tags} = user, tag) do
    new_tags = Enum.filter(tags, fn t -> t != tag end)
    %{user | tags: new_tags}
  end
end
