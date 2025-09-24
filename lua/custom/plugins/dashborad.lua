return {
  'goolord/alpha-nvim',
  priority = 2000,
  lazy = false,
  dependencies = { 'nvim-tree/nvim-web-devicons', '2kabhishek/utils.nvim' },
  config = function()
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'
    local icons = require('utils.icons').icons
    local datetime = tonumber(os.date ' %H ')
    local stats = require('lazy').stats()
    local total_plugins = stats.count
    local get_header = require 'utils.startpage-headers'

    local function button(sc, txt, keybind, keybind_opts)
      local b = dashboard.button(sc, txt, keybind, keybind_opts)
      b.opts.hl_shortcut = 'MiniIconsPurple'
      return b
    end

    dashboard.section.header.val = get_header(12, false) -- (index, bool) index of ascii art bool if you want random or not eg: (30, false)
    dashboard.section.buttons.val = {
      button('e', icons.ui.new_file .. ' New file', ':ene <BAR> startinsert <CR>'),
      button('f', icons.ui.files .. ' Find Files', ':Telescope find_files <CR>'),
      button('p', icons.git.repo .. ' Find project', "<cmd>lua require('telescope').extensions.projects.projects()<cr>"),
      button('o', icons.ui.restore .. ' Recent Files', '<cmd>Telescope oldfiles<cr>'),
      button('t', icons.kinds.nvchad.Text .. ' Find text', ':Telescope live_grep <CR>'),
      button('c', ' ' .. ' Neovim config', '<cmd>e ~/.config/nvim/ | cd %:p:h<cr>'),
      button('l', '󰒲  Lazy', '<cmd>Lazy<cr>'),
      button('q', icons.ui.close .. ' Quit NVIM', ':qa<CR>'),
    }

    local function footer()
      local footer_datetime = os.date '  %m-%d-%Y   %H:%M:%S'
      local version = vim.version()
      local nvim_version_info = '   v' .. version.major .. '.' .. version.minor .. '.' .. version.patch
      local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
      local value = footer_datetime .. '   Plugins ' .. total_plugins .. nvim_version_info
      return value
    end
    dashboard.section.footer.val = footer()

    local greeting = function()
      -- Determine the appropriate greeting based on the hour
      local mesg
      local username = 'ffw'
      if datetime >= 0 and datetime < 6 then
        mesg = 'Dreaming..󰒲 󰒲 '
      elseif datetime >= 6 and datetime < 12 then
        mesg = '🌅 Hi ' .. username .. ', Good Morning ☀️'
      elseif datetime >= 12 and datetime < 18 then
        mesg = '🌞 Hi ' .. username .. ', Good Afternoon ☕️'
      elseif datetime >= 18 and datetime < 21 then
        mesg = '🌆 Hi ' .. username .. ', Good Evening 🌙'
      else
        mesg = 'Hi ' .. username .. ", it's getting late, get some sleep 😴"
      end
      return mesg
    end

    local bottom_section = {
      type = 'text',
      val = greeting,
      opts = {
        position = 'center',
      },
    }

    local section = {
      header = dashboard.section.header,
      bottom_section = bottom_section,
      buttons = dashboard.section.buttons,
      footer = dashboard.section.footer,
    }

    local opts = {
      layout = {
        { type = 'padding', val = 1 },
        section.header,
        { type = 'padding', val = 2 },
        section.buttons,
        { type = 'padding', val = 1 },
        section.bottom_section,
        { type = 'padding', val = 1 },
        section.footer,
      },
    }
    dashboard.opts.opts.noautocmd = true

    -- close Lazy and re-open when the dashboard is ready
    if vim.o.filetype == 'lazy' then
      vim.cmd.close()
      vim.api.nvim_create_autocmd('User', {
        once = true,
        pattern = 'AlphaReady',
        callback = function()
          require('lazy').show()
        end,
      })
    end

    alpha.setup(opts)

    -- don't show status line in alpha dashboard
    vim.api.nvim_create_autocmd({ 'User' }, {
      pattern = { 'AlphaReady' },
      callback = function()
        vim.cmd [[ set laststatus=0 | autocmd BufUnload <buffer> set laststatus=3 ]]
      end,
    })
  end,
}
