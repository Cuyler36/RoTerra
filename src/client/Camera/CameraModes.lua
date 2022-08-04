--[[ --------------------------------------------------------------------

-- 4thAxis
-- 6/20/22

	MIT License

	Copyright (c) 2022 4thAxis

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
]]
--------------------------------------------------------------------

local Module = {}

--------------------------------------------------------------------
---------------------------  Imports   -----------------------------
--------------------------------------------------------------------

local Configs = require(script.Parent:WaitForChild("Configurations"))

--------------------------------------------------------------------
--------------------------  Services  ------------------------------
--------------------------------------------------------------------

local Players = game:GetService("Players")

--------------------------------------------------------------------
-------------------------  Constants  ------------------------------
--------------------------------------------------------------------

Module.Epsilon = 1e-5
Module.CameraAngleX = 0
Module.CameraAngleY = 0

--------------------------------------------------------------------

local Player = Players.LocalPlayer

local Camera = workspace.CurrentCamera

local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

--------------------------------------------------------------------
--------------------------  Privates  ------------------------------
--------------------------------------------------------------------

local function DisableRobloxCamera()
	if Camera.CameraType ~= Enum.CameraType.Scriptable then
		Camera.CameraType = Enum.CameraType.Scriptable
	end
end

local function GetViewMatrix(Eye, Focus)
	-- Faster alternative to cframe.lookat for our case since we are more commonly prone to special cases such as: when focus is facing up/down or if focus and eye are colinear vectors
	local XAxis = Focus - Eye -- Lookvector
	if XAxis:Dot(XAxis) <= Module.Epsilon then
		return CFrame.new(Eye.X, Eye.Y, Eye.Z, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	end
	XAxis = XAxis.Unit
	local Xx, Xy, Xz = XAxis.X, XAxis.Y, XAxis.Z
	local RNorm = ((Xz * Xz) + (Xx * Xx)) -- R:Dot(R), our right vector
	if RNorm <= Module.Epsilon and math.abs(XAxis.Y) > 0 then
		return CFrame.fromMatrix(Eye, -math.sign(XAxis.Y) * Vector3.zAxis, Vector3.xAxis)
	end
	RNorm = 1 / (RNorm ^ 0.5) -- take the root of our squared norm and inverse division
	local Rx, Rz = -(Xz * RNorm), (Xx * RNorm) -- cross y-axis with right and normalize
	local Ux, Uy, Uz = -Rz * (Rz * Xx - Rx * Xz), -(Rz * Rz) * Xy - (Rx * Rx) * Xy, Rx * (Rz * Xx - Rx * Xz) -- cross right and up and normalize.
	local UNorm = 1 / ((Ux * Ux) + (Uy * Uy) + (Uz * Uz)) ^ 0.5 -- inverse division and multiply this ratio rather than dividing each component
	return CFrame.new(
		Eye.X,
		Eye.Y,
		Eye.Z,
		Rx,
		-Xy * Rz,
		Ux * UNorm,
		0,
		(Rz * Xx) - Rx * Xz,
		Uy * UNorm,
		Rz,
		Xy * Rx,
		Uz * UNorm
	)
end

--------------------------------------------------------------------
-------------------------  Functions  ------------------------------
--------------------------------------------------------------------

Module.SideScrollingCamera = function(_, CameraDepth, HeightOffset, FOV)
	CameraDepth = CameraDepth or Configs.SideCameraDepth
	HeightOffset = HeightOffset or Configs.SideHeightOffset
	Camera.FieldOfView = FOV or Configs.SideFieldOfView
	DisableRobloxCamera()

	local Focus = HumanoidRootPart.Position + Vector3.new(0, HeightOffset, 0)
	local Eye = Vector3.new(Focus.X, Focus.Y, CameraDepth)
	Camera.CFrame = GetViewMatrix(Eye, Focus)
end

Module.SetFocusPart = function(focusPart: BasePart): ()
	HumanoidRootPart = focusPart
end

return Module
