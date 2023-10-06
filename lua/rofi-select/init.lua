local M = {}

local default_opts = {
	rofi = "rofi",
	additional_args = nil,
	sep = '\n'
}

function M.setup(opts)
	opts = opts or {}
	for k, v in pairs(default_opts) do
		opts[k] = v or default_opts[k]
	end

	---@diagnostic disable-next-line: duplicate-set-field
	vim.ui.select = function(items, select_opts, on_choice)
		if select_opts.prompt:sub(-1) == ":" then
			select_opts.prompt = select_opts.prompt:sub(0, -2)
		end

		local cmd = { opts.rofi, "-dmenu", "-sep", opts.sep, "-p", select_opts.prompt, "-format", "d" }

		if type(opts.additional_args) == "table" then
			for _, v in pairs(opts.additional_args) do
				table.insert(cmd, v)
			end
		elseif type(opts.additional_args) == "function" then
			for _, v in pairs(opts.additional_args()) do
				table.insert(cmd, v)
			end
		end

		local formatted = "";
		for _, item in pairs(items) do
			formatted = formatted .. select_opts.format_item(item) .. opts.sep
		end
		vim.system(cmd, { stdin = formatted, text = true },
			vim.schedule_wrap(function(completed)
				if (completed.code ~= 0) then
					on_choice(nil, nil)
				else
					local index = tonumber(completed.stdout)
					on_choice(items[index], index)
				end
			end)
		)
	end
end

return M
