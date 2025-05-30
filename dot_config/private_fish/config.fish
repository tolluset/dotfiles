# alias
alias sz='source ~/.zshrc'
alias cf='n ~/.config/fish/config.fish'

alias python='python3'
alias py='python3'
alias pip='pip3'
alias pvs='py -m venv .venv'
alias pv='set -g VIRTUAL_ENV .venv'

alias g='git'
alias gt='serie'
alias h='history'
alias dk='docker'
alias dc='docker compose'
alias p='pnpm'
alias pi='pnpm install'
alias ps='pnpm start'
alias psm='pnpm start:mock'
alias psd='pnpm start:demo'
alias px='pnpx'
alias vt='npx vitest'

alias as="source (which awsume.fish)"

#function as
#    . awsume $argv
#end

#function awsume
#    bass source (which awsume) $argv
#end

alias a="aws"
alias gs='git status'
alias y='yarn'
alias n='nvim'
alias b='bun'
alias f='flutter'
alias pr='proto'

alias fz='fzf'
alias fk='fuck'

function gb
    set -g BASE (git rev-parse --abbrev-ref @{-1})
    echo $BASE
end

function ghpc
    gb
    gh pr create --web -a @me -B $BASE
end

alias avt='av tree'
alias avn='av next'
alias anp='av prev'
alias avr='av reparent'
alias avb='av branch'

alias c='chamgo'

# local
fish_add_path ~/.local/bin

# homebrew
fish_add_path /opt/homebrew/bin

# pnpm
set -gx PNPM_HOME ~/Library/pnpm
fish_add_path $PNPM_HOME

# rust
fish_add_path ~/.cargo/bin

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# cargo 별칭 설정
function ca --description "cargo 별칭"
    cargo $argv
end

function car --description "cargo run 별칭"
    cargo run $argv
end

function cab --description "cargo build 별칭"
    cargo build $argv
end

function cac --description "cargo check 별칭"
    cargo check $argv
end

function caa --description "cargo add 별칭"
    cargo add $argv
end

# AWS 및 Claude 설정
set -x AWS_REGION us-east-1
set -x CLAUDE_CODE_USE_BEDROCK 1
set -x DISABLE_PROMPT_CACHING 1
set -x ANTHROPIC_MODEL 'us.anthropic.claude-3-7-sonnet-20250219-v1:0'

set -gx ATUIN_SESSION (atuin uuid)
set --erase ATUIN_HISTORY_ID

function _atuin_preexec --on-event fish_preexec
    if not test -n "$fish_private_mode"
        set -g ATUIN_HISTORY_ID (atuin history start -- "$argv[1]")
    end
end

function _atuin_postexec --on-event fish_postexec
    set -l s $status

    if test -n "$ATUIN_HISTORY_ID"
        ATUIN_LOG=error atuin history end --exit $s -- $ATUIN_HISTORY_ID &>/dev/null &
        disown
    end

    set --erase ATUIN_HISTORY_ID
end

function _atuin_search
    set -l keymap_mode
    switch $fish_key_bindings
        case fish_vi_key_bindings
            switch $fish_bind_mode
                case default
                    set keymap_mode vim-normal
                case insert
                    set keymap_mode vim-insert
            end
        case '*'
            set keymap_mode emacs
    end

    # In fish 3.4 and above we can use `"$(some command)"` to keep multiple lines separate;
    # but to support fish 3.3 we need to use `(some command | string collect)`.
    # https://fishshell.com/docs/current/relnotes.html#id24 (fish 3.4 "Notable improvements and fixes")
    set -l ATUIN_H (ATUIN_SHELL_FISH=t ATUIN_LOG=error atuin search --keymap-mode=$keymap_mode $argv -i -- (commandline -b) 3>&1 1>&2 2>&3 | string collect)

    if test -n "$ATUIN_H"
        if string match --quiet '__atuin_accept__:*' "$ATUIN_H"
            set -l ATUIN_HIST (string replace "__atuin_accept__:" "" -- "$ATUIN_H" | string collect)
            commandline -r "$ATUIN_HIST"
            commandline -f repaint
            commandline -f execute
            return
        else
            commandline -r "$ATUIN_H"
        end
    end

    commandline -f repaint
end

function _atuin_bind_up
    # Fallback to fish's builtin up-or-search if we're in search or paging mode
    if commandline --search-mode; or commandline --paging-mode
        up-or-search
        return
    end

    # Only invoke atuin if we're on the top line of the command
    set -l lineno (commandline --line)

    switch $lineno
        case 1
            _atuin_search --shell-up-key-binding
        case '*'
            up-or-search
    end
end

bind \cr _atuin_search
bind -k up _atuin_bind_up
bind \eOA _atuin_bind_up
bind \e\[A _atuin_bind_up
if bind -M insert >/dev/null 2>&1
    bind -M insert \cr _atuin_search
    bind -M insert -k up _atuin_bind_up
    bind -M insert \eOA _atuin_bind_up
    bind -M insert \e\[A _atuin_bind_up
end
