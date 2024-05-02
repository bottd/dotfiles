{
  1 :dustinblackman/oatmeal.nvim
  :cmd [:Oatmeal]
  :keys [
    {
      1 :<leader>om
      :mode "n"
      :desc "Start Oatmeal Session"
    }
  ]
  :opts {
    :backened "ollama"
    :model "mistral:latest"
  }
}
