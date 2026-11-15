-- debug.lua
--
-- Debugger (DAP) para Python, C/C++/Rust, JavaScript/TypeScript, C# y Go.
--
-- Uso rápido:
--   <leader>db  poner/quitar breakpoint        <leader>dc / F5  iniciar o continuar
--   <leader>do  step over   <leader>di  step into   <leader>dO  step out
--   <leader>dt  terminar    <leader>du  abrir/cerrar la UI   <leader>dl  repetir la última sesión
--   <leader>dT  (Go) depurar el test bajo el cursor
--
-- Los adaptadores se instalan con Mason. Go solo se configura si `go` está instalado.

local have_go = vim.fn.executable 'go' == 1

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
  },
  keys = {
    -- Teclas F (ojo: xfce4-terminal se queda con F1 para su ayuda, usa <leader>di)
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F1>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<F2>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>b',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>B',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Set Breakpoint',
    },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    {
      '<F7>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: See last session result.',
    },

    -- Mismas acciones bajo <leader>d (funcionan en cualquier terminal)
    { '<leader>dc', function() require('dap').continue() end, desc = '[C]ontinue / start' },
    { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Toggle [B]reakpoint' },
    { '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, desc = 'Conditional [B]reakpoint' },
    { '<leader>do', function() require('dap').step_over() end, desc = 'Step [O]ver' },
    { '<leader>di', function() require('dap').step_into() end, desc = 'Step [I]nto' },
    { '<leader>dO', function() require('dap').step_out() end, desc = 'Step [O]ut' },
    { '<leader>dC', function() require('dap').run_to_cursor() end, desc = 'Run to [C]ursor' },
    { '<leader>dl', function() require('dap').run_last() end, desc = 'Run [L]ast' },
    { '<leader>dt', function() require('dap').terminate() end, desc = '[T]erminate' },
    { '<leader>du', function() require('dapui').toggle() end, desc = 'Toggle [U]I' },
    { '<leader>de', function() require('dapui').eval() end, desc = '[E]valuate expression', mode = { 'n', 'v' } },

    -- Go: depurar solo el test que está bajo el cursor
    {
      '<leader>dT',
      function()
        if not have_go then
          vim.notify('Go no está instalado (sudo dnf install golang)', vim.log.levels.WARN)
          return
        end
        require('dap-go').debug_test()
      end,
      desc = 'Debug Go [T]est under cursor',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    local adapters = {
      'python', -- debugpy
      'codelldb', -- C, C++, Rust
      'js', -- js-debug-adapter (configurado más abajo)
      'coreclr', -- netcoredbg (C#, necesita el SDK de .NET para compilar)
    }
    if have_go then
      table.insert(adapters, 'delve')
    end

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      ensure_installed = adapters,
    }

    -- JavaScript / TypeScript (Node.js). mason-nvim-dap instala js-debug-adapter
    -- pero no lo configura. Node >= 22.18 ejecuta .ts directamente.
    dap.adapters['pwa-node'] = {
      type = 'server',
      host = 'localhost',
      port = '${port}',
      executable = { command = 'js-debug-adapter', args = { '${port}' } },
    }
    for _, ft in ipairs { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' } do
      dap.configurations[ft] = {
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Node: Launch file',
          program = '${file}',
          cwd = '${workspaceFolder}',
          sourceMaps = true,
        },
        {
          type = 'pwa-node',
          request = 'attach',
          name = 'Node: Attach to process (node --inspect)',
          processId = require('dap.utils').pick_process,
          cwd = '${workspaceFolder}',
        },
      }
    end

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Breakpoints de color en la columna de signos
    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    local breakpoint_icons = vim.g.have_nerd_font
        and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
      or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    for type, icon in pairs(breakpoint_icons) do
      local tp = 'Dap' .. type
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config (solo si Go está instalado)
    if have_go then
      require('dap-go').setup {
        delve = {
          -- On Windows delve must be run attached or it crashes.
          -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
          detached = vim.fn.has 'win32' == 0,
        },
      }
    end
  end,
}
