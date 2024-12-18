local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Chromium",
   LoadingTitle = "Chromium",
   LoadingSubtitle = "by Notagoodname",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = Chromium,
      FileName = "Chromium"
   },
   Discord = {
      Enabled = true,
      Invite = "K2qyfUMGHc",
      RememberJoins = true
   },
   KeySystem = true,
           KeySettings = {
      Title = "Key",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

-- Add a Home tab with a custom icon (Using the provided URL)
local homeIconUrl = "https://cdn.discordapp.com/attachments/1149817777205555300/1318093751523999795/house.png?ex=676111f7&is=675fc077&hm=bca13a7079dbcf4a700d470af91059872f5cf89377d56c14bb746f18a1420eea&"
local MainTab = Window:CreateTab("Home", nil, {
   Icon = homeIconUrl  -- Add the icon to the tab using the provided URL
})

local MainSection = MainTab:CreateSection("Main")

Rayfield:Notify({
   Title = "Script Executed",
   Content = "Script Injected Successfully",
   Duration = 3.5,
})

-- Variables
local FlyEnabled = false
local NoClipEnabled = false
local FlySpeed = 50
local InfiniteJumpEnabled = false
local WalkSpeed = 16
local AscendSpeed = 10
local DescendSpeed = 10

-- Services
local Players = game:GetService("Players")
local Input = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local Player = Players.LocalPlayer

-- Infinite Jump
local function enableInfiniteJump()
   local Character = Player.Character or Player.CharacterAdded:Wait()
   local Humanoid = Character:FindFirstChildOfClass("Humanoid")

   game.StarterGui:SetCore("SendNotification", {Title="Chromium"; Text="Infinite Jump Activated!"; Duration=5;})

   Input.InputBegan:Connect(function(input)
      if input.KeyCode == Enum.KeyCode.Space and InfiniteJumpEnabled then
         Humanoid:ChangeState("Jumping")
      end
   end)
end

-- Fly Logic (Infinite Yield style) with Q and E for altitude control
local function startFly()
   local Character = Player.Character or Player.CharacterAdded:Wait()
   local RootPart = Character:WaitForChild("HumanoidRootPart")
   local Humanoid = Character:WaitForChild("Humanoid")

   -- Create BodyVelocity to apply smooth flying
   local BodyVelocity = Instance.new("BodyVelocity")
   BodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
   BodyVelocity.Velocity = Vector3.zero
   BodyVelocity.Parent = RootPart

   -- Flying mechanics based on the Infinite Yield script
   local flying = true
   local speed = FlySpeed
   local direction = Vector3.zero
   local bodyGyro = Instance.new("BodyGyro")
   bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
   bodyGyro.CFrame = RootPart.CFrame
   bodyGyro.Parent = RootPart

   -- Function to update flying direction and speed
   local function updateFly()
      local moveDirection = Vector3.zero
      if Input:IsKeyDown(Enum.KeyCode.W) then
         moveDirection = moveDirection + Camera.CFrame.LookVector
      end
      if Input:IsKeyDown(Enum.KeyCode.S) then
         moveDirection = moveDirection - Camera.CFrame.LookVector
      end
      if Input:IsKeyDown(Enum.KeyCode.A) then
         moveDirection = moveDirection - Camera.CFrame.RightVector
      end
      if Input:IsKeyDown(Enum.KeyCode.D) then
         moveDirection = moveDirection + Camera.CFrame.RightVector
      end
      if Input:IsKeyDown(Enum.KeyCode.Space) then
         moveDirection = moveDirection + Vector3.new(0, 1, 0)
      end
      if Input:IsKeyDown(Enum.KeyCode.LeftControl) then
         moveDirection = moveDirection - Vector3.new(0, 1, 0)
      end
      if Input:IsKeyDown(Enum.KeyCode.Q) then
         moveDirection = moveDirection - Vector3.new(0, DescendSpeed, 0)  -- Descent
      end
      if Input:IsKeyDown(Enum.KeyCode.E) then
         moveDirection = moveDirection + Vector3.new(0, AscendSpeed, 0)  -- Ascend
      end

      BodyVelocity.Velocity = moveDirection * speed
      bodyGyro.CFrame = RootPart.CFrame
   end

   -- Loop to apply continuous fly force
   local flyingLoop = RunService.RenderStepped:Connect(function()
      if flying then
         updateFly()
      end
   end)

   -- Stop flying function
   local function stopFlying()
      flying = false
      BodyVelocity:Destroy()
      bodyGyro:Destroy()
      flyingLoop:Disconnect()
   end

   -- Toggle flying state
   FlyEnabled = true
   Input.InputBegan:Connect(function(input)
      if input.KeyCode == Enum.KeyCode.Space and FlyEnabled then
         stopFlying()
      end
   end)
end

-- Fly Toggle
local function stopFly()
   FlyEnabled = false
end

-- NoClip Logic
local function enableNoClip()
   local Character = Player.Character or Player.CharacterAdded:Wait()
   local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

   -- Disable collisions
   Character:FindFirstChildOfClass("Humanoid").PlatformStand = true
   HumanoidRootPart.CanCollide = false

   -- Keep updating the position so the character passes through walls
   local function updateNoClip()
      if NoClipEnabled then
         for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
               part.CanCollide = false
            end
         end
      end
   end

   -- Loop to check and update
   local noClipLoop = RunService.RenderStepped:Connect(updateNoClip)

   -- Reset collisions when NoClip is turned off
   local function disableNoClip()
      NoClipEnabled = false
      for _, part in pairs(Character:GetChildren()) do
         if part:IsA("BasePart") then
            part.CanCollide = true
         end
      end
      Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
      noClipLoop:Disconnect()
   end

   -- Toggle NoClip
   Input.InputBegan:Connect(function(input)
      if input.KeyCode == Enum.KeyCode.N and NoClipEnabled then
         disableNoClip()
      elseif input.KeyCode == Enum.KeyCode.N and not NoClipEnabled then
         enableNoClip()
      end
   end)
end

-- UI Elements
MainTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfiniteJumpToggle",
   Callback = function(Value)
      InfiniteJumpEnabled = Value
      if Value then
         enableInfiniteJump()
      end
   end,
})

MainTab:CreateSlider({
   Name = "Walk Speed",
   Range = {16, 100},
   Increment = 5,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "WalkSpeedSlider",
   Callback = function(Value)
      WalkSpeed = Value
      local Character = Player.Character or Player.CharacterAdded:Wait()
      local Humanoid = Character:FindFirstChildOfClass("Humanoid")
      if Humanoid then
         Humanoid.WalkSpeed = Value
      end
   end,
})

MainTab:CreateToggle({
   Name = "Fly (Infinite Yield Style)",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      FlyEnabled = Value
      if Value then
         startFly()
      else
         stopFly()
      end
   end,
})

MainTab:CreateSlider({
   Name = "Fly Speed",
   Range = {20, 200},
   Increment = 10,
   Suffix = "Speed",
   CurrentValue = 50,
   Flag = "FlySpeedSlider",
   Callback = function(Value)
      FlySpeed = ValueA
   end,
})

MainTab:CreateToggle({
   Name = "No Clip",
   CurrentValue = false,
   Flag = "NoClipToggle",
   Callback = function(Value)
      NoClipEnabled = Value
      if Value then
         enableNoClip()
      else
         disableNoClip()
      end
   end,
})
