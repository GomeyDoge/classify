Classify( "Account" )
	:addField( "balance", "number" )
	:addField( "name", "string" )
:build()

-- Outputs --

--[[

---@class Account
---@field balance number
---@field name string
local Account = {}
Account.__index = Account

---@param newBalance number
---@return nil
function Account:SetBalance( newBalance )
    self.balance = newBalance
end

---@return number
function Account:GetBalance()
    return self.balance
end

---@param newName string
---@return nil
function Account:SetName( newName )
    self.name = newName
end

---@return string
function Account:GetName()
    return self.name
end

---@return Account
function CreateAccount()
    return setmetatable( {
        balance = 0,
        name = "<UNKNOWN>"
    }, Account )
end

]]--