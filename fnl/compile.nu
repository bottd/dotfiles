ls wezterm/**/*.fnl | each {|file| 
  let lua_file = $"~/.config/($file.name)" | str replace '.fnl' '.lua'
  print $"Compiling ($file.name) to ($lua_file)"
  fennel --compile $file.name | save -f $lua_file
}
