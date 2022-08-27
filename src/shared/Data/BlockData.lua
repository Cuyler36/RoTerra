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
	[0] = {
		Name = "Air",
		Description = "Air.",
		Id = 0,
		Color = Color3.fromRGB(255, 255, 255),
		Material = Enum.Material.Air,
		MaxStackSize = 0,
		Type = -1,
		Placeable = false,
	},
	[1] = {
		Name = "Dirt",
		Description = "A block of dirt.",
		Id = 1,
		Color = Color3.fromRGB(109, 97, 72),
		Material = Enum.Material.Ground,
		MaxStackSize = 999,
		Type = 0,
		Placeable = true,
	},
	[2] = {
		Name = "Grass",
		Description = "A block of grass.",
		Id = 2,
		Color = Color3.fromRGB(9, 163, 9),
		Material = Enum.Material.Grass,
		MaxStackSize = 999,
		Type = 0,
		Placeable = true,
	},
} :: { BlockData_t }
