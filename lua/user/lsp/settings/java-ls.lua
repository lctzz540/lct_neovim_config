local on_attach = function(_, bufnr)
    require('jdtls').setup_dap({ hotcodereplace = 'auto' })
    require'jdtls.setup'.add_commands()
    require("configs.lspconfig").on_attach(_, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = { noremap=true, silent=true }
     -- Java specific
    buf_set_keymap("n", "<leader>ji", "<Cmd>lua require'jdtls'.organize_imports()<CR>", opts)
    buf_set_keymap("n", "<leader>jt", "<Cmd>lua require'jdtls'.test_class()<CR>", opts)
    buf_set_keymap("n", "<leader>jn", "<Cmd>lua require'jdtls'.test_nearest_method()<CR>", opts)
    buf_set_keymap("v", "<leader>je", "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", opts)
    buf_set_keymap("n", "<leader>je", "<Cmd>lua require('jdtls').extract_variable()<CR>", opts)
    buf_set_keymap("v", "<leader>jm", "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", opts)

end

local root_markers = {'gradlew', 'pom.xml', '.vscode', '.project'}
local root_dir = require('jdtls.setup').find_root(root_markers)
local home = os.getenv('HOME')

local capabilities = require("configs.lspconfig").capabilities
capabilities.workspace.configuration = true
capabilities.textDocument.completion.completionItem.snippetSupport = false
local workspace_folder = home .. "/.local/workspace/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")
local config = {
    flags = {
        allow_incremental_sync = true,
    };
    capabilities = capabilities,
    on_attach = on_attach,
}

config.settings = {
    -- ['java.format.settings.url'] = home .. "/.local/share/lsp/jdtls/java-google-formatter.xml",
    -- ['java.format.settings.profile'] = "GoogleStyle",
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
                    name = "JavaSE-11",
                    path = home .. "/opt/homebrew/opt/java11/bin/java",
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

config.init_options = {
    extendedClientCapabilities = extendedClientCapabilities;
}
-- Server
require('jdtls').start_or_attach(config)

