--[[
    Classify: Lua Class Generator
    ------------------------------------
    A utility for generating annotated, 
    object-based class definitions.

    Version: 1.0.0
]]--

-- Copyright (c) 2025 @realdotty
-- Licensed under the MIT License. See LICENSE file for details.

CLASSIFY_VERSION = "1.0.0" -- In the future we may need to check the version

local DEFAULT_MAP = {
    ["string"] = "\"<UNKNOWN>\"",
    ["number"] = "0",
    ["integer"] = "0",
    ["boolean"] = "false",
    ["table"] = "{}",
    ["nil"] = "nil"
}

---@param word string
---@return string
local function upperFirst( word )
    return word:sub( 1, 1 ):upper() .. word:sub( 2 )
end

---@class ClassCreator
---@field validClass boolean
---@field className string
---@field classFields table<integer, table<string, string, string>>
---@field classMethods table<integer, table<string, string, string>>
---@field _VERSION string
local ClassCreator = {}
ClassCreator.__index = ClassCreator

---@param ... string
---@return nil
function ClassCreator:_Output( ... )
    print( string.format( ... ) )
end

---@return nil
function ClassCreator:_OutputSpacer()
    print( "" ) -- Nothing
end

---@param fieldName string
---@param fieldType string
---@param defaultValue? string
---@return ClassCreator
function ClassCreator:addField( fieldName, fieldType, defaultValue )
    if not DEFAULT_MAP[fieldType] then
        self.validClass = false
        self:_Output( "Unknown field type \"%s\" was passed to :addField function!", fieldType )
        return self
    end

    table.insert( self.classFields, { fieldName = fieldName, fieldType = fieldType, defaultValue = defaultValue } )
    return self
end

---@param methodName string
---@param returnType string
---@param methodCode string
---@return ClassCreator
function ClassCreator:addMethod( methodName, returnType, methodCode )
    if not DEFAULT_MAP[returnType] then
        self.validClass = false
        self:_Output( "Unknown return type \"%s\" was passed to :addMethod function!", returnType )
        return self
    end

    table.insert( self.classMethods, { methodName = methodName, returnType = returnType, methodCode = methodCode } )
    return self
end

---@return nil
function ClassCreator:build()
    if not self.validClass then
        self:_Output( "A previous problem has prevented the class from being built!" )
        return
    end

    -- Class header
    self:_Output( "---@class %s", self.className )
    
    for _, fieldData in ipairs( self.classFields ) do
        self:_Output( "---@field %s %s", fieldData.fieldName, fieldData.fieldType )
    end

    -- Class definition
    self:_Output( "local %s = {}", self.className )
    self:_Output( "%s.__index = %s", self.className, self.className )
    self:_OutputSpacer()

    -- Setters/Getters
    for _, fieldData in ipairs( self.classFields ) do
        self:_Output( "---@param new%s %s", upperFirst( fieldData.fieldName ), fieldData.fieldType )
        self:_Output( "---@return nil" )
        self:_Output( "function %s:Set%s( new%s )", self.className, upperFirst( fieldData.fieldName ), upperFirst( fieldData.fieldName ) )
        self:_Output( "    self.%s = new%s", fieldData.fieldName, upperFirst( fieldData.fieldName ) )
        self:_Output( "end" )

        self:_OutputSpacer()

        self:_Output( "---@return %s", fieldData.fieldType )
        self:_Output( "function %s:Get%s()", self.className, upperFirst( fieldData.fieldName ) )
        self:_Output( "    return self.%s", fieldData.fieldName )
        self:_Output( "end" )
        self:_OutputSpacer()
    end

    for _, methodData in ipairs( self.classMethods ) do
        self:_Output( "---@return %s", methodData.returnType )
        self:_Output( "function %s:%s()", self.className, methodData.methodName )
        self:_Output( "    " .. methodData.methodCode )
        self:_Output( "end" )
        self:_OutputSpacer()
    end

    -- Class Creator function
    self:_Output( "---@return %s", self.className )
    self:_Output( "function Create%s()", self.className )
    
    local fieldCount = #self.classFields

    if ( fieldCount == 0 ) then
        self:_Output( "    return setmetatable( {}, %s )", self.className )
        self:_Output( "end" )
    else
        self:_Output( "    return setmetatable( {" )
        
        for index = 1, #self.classFields do -- We do a for i loop to avoid the trailing comma
            local fieldData = self.classFields[index]
            local defaultValue = fieldData.defaultValue
            if ( index == fieldCount ) then
                self:_Output( "        %s = %s", fieldData.fieldName, defaultValue or DEFAULT_MAP[fieldData.fieldType] )
            else
                self:_Output( "        %s = %s,", fieldData.fieldName, defaultValue or DEFAULT_MAP[fieldData.fieldType] )
            end
        end

        self:_Output( "    }, %s )", self.className )
        self:_Output( "end" )
    end
end

---@param classname string
---@return ClassCreator
function Classify( classname )
    assert( classname, "No class name has been passed to the Classify function!" )
    return setmetatable( {
        validClass = true,
        className = classname,
        classFields = {},
        classMethods = {},
        _VERSION = CLASSIFY_VERSION -- semver
    }, ClassCreator )
end
