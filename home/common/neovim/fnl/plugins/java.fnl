(local java (require :java))

(java.setup {:jdk {:auto_install false} :spring_boot_tools {:enable false}})

(vim.lsp.enable :jdtls)
