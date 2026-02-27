require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "ts_ls", "svelte", "roslyn_ls", "pyright" }
vim.lsp.enable(servers)

vim.lsp.config('roslyn_ls', {
  cmd = {
    'dotnet',
    vim.fs.joinpath(vim.env.CLI_CONFIG_ROOT, 'current/path/Microsoft.CodeAnalysis.LanguageServer.osx-arm64.5.4.0-2.26080.13.nupkg/content/LanguageServer/osx-arm64/Microsoft.CodeAnalysis.LanguageServer.dll'),
    '--logLevel',
    'Information',
    '--extensionLogDirectory',
    vim.fs.joinpath(vim.uv.os_tmpdir(), 'roslyn_ls/logs'),
    '--stdio'
  }
})

-- read :h vim.lsp.config for changing options of lsp servers 

