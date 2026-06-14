##### Powerlevel10k Instant Prompt #####
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

##### Git 设置：使用 SSH 替代 HTTPS（避免 clone 失败） #####
git config --global url."git@github.com:".insteadOf "https://github.com/"

##### 基础环境变量 #####
export EDITOR="code"     # 默认编辑器，可改为 code 或 nano
export VISUAL="$EDITOR"
export PAGER="less"    # 默认分页器

# 将 ~/.local/bin 添加到 PATH 中（如果尚未添加）
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$HOME/.local/bin:$PATH" ;;
esac

##### nvm 配置 #####
export NVM_DIR="$HOME/.nvm"
export NPM_CONFIG_USERCONFIG="$HOME/.npmrc"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # 加载 nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # nvm bash_completion

##### Shell 行为优化 #####
setopt autocd              # 输入目录名自动 cd
setopt correct             # 自动更正命令拼写
setopt interactivecomments # 允许交互式注释
setopt magicequalsubst     # 支持 key=~/xxx 自动展开
setopt nonomatch           # 模式不匹配时不报错
setopt notify              # 后台任务完成立刻提示
setopt numericglobsort     # 文件名数字排序
setopt promptsubst         # 支持 prompt 中命令替换

# 历史记录配置
setopt histignorealldups     # 忽略重复记录
setopt sharehistory          # 所有终端共享历史
setopt inc_append_history    # 命令执行后立即写入历史文件
setopt extended_history      # 历史中记录时间戳

HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000

##### 终端行为 #####
bindkey -e                  # 使用 Emacs 键绑定
precmd() { print -Pn "\e]0;%n@%m: %~\a" }  # 设置终端窗口标题

##### 快速补全配置(加上 -u 忽略权限检查) #####
autoload -Uz compinit
compinit -u -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump-$ZSH_VERSION"

##### 插件管理器 zinit 初始化 #####
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

##### 主题 & 插件加载（使用 zinit）#####
# P10K 主题（必须最前加载）
zinit ice depth"1"
zinit light romkatv/powerlevel10k

# 补全增强
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions  # 自动建议（类似鱼壳）
zinit light zsh-users/zsh-history-substring-search 

# 模式增强
zinit light jeffreytse/zsh-vi-mode

# 命令高亮一定要放在 Zinit 插件列表的最末尾！
zinit light zsh-users/zsh-syntax-highlighting

# Oh-My-Zsh 插件片段
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

##### 主题配置文件#####
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

##### WSL 代理配置 #####
# 1. 获取宿主机 IP (通过 /etc/resolv.conf)
export HOST_IP=$(grep nameserver /etc/resolv.conf | awk '{print $2}')

# 2. 设置代理端口 (假设代理软件端口是 7890，Clash 默认通常是 7890)
export PROXY_PORT=7890 

# 3. 定义代理地址
export PROXY_ADDR="http://$HOST_IP:$PROXY_PORT"

# 4. 快捷命令：手动开/关代理
alias proxy_on='
    export http_proxy="$PROXY_ADDR";
    export https_proxy="$PROXY_ADDR";
    export ALL_PROXY="$PROXY_ADDR";
    echo "Proxy ON: $PROXY_ADDR"
'

alias proxy_off='
    unset http_proxy;
    unset https_proxy;
    unset ALL_PROXY;
    echo "Proxy OFF"
'

##### Eza 配置 (ls 的现代替代品) #####
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --color=auto --group-directories-first'
    alias ll='eza -lah --git'                  # 详细列表，带 Git 状态
    alias la='eza -a --group-directories-first' # 显示所有文件
    alias l='eza -l --git'                     # 简洁详细列表
    alias lt='eza -T --level=2'                # 树形结构 (2层)
    alias ltf='eza -T --level=4'               # 树形结构 (4层)
    alias lsi='eza --color=auto --group-directories-first --icons'   # 基础列表 + 图标
    alias lli='eza -lah --git --icons'         # 详细列表 + 图标

    # 如果 _eza 补全存在则启用
    (( $+functions[_eza] )) && compdef _eza ls ll la lsi lli
fi

alias np+='/mnt/d/Applications/Notepad++/notepad++.exe'
alias code='/mnt/d/DevTool/VSCode/bin/code'

alias claude-mem='bun "/home/zzhua/.claude/plugins/cache/thedotmack/claude-mem/12.3.8/scripts/worker-service.cjs"'

##### Python & uv 配置 #####
# 使用 uv 管理的 Python 作为默认版本
export UV_PYTHON_BIN="$HOME/.local/share/uv/python/cpython-3.13.13-linux-x86_64-gnu/bin"
case ":$PATH:" in
    *":$UV_PYTHON_BIN:"*) ;;
    *) PATH="$UV_PYTHON_BIN:$PATH" ;;
esac

# Alias
alias ve='uv venv'                    # 创建虚拟环境: ve
alias va='source .venv/bin/activate'  # 激活虚拟环境: va
alias vd='deactivate'                 # 退出虚拟环境: vd
alias uvrun='uv run'                  # 无需激活直接运行

# uv shell completion
eval "$(uv generate-shell-completion zsh 2>/dev/null)"

##### bun 配置 #####
# bun completions
[ -s "/home/zzhua/.bun/_bun" ] && source "/home/zzhua/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

