# Nushell Environment Config File
#
# version = 0.82.0

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# let-env PATH = ($env.PATH | split row (char esep) | prepend '/some/path')
$env.PATH = (
  $env.PATH
  | split row (char esep)
  | prepend '/opt/homebrew/bin'
  | prepend '~/.cargo/bin'
#  | prepend '/Applications/calibre.app/Contents/MacOS'
  | prepend '~/platform-tool'
  | prepend $"/Users/(whoami | str trim)/.local/bin"
  | prepend '~/.volta/bin'
  | prepend '/nix/var/nix/profiles/default/bin'
)

let MACHINE_ENV = $"env.(whoami | str trim).nu"

$env.STARSHIP_SHELL = "nu"

let starship_dir = ($env.HOME | path join ".config/starship/")
if $env.WINDOW_APPEARANCE == "dark" {
    $env.STARSHIP_CONFIG = ($starship_dir | path join "starship.dark.toml")
} else if $env.WINDOW_APPEARANCE == "light" {
    $env.STARSHIP_CONFIG = ($starship_dir | path join "starship.light.toml")
}

def create_left_prompt [] {
    starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
}

# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = { || create_left_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
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

# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
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

# Directories to search for scripts when calling source or use
#
# By default, <nushell-config-dir>/scripts is added
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts')
]

# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins')
]

# Source local.env.nu for untracked, per-machine env variables
const some_path = $nu.default-config-dir
source-env $"($some_path)/local.env.nu"

# CXXFLAGS needed to avoid Treesitter parser compilation errors
$env.CXXFLAGS = "-std=c++11"
