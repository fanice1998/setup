# config.fish

# 匯入 Bash/Zsh 的環境變數
if status is-interactive
    # 假設使用 Bash，匯入 PATH 和其他環境變數
    # 若使用 Zsh，請將 ~/.bashrc 替換為 ~/.zshrc
    eval (bash -c 'source ~/.bashrc; env | grep -E "^(PATH|HOME|USER|CARGO_HOME|RUSTUP_HOME|NVM_DIR|GOPATH|GOROOT)="')
end

# 確保 cargo 的路徑（rustup 安裝）
if test -d "$HOME/.cargo/bin"
    set -gx PATH $PATH $HOME/.cargo/bin
end

# 確保 brew 的路徑
if command -v brew >/dev/null
    eval (brew shellenv)
end

# 確保 apt 的路徑
if command -v apt >/dev/null
    set -gx PATH $PATH /usr/bin
end

# 設置 nvm 和 Node.js
if test -d "$HOME/.nvm"
    set -gx NVM_DIR "$HOME/.nvm"
    # 載入 nvm（模擬 nvm.sh 的功能）
    function nvm
        bash -c "source $NVM_DIR/nvm.sh; nvm $argv"
    end
    # 預設載入最新的 Node.js 版本（可根據需求修改）
    if test -f "$NVM_DIR/nvm.sh"
        bash -c "source $NVM_DIR/nvm.sh; nvm use default"
    end
end

# 確保 Go 的路徑
if command -v go >/dev/null
    set -gx GOPATH "$HOME/go"
    set -gx PATH $PATH $GOPATH/bin /usr/local/go/bin
end

# 設置常用別名
alias ll 'ls -la'
alias gs 'git status'
alias gc 'git commit -m'

# 自定義提示符（簡約風格）
function fish_prompt
    set_color cyan
    echo -n (prompt_pwd)
    set_color normal
    echo -n ' $ '
end

# 設置 PATH，添加常用路徑
set -gx PATH $PATH /usr/local/bin /usr/bin /bin /usr/sbin /sbin
