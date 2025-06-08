--- https://github.com/1bardesign/batteries/blob/master/tablex.lua

--[[
	extra table routines
]]

local path = (...):gsub("tablex", "")
local assert = require(path .. "assert")


--apply prototype to module if it isn't the global table
--so it works "as if" it was the global table api
--upgraded with these routines
local tablex = setmetatable({}, {
	__index = table,
})

--alias
tablex.join = tablex.concat

--alias
tablex.copy = tablex.shallow_copy

--implementation for deep copy
--traces stuff that has already been copied, to handle circular references
local function _deep_copy_impl(t, already_copied)
	local clone = t
	if type(t) == "table" then
		if already_copied[t] then
			--something we've already encountered before
			clone = already_copied[t]
		elseif type(t.copy) == "function" then
			--something that provides its own copy function
			clone = t:copy()
			assert:type(clone, "table", "member copy() function didn't return a copy")
		else
			--a plain table to clone
			clone = {}
			already_copied[t] = clone
			for k, v in pairs(t) do
				clone[k] = _deep_copy_impl(v, already_copied)
			end
			setmetatable(clone, getmetatable(t))
		end
	end
	return clone
end

-- Recursively copy values of a table.
-- Retains the same keys as original table -- they're not cloned.
function tablex.deep_copy(t)
	assert:type(t, "table", "tablex.deep_copy - t", 1)
	return _deep_copy_impl(t, {})
end


return tablex