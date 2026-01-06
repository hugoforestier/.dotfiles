set fish_greeting ""
set -U fish_prompt_pwd_dir_length 0

abbr "g" "git"
abbr "gga" "gg amend"
abbr "ggc" "gg commit"
abbr "gl" "git log"
abbr "gp" "git push"
abbr "gpf" "git push --force-with-lease"
abbr "gs" "git status"
abbr "gup" "git pull --rebase"
abbr "gr" "./zig/zig build git-review --"
abbr "ls" "eza -lb"
abbr "sw" "gg switch"
abbr "swr" "gg switch --remote"
abbr "swd" "git switch --detach"
abbr "vim" "nvim"
abbr "vimconf" "nvim ~/.config/nvim/"

bind \cf 'tmux-sessionizer; commandline -f repaint'

fish_config theme choose termcolors


if status is-interactive
    # Commands to run in interactive sessions can go here
end

# opencode
fish_add_path /home/hugoforestier/.opencode/bin
set -x OTEL_PHP_AUTOLOAD_ENABLED false

source ~/.azssh/azssh/azssh.fish
source ~/.azssh/azssh/azssh_autocomplete.fish
source ~/.azssh/azssh/update_vms_list.fish
