local metals = require("metals")
local metals_config = metals.bare_config()
metals_config.settings = {
  showImplicitArguments = true,
}
metals_config.init_options.statusBarProvider = "on"
metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()
metals.initialize_or_attach(metals_config)
