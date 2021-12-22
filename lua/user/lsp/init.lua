local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end

require "user.lsp.lsp-installer"
require("user.lsp.handlers").setup()
require "user.lsp.null-ls"

vim.api.nvim_exec( [[
        augroup jdtls_lsp
        autocmd!
        autocmd FileType java lua require("user.lsp.settings.java-ls")
        augroup end
]], true)

