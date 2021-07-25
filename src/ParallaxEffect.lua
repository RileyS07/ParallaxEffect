--!strict
-- Variables
local parallaxEffect = {}

-- Constructor
function parallaxEffect.new(speed: number?)
	local newObject = setmetatable({}, {__index = parallaxEffect})
	newObject.Layers = {}
	newObject.Parent = nil
	newObject.Speed = speed or 5
	
	return newObject
end

-- Functional Methods
function parallaxEffect:Update(deltaValue: number)
	assert(self:IsMounted(), "ParallaxEffect is not mounted.")
	assert(#self:GetLayers() > 0, "ParallaxEffect has no layers.")
	
	-- We update the position first then we deal with any bounds issues.
	local function updateLayer(layer: ImageLabel, overrideSpeed: number?)
		local inverseValue = #self:GetLayers() - layer.ZIndex + 1
		
		layer.Position -= UDim2.fromOffset(
			layer.AbsoluteSize.X * ((overrideSpeed or 1) / self:GetSpeed()) * deltaValue * (1 / inverseValue), 0
		)
		
		-- Said dealing with bound issues.
		
		-- If the right corner is further left than where the left corner should be.
		if deltaValue >= 0 and layer.AbsolutePosition.X + layer.AbsoluteSize.X < 0 then
			layer.Position = UDim2.fromOffset(
				layer.AbsoluteSize.X + (layer.AbsolutePosition.X + layer.AbsoluteSize.X), 0
			)

			-- If the left corner is further right than where the right corner should be.
		elseif deltaValue < 0 and layer.AbsolutePosition.X > layer.AbsoluteSize.X then
			layer.Position = UDim2.fromOffset(
				(layer.AbsolutePosition.X - layer.AbsoluteSize.X) - layer.AbsoluteSize.X, 0
			)
		end
	end
	
	-- Let's update the layers.
	for index = 1, #self:GetLayers() do
		local layerInformation = self:GetLayers()[index]
		updateLayer(layerInformation.Layer, layerInformation.OverrideSpeed)
		updateLayer(layerInformation.LayerClone, layerInformation.OverrideSpeed)
	end
end


function parallaxEffect:AddLayer(layerContentId: string, overrideSpeed: number?, optionalIndex: number?)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.BackgroundTransparency = 1
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.Image = layerContentId
	imageLabel.ZIndex = optionalIndex or #self:GetLayers() + 1
	imageLabel.Parent = self:GetMount()
	
	-- We have to assert the clone as an ImageLabel because luau type system is baby mode.
	local imageLabelClone = imageLabel:Clone() :: ImageLabel
	imageLabelClone.Position = UDim2.fromScale(1, 0)
	imageLabelClone.Parent = self:GetMount()
	
	local newLayerInformation: {Layer: ImageLabel, LayerClone: ImageLabel, OverrideSpeed: number?} = {
		Layer = imageLabel, 
		LayerClone = imageLabelClone, 
		OverrideSpeed = overrideSpeed
	}
	
	table.insert(self:GetLayers(), imageLabel.ZIndex, newLayerInformation)
	
	-- Do we need to update previous layers because of this change?
	for index, layerInformation in next, self:GetLayers() do
		if layerInformation.Layer.ZIndex ~= index then
			layerInformation.Layer.ZIndex = index
			layerInformation.LayerClone.ZIndex = index
		end
	end
	
	
	return self
end


function parallaxEffect:Mount(mount: GuiBase2d)
	self.Parent = mount
	
	for _, layerCollection in next, self:GetLayers() do
		layerCollection.Layer.Parent = self.Parent
		layerCollection.LayerClone.Parent = self.Parent
	end
end


function parallaxEffect:Clone()
	local newObject = parallaxEffect.new(self:GetSpeed())
	
	-- Cloning the layers.
	for index, layerCollection in next, self:GetLayers() do
		newObject:GetLayers()[index] = {
			Layer = layerCollection.Layer:Clone(),
			LayerClone = layerCollection.LayerClone:Clone(),
			OverrideSpeed = layerCollection.OverrideSpeed
		}
	end
	
	return newObject
end


function parallaxEffect:Destroy()
	for _, layerCollection in next, self:GetLayers() do
		layerCollection.Layer:Destroy()
		layerCollection.LayerClone:Destroy()
	end

	self.Layers = nil
	self.Parent = nil
	self.Speed = nil
	
	setmetatable(self, nil)
end


-- Utility Methods
function parallaxEffect:GetLayers() : {[number]: {Layer: ImageLabel, LayerClone: ImageLabel, OverrideSpeed: number?}}
	return self.Layers
end


function parallaxEffect:GetMount() : GuiBase2d?
	return self.Parent
end


function parallaxEffect:GetSpeed() : number
	return self.Speed	
end


function parallaxEffect:IsMounted() : boolean
	return self:GetMount() ~= nil
end


function parallaxEffect:SetSpeed(speed: number)
	self.Speed = speed
end


--
return parallaxEffect