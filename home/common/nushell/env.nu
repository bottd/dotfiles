# version = 0.82.0
$env.PATH = (
  $env.PATH
  | split row (char esep)
  | prepend '~/.cargo/bin'
  | prepend '~/platform-tool'
  | prepend '~/.npm-packages/bin'
  | prepend $"/Users/(whoami | str trim)/.local/bin"
  | prepend '/nix/var/nix/profiles/default/bin'
)

$env.NODE_PATH = '~/.npm-packages/lib/node_modules'

$env.WINDOW_APPEARANCE = try {
  match (term query "\e[?996n" --prefix "\e[?997;" --terminator "n" | decode) {
    "1" => "dark"
    _ => "light"
  }
} catch {
  if ("THEME_PREFERENCE" in $env) {
    $env.THEME_PREFERENCE
  } else {
    "dark"
  }
}

$env.CATPPUCCIN_FLAVOR = match $env.WINDOW_APPEARANCE {
  "dark" => "mocha"
  "light" => "latte"
}

let MACHINE_ENV = $"env.(whoami | str trim).nu"

$env.STARSHIP_SHELL = "nu"

claude config set --global theme $env.WINDOW_APPEARANCE

let starship_dir = ($env.HOME | path join ".config/starship/")
if $env.WINDOW_APPEARANCE == "dark" {
    $env.STARSHIP_CONFIG = ($starship_dir | path join "starship.dark.toml")
} else if $env.WINDOW_APPEARANCE == "light" {
    $env.STARSHIP_CONFIG = ($starship_dir | path join "starship.light.toml")
}

def create_left_prompt [] {
    starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
}

$env.PROMPT_COMMAND = { || create_left_prompt }
$env.PROMPT_INDICATOR = ""
$env.PROMPT_INDICATOR_VI_INSERT = ": "
$env.PROMPT_INDICATOR_VI_NORMAL = "〉"
$env.PROMPT_MULTILINE_INDICATOR = "::: "

def create_right_prompt [] {
    let time_segment_color = (ansi magenta)

    let time_segment = ([
        (ansi reset)
        $time_segment_color
        (date now | format date '%m/%d/%Y %r')
    ] | str join | str replace --all "([/:])" $"(ansi light_magenta_bold)${1}($time_segment_color)" |
        str replace --all "([AP]M)" $"(ansi light_magenta_underline)${1}")

    let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
        (ansi rb)
        ($env.LAST_EXIT_CODE)
    ] | str join)
    } else { "" }

    ([$last_exit_code, (char space), $time_segment] | str join)
}

$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

$env.ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
    to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
    to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
  }
}

$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts')
]

$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins')
]

# Prevents Treesitter parser compilation errors
$env.CXXFLAGS = "-std=c++11"
