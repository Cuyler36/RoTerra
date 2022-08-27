local Packages = game:GetService("ReplicatedStorage").Packages
local roact = require(Packages.roact)

local darkTheme = {
	foreground = Color3.fromRGB(255, 255, 255),
	background = Color3.fromRGB(61, 61, 61),
}

local ThemeContext = roact.createContext(darkTheme)
local ThemeProvider = roact.Component:extend("ThemeProvider")

function ThemeProvider:updateTheme(newTheme)
	self:setState({
		theme = newTheme,
	})
end

function ThemeProvider:init()
	self:updateTheme()
end

function ThemeProvider:render()
	return roact.createElement(ThemeContext.Provider, {
		value = self.state.theme,
	}, self.props[roact.Children])
end

local function with(renderCallback)
	return roact.createElement(ThemeContext.Consumer, {
		render = renderCallback,
	})
end

return {
	ThemeProvider = ThemeProvider,
	Consumer = ThemeContext.Consumer,
	with = with,
}
