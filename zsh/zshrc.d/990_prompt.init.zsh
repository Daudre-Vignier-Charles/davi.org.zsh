#!/usr/bin/zsh

(){
    # BEGIN LOGIN MSG SECTION
    # In zshrc, login message is launched as job
    # We need the prompt not to appear while the login message is printed,
    # Then we run the prompt only when the job run is finished.
    if $LOGIN_MSG ; then
        wait $LOGIN_MSG_PID
        setopt monitor
        unset LOGIN_MSG_PID
    fi
    # END LOGIN MSG SECTION

    # Nice prompt based on Adam2
    # It display :
    # LINE 1 LEFT   : relative path
    # LINE 1 RIGHT  : date, tty, shlvl, user@host
    # LINE 2        : return of the last command, time of the last command
    prompt_davi_configure(){
        unsetopt histexpand
        autoload -U add-zsh-hook
        autoload -U colors
        colors
    }

    prompt_davi_setup(){
        prompt_davi_configure
        local CHAR_LPAREN="%B%F{black}("
        local CHAR_RPAREN="%B%F{black})"
        local CHAR_SEP="%b%F{cyan}-"

        local PROMPT_JOB="$CHAR_LPAREN%B%F{cyan}%j$CHAR_RPAREN"
        local PROMPT_DIR="$CHAR_LPAREN%B%F{green}%~$CHAR_RPAREN"
        local PROMPT_USER="%b%F{cyan}%n"
        local PROMPT_AT="%B%F{cyan}@"
        local PROMPT_HOST="%b%F{cyan}%m"
        local PROMPT_ID="$CHAR_LPAREN$PROMPT_USER$PROMPT_AT$PROMPT_HOST$CHAR_RPAREN"
        local PROMPT_DATE="$CHAR_LPAREN%b%F{cyan}$(date +"%a %d %b")$CHAR_RPAREN"
        local PROMPT_TTY="$CHAR_LPAREN%b%F{cyan}$TTY$CHAR_RPAREN"
        local PROMPT_SHLVL="$CHAR_LPAREN%b%F{cyan}»$(( SHLVL - 1 ))«$CHAR_RPAREN"
        local PROMPT_RET="$CHAR_LPAREN%B%F{red}%?$CHAR_RPAREN"
        local PROMPT_TIME="$CHAR_LPAREN%B%F{green}%*$CHAR_RPAREN"
        local PROMPT_CHAR="%(!.%B%F{red}#.%B%F{white}>)"

        export PROMPT_DAVI_LINE_1_L="%B%F{cyan}.-$PROMPT_JOB$CHAR_SEP$PROMPT_DIR"
        export PROMPT_DAVI_LINE_1_R="$PROMPT_DATE$CHAR_SEP$PROMPT_TTY$CHAR_SEP$PROMPT_SHLVL$CHAR_SEP$PROMPT_ID$CHAR_SEP"

        export PROMPT_DAVI_LINE_2="%B%F{cyan}\`-$PROMPT_RET$CHAR_SEP$PROMPT_TIME$CHAR_SEP$PROMPT_CHAR"

        add-zsh-hook precmd prompt_davi_precmd
    }

    prompt_davi_precmd(){
        setopt noxtrace localoptions extendedglob
        local PROMPT_SEP
        local TILDE='~'
        local PROMPT_JOB="$#jobtexts"
        local LINE_1_VAL="${PWD/$HOME/$TILDE}$(date +"%a %d %b")$TTY$USER$HOST$(( SHLVL - 1 ))$PROMPT_JOB"
        local LINE_1_LEN=$(( COLUMNS - ( $#LINE_1_VAL + 22 ) ))

        if (( LINE_1_LEN > 0 )); then
            eval "PROMPT_SEP=\${(l:${LINE_1_LEN}::-:)}"
        fi
        export PROMPT_DAVI_LINE_1="$PROMPT_DAVI_LINE_1_L%b%F{cyan}$PROMPT_SEP$PROMPT_DAVI_LINE_1_R"

        export PROMPT="$PROMPT_DAVI_LINE_1"$'\n'"$PROMPT_DAVI_LINE_2 %b%f"
        export PS2="%b%F{white}[%B%F{blue}%_%b%F{white}]%b%F{cyan}-%B%F{white}> "
        export PS4="%B%F{red}+%b%F{white}[%B%F{blue}%N%b%F{white}]%B%F{cyan}-%b%F{white}[%B%F{blue}%i%b%F{white}]%B%F{cyan}-%B%F{white}> %b%f"
        export zle_highlight[(r)default:*]="default:fg=yellow,bold"
    }

    prompt_davi_setup
}
