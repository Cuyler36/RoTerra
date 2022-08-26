export type BlockData_t = {
	Name: string,
	Description: string,
	Id: number,
	Color: Color3,
	Material: Enum.Material,
	PhysicalProperties: PhysicalProperties?,
	MaxStackSize: number,
	Type: number,
	Placeable: boolean,
}

return {
	{
		Name = "Dirt",
		Description = "A block of dirt.",
		Id = 0,
		Color = Color3.fromRGB(109, 97, 72),
		Material = Enum.Material.Ground,
		MaxStackSize = 999,
		Type = 0,
		Placeable = true,
	},
	{
		Name = "Grass",
		Description = "A block of grass.",
		Id = 1,
		Color = Color3.fromRGB(9, 163, 9),
		Material = Enum.Material.Grass,
		MaxStackSize = 999,
		Type = 0,
		Placeable = true,
	},
} :: { BlockData_t }
