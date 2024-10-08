local M = {}
M.register = ""
M.plugin_name = "regtee"
M.config = {}
M.config_defaults = {
	enabled = true,
}

-- Start/stop
local function set_register(opts)
	local register = opts.fargs[1] or ""
	if #register > 1 or #register == 1 and not string.match(register, "%a") then
		vim.notify("Regtee: register must be one of [a-zA-Z]", vim.log.levels.ERROR)
		return
	end
	if register == "" then
		if M.register ~= "" then
			vim.notify("Stop tee @" .. M.register, vim.log.levels.INFO)
			M.register = ""
			return
		end
	elseif string.match(register, "%u") then
		vim.notify("Append tee @" .. register, vim.log.levels.INFO)
		M.register = string.lower(register)
	else
		vim.notify("Start tee @" .. register, vim.log.levels.INFO)
		M.register = register
		vim.fn.setreg(register, "")
	end
end

-- Copy the yanked text to the sticky register
local function tee()
	local ev = vim.v.event
	if M.register == "" or ev.operator ~= "y" or ev.regname ~= "" then
		return
	end
	local lines = ev.regcontents
	-- withouth this fix, the last empty line is treated as a literal \n
	if lines[#lines] == "" then
		lines[#lines] = "\n"
	end
	vim.fn.setreg(M.register, table.concat(lines, "\n"), "a" .. ev.regtype)
end

-- Setup commands
local function setup_commands()
	vim.api.nvim_create_user_command("Regtee", set_register, { nargs = "?" })
end

-- Setup autocommands
local function setup_autocommands()
	if not vim.fn.exists("##TextYankPost") then
		vim.notify("Regtee: autocommand TextYankPost not available", vim.log.levels.ERROR)
		return false
	end
	local group = vim.api.nvim_create_augroup(M.plugin_name, { clear = true })
	vim.api.nvim_create_autocmd("TextYankPost", {
		group = group,
		pattern = { "*" },
		desc = "Copy yanked text to a sticky register",
		callback = tee,
	})
	return true
end

-- Setup config
-- Before falling back to the default value, look for options
-- definied with vimscript (eg via let g:regtee_enabled = v:true)
local function setup_config(config)
	for k, v in pairs(M.config_defaults) do
		if config[k] ~= nil then
			M.config[k] = config[k]
		elseif vim.g[M.plugin_name .. "_" .. k] ~= nil then
			M.config[k] = vim.g[M.plugin_name .. "_" .. k]
		else
			M.config[k] = v
		end
	end
end

M.setup = function(config)
	setup_config(config)
	if not M.config.enabled or not setup_autocommands() then
		return
	end
	setup_commands()
end

return M
