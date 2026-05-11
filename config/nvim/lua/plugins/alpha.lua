vim.pack.add({
	{ src = "https://github.com/goolord/alpha-nvim" },
})

local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

local header_art = vim.split([[

                                     d88b
                     _______________|8888|_______________
                    |_____________ ,~~~~~~. _____________|
  _________         |_____________: mmmmmm :_____________|         _________
 / _______ \   ,----|~~~~~~~~~~~,'\ _...._ /`.~~~~~~~~~~~|----,   / _______ \
| /       \ |  |    |       |____|,d~    ~b.|____|       |    |  | /       \ |
||         |-------------------\-d.-~~~~~~-.b-/-------------------|         ||
||         | |8888 ....... _,===~/......... \~===._         8888| |         ||
||         |=========_,===~~======._.=~~=._.======~~===._=========|         ||
||         | |888===~~ ...... //,, .`~~~~'. .,\\        ~~===888| |         ||
||        |===================,P'.::::::::.. `?,===================|        ||
||        |_________________,P'_::----------.._`?,_________________|        ||
`|        |-------------------~~~~~~~~~~~~~~~~~~-------------------|        |'
  \_______/                                              _ wh.l _  \_______/

]],
    "\n",
    {}
)

dashboard.section.header.val = header_art 

dashboard.section.buttons.val = {
	dashboard.button("e", "  Explore", ":Oil .<CR>"),
	dashboard.button("f", "󰮗  Find file", ":Pick files<CR>"),
	dashboard.button("u", "󰏗  Plugins", ":Pack<CR>"),
	dashboard.button("h", "  Dotfiles", ":e ~/.config/nvim<CR>"),
	dashboard.button("m", "󰏗  Mason", ":Mason<CR>"),
	dashboard.button("q", "󰈆  Quit Nvim", ":qa<CR>"),
}

local datetime = os.date("󱑂 %Y-%m-%d  %H:%M %A")
local function get_greeting()
	local hour = tonumber(os.date("%H"))
	if hour < 12 then
		return "󰖔 Good Morning"
	elseif hour < 18 then
		return "󰖙 Good Afternoon"
	else
		return "󰖔 Good Evening"
	end
end
local greeting = get_greeting() .. "  |  " .. datetime

dashboard.section.footer.val = greeting
dashboard.section.footer.opts.position = "center"
dashboard.section.footer.opts.hl = "gruvbox-material"

dashboard.config.layout = {
	{ type = "padding", val = 2 },
	dashboard.section.header,
	{ type = "padding", val = 1 },
	{ type = "padding", val = 2 },
	dashboard.section.buttons,
	dashboard.section.footer,
}

alpha.setup(dashboard.config)

vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
