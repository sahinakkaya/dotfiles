local on_attach = function(client, bufr)
    -- require('jdtls').setup_dap()
    require'lsp'.common_on_attach(client, bufr)
end

require'lspconfig'.jdtls.setup {
    on_attach = on_attach,
    cmd = {DATA_PATH .. "/lspinstall/java/jdtls.sh"},
    filetypes = { "java" },
    root_dir = util.root_pattern({'.git', 'build.gradle', 'pom.xml'}),
    -- init_options = {bundles = bundles}
    -- on_attach = require'lsp'.common_on_attach
}
