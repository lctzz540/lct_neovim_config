local jdtls_on_attach = function(_, bufnr)
  require('jdtls').setup_dap({ hotcodereplace = 'auto' })
  require'jdtls.setup'.add_commands()
  require("user.lsp.handlers").on_attach(_, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

   -- Mappings.
  local opts = { noremap=true, silent=true }
   -- Java specific
  buf_set_keymap("n", "<leader>di", "<Cmd>lua require'jdtls'.organize_imports()<CR>", opts)
  buf_set_keymap("n", "<leader>dt", "<Cmd>lua require'jdtls'.test_class()<CR>", opts)
  buf_set_keymap("n", "<leader>dn", "<Cmd>lua require'jdtls'.test_nearest_method()<CR>", opts)
  buf_set_keymap("v", "<leader>de", "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", opts)
  buf_set_keymap("n", "<leader>de", "<Cmd>lua require('jdtls').extract_variable()<CR>", opts)
  buf_set_keymap("v", "<leader>dm", "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", opts)

end

local home = os.getenv('HOME')
local root_markers = {'gradlew', 'pom.xml', '.vscode', '.project'}
local root_dir = require('jdtls.setup').find_root(root_markers)

require("lua.user.handlers").capabilities.workspace.configuration = true
local workspace_folder = home .. "/.local/workspace/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")
local config = {
    flags = {
      allow_incremental_sync = true,
    };
    capabilities = require("user.lsp.handlers").capabilities,
    on_attach = jdtls_on_attach,
}

config.settings = {
    java = {
      signatureHelp = { enabled = true };
      contentProvider = { preferred = 'fernflower' };
      completion = {
        favoriteStaticMembers = {
          "org.hamcrest.MatcherAssert.assertThat",
          "org.hamcrest.Matchers.*",
          "org.hamcrest.CoreMatchers.*",
          "org.junit.jupiter.api.Assertions.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
          "org.mockito.Mockito.*"
        }
      };
      sources = {
        organizeImports = {
          starThreshold = 9999;
          staticStarThreshold = 9999;
        };
      };
      codeGeneration = {
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
        }
      };
      configuration = {
        runtimes = {
          {
            name = "JavaSE-17",
            -- Edit JavaRuntime here. (home is $HOME)
            path = home .. "/Java/jdk-17.0.1",
          },
        }
      };
    };
}
config.cmd = {'java-lsp', workspace_folder}
config.on_init = function(client, _)
    client.notify('workspace/didChangeConfiguration', { settings = config.settings })
end
local extendedClientCapabilities = require'jdtls'.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
-- local bundles = {
--         vim.fn.glob("~/.vscode-oss/extensions/vscjava.vscode-java-debug-0.37.0/server/com.microsoft.java.debug.plugin-*.jar"),
-- };
-- vim.list_extend(bundles, vim.split(vim.fn.glob("~/.vscode-oss/extensions/vscjava.vscode-java-test-0.33.0/server/*.jar"), "\n"))

config.init_options = {
    extendedClientCapabilities = extendedClientCapabilities;
    -- bundles = bundles;
}

-- Server
require('jdtls').start_or_attach(config)
