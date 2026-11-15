-- Resolver conflictos de merge dentro del buffer (estilo VS Code).
--
-- Solo en archivos con conflictos:
--   co  elegir ours (lo tuyo)        ct  elegir theirs (lo que entra)
--   cb  elegir ambos                 c0  no elegir ninguno
--   ]x  siguiente conflicto          [x  conflicto anterior
--   :GitConflictListQf  lista todos los conflictos del repo en la quickfix
return {
  'akinsho/git-conflict.nvim',
  version = '*',
  -- Se carga al arrancar: el plugin busca los archivos con conflictos en el evento VimEnter.
  -- Con carga perezosa se lo perdía y `nvim` + :GitConflictListQf salía vacío.
  -- Es pequeño y la búsqueda es un `git diff` asíncrono, no frena el arranque.
  lazy = false,
  config = function()
    -- No usamos `disable_diagnostics = true`: llama a vim.diagnostic.disable(),
    -- que ya no existe en Neovim 0.12. Lo hacemos aquí con la API nueva.
    require('git-conflict').setup()

    local group = vim.api.nvim_create_augroup('custom-git-conflict', { clear = true })
    -- Oculta errores del LSP mientras hay marcadores <<<<<<< en el archivo
    vim.api.nvim_create_autocmd('User', {
      group = group,
      pattern = 'GitConflictDetected',
      callback = function(args)
        vim.diagnostic.enable(false, { bufnr = args.buf })
      end,
    })
    vim.api.nvim_create_autocmd('User', {
      group = group,
      pattern = 'GitConflictResolved',
      callback = function(args)
        vim.diagnostic.enable(true, { bufnr = args.buf })
      end,
    })
  end,
}
