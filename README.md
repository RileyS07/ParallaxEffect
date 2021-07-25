# ParallaxEffect
 
ParallaxEffect is a stand alone library that makes creating [parallax scrolling](https://en.wikipedia.org/wiki/Parallax_scrolling) a lot easier to setup and work with.

# Usage

```lua
local exampleParallax = parallaxEffect.new(5)

exampleParallax:AddLayer(
    "http://www.roblox.com/asset/?id=7142912853", 0
):AddLayer(
    "http://www.roblox.com/asset/?id=7142924307"
):AddLayer(
    "http://www.roblox.com/asset/?id=7142931111"
):AddLayer(
    "http://www.roblox.com/asset/?id=7142938951"
):AddLayer(
    "http://www.roblox.com/asset/?id=7142942303"
):Mount(workspace.ParallaxBackground.SurfaceGui)  -- A SurfaceGui in Workspace.

game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
    exampleParallax:Update(deltaTime)
end)
```
