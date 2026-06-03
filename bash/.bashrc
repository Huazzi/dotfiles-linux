# ~/.bashrc: 由 bash(1) 为非登录 shell 执行。
# 有关更多示例，请参阅 /usr/share/doc/bash/examples/startup-files (在 bash-doc 包中)

# ==================== 0. 环境变量/路径配置 =============
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$HOME/.local/bin:$PATH" ;;
esac

# ==================== 1. 交互式检查 ====================
# 如果不是在交互模式下运行，则不执行任何操作
case $- in
    *i*) ;;
      *) return;;
esac

# ==================== 2. 历史记录设置 ====================
# 不在历史记录中保存重复行，以及以空格开头的行
# 更多选项请参见 bash(1)
HISTCONTROL=ignoreboth

# 将历史记录追加到文件中，而不是覆盖它
shopt -s histappend

# 设置历史记录长度，请参见 bash(1) 中的 HISTSIZE 和 HISTFILESIZE
# 这里增加了保存的数量，方便回溯更多命令
HISTSIZE=5000
HISTFILESIZE=10000
HISTIGNORE='ls:ll:la:l:pwd:exit:clear:history'

# 多终端实时同步历史，避免只在退出时写入
case ";${PROMPT_COMMAND};" in
    *";history -a;"*) ;;
    *) PROMPT_COMMAND="history -a; history -n${PROMPT_COMMAND:+; $PROMPT_COMMAND}" ;;
esac

# ==================== 3. 窗口与显示设置 ====================
# 在每个命令后检查窗口大小，如果有必要，
# 更新 LINES 和 COLUMNS 的值。
shopt -s checkwinsize

# 如果设置，在路径名扩展上下文中使用的模式 "**"
# 将匹配所有文件和零个或多个目录及子目录。
#shopt -s globstar

# 使 less 对非文本输入文件更友好，参见 lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# 设置识别你所在的 chroot 的变量（在下面的提示中使用）
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# ==================== 4. 提示符 (Prompt) 设置 ====================
# 设置一个漂亮的提示符（默认非彩色，除非我们知道“想要”颜色）
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# 如果终端有此功能，取消注释以强制启用彩色提示符
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # 我们有颜色支持；假设符合 Ecma-48
    # (ISO/IEC-6429)。（缺乏这种支持极其罕见，而且
    # 这种情况倾向于支持 setf 而不是 setaf。）
    color_prompt=yes
    else
    color_prompt=
    fi
fi

# --- 自定义提示符样式 ---
# 第一行：当前路径，第二行：提示符 '❯'
if [ "$color_prompt" = yes ]; then
    # 彩色版本：
    # \w -> 完整路径 (蓝色)
    # \n -> 换行
    # >  -> 提示符 (绿色)
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;34m\]\w\[\033[00m\]\n\[\033[01;32m\]❯ \[\033[00m\]'
else
    # 非彩色版本
    PS1='${debian_chroot:+($debian_chroot)}\w\n$ '
fi
unset color_prompt force_color_prompt

# 如果这是一个 xterm，则将标题设置为 user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# ==================== 5. 颜色与别名支持 (已切换至 eza) ====================
# 启用 grep 的颜色支持 (ls 现在由 eza 接管)
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# --- Eza 替代 LS 配置 ---
# eza 是 ls 的现代替代品，支持 Git 状态、图标和更友好的视图
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --color=auto'                     # 基础列表 (不带图标)
    alias lsi='eza --color=auto --icons'            # 基础列表 (带图标)
    alias ll='eza -lah --git'                       # 详细列表 (所有文件、人性化大小、Git状态)
    alias lli='eza -lah --git --icons'              # 详细列表 (所有文件、人性化大小、Git状态、带图标)
    alias la='eza -a'                               # 列出所有文件 (包括隐藏文件，不带图标)
    alias lai='eza -a --icons'                      # 列出所有文件 (包括隐藏文件，带图标)
    alias l='eza'                                   # 简洁列表
else
    alias ls='ls --color=auto'
    alias lsi='ls --color=auto'
    alias ll='ls -alF'
    alias lli='ls -alF'
    alias la='ls -A'
    alias lai='ls -A'
    alias l='ls -CF'
fi

# 彩色的 GCC 警告和错误
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# 添加一个“alert”别名用于长时间运行的命令。像这样使用：
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# 你可能希望把所有补充内容放到一个单独的文件中，如
# ~/.bash_aliases，而不是直接添加到这里。
# 参见 bash-doc 包中的 /usr/share/doc/bash-doc/examples。

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# ==================== 6. 自动补全功能 ====================
# 启用可编程补全功能（你不需要启用此功能，
# 如果它已经在 /etc/bash.bashrc 和 /etc/profile
# 源引用了 /etc/bash.bashrc）。
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

alias claude-mem='bun "/home/zzhua/.claude/plugins/cache/thedotmack/claude-mem/12.3.8/scripts/worker-service.cjs"'
