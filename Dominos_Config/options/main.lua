local AddonName, Addon = ...
local ParentAddonName = GetAddOnDependencies(AddonName)
local ParentAddon = LibStub("AceAddon-3.0"):GetAddon(ParentAddonName)

local function createMainPanel()
    local frame = CreateFrame("Frame", nil, InterfaceOptionsFrame)
    frame.name = ParentAddonName
    frame.children = {}
    frame:Hide()

    frame:SetScript(
        "OnShow",
        function()
            local _, child = next(frame.children)

            if child then
                InterfaceOptionsFrame_OpenToCategory(child)
            end
        end
    )

    InterfaceOptions_AddCategory(frame)

    return frame
end

function Addon:Initialize()
    self:OnInitialize()

    -- setup the main options panel
    self.frame = createMainPanel()

    -- register ace config options
    LibStub("AceConfig-3.0"):RegisterOptionsTable(
        ParentAddonName,
        function()
            local options = {
                type = "group",
                name = ParentAddonName,
                args = {}
            }

            for _, panel in self:GetOptionsPanels() do
                if panel.options then
                    options.args[panel.key] = panel.options
                end
            end

            return options
        end
    )

    -- build options panels
    for _, panel in self:GetOptionsPanels() do
        local frame = panel.frame

        if not frame then
            frame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(
                self.frame.name,
                panel.options.name,
                self.frame.name,
                panel.key
            )
        end

        tinsert(self.frame.children, frame)
    end

    self:OnInitialized()
end

function Addon:ShowAddonPanel()
    self:Initialize()
    self:ShowMainOptionsPanel()
    self.ShowAddonPanel = self.ShowMainOptionsPanel
end

-- todo, fire callbacks
function Addon:OnInitialize()
    ParentAddon.callbacks:Fire("OPTIONS_MENU_LOADING")
end

function Addon:OnInitialized()
    ParentAddon.callbacks:Fire("OPTIONS_MENU_LOADED")
end

function Addon:ShowMainOptionsPanel()
    if not InterfaceOptionsFrame:IsShown() then
        InterfaceOptionsFrame_Show()
    end

    InterfaceOptionsFrame_OpenToCategory(self.frame)
end

-- export
ParentAddon.Options = Addon