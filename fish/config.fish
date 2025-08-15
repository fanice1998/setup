## config.fish

# 初始化 nvm
set -gx NVM_DIR "$HOME/.nvm"
nvm use default >/dev/null 2>&1 config.fish

# 檢查檔案是否存在並匯入必要的環境變數
if status is-interactive
    # 優先檢查 ~/.bashrc 或 ~/.zshrc
    set -l shell_rc
    if test -f "$HOME/.bashrc"
        set shell_rc "$HOME/.bashrc"
    else if test -f "$HOME/.zshrc"
        set shell_rc "$HOME/.zshrc"
    end

    if set -q shell_rc
        # 只匯入 PATH 和必要的環境變數
        for line in (bash -c "source $shell_rc; env | grep -E '^(PATH|HOME|USER|CARGO_HOME|RUSTUP_HOME|NVM_DIR|GOPATH|GOROOT)='")
            set -l key_value (string split -m 1 '=' $line)
            set -gx $key_value[1] $key_value[2]
        end
    end
end

# 輔助函數：檢查並添加路徑，避免重複
function add_to_path
    for path in $argv
        if test -d "$path" && not contains $path $PATH
            set -gx PATH $PATH $path
        end
    end
end

# Rust/Cargo 路徑
if test -d "$HOME/.cargo/bin"
    add_to_path "$HOME/.cargo/bin"
end

# Homebrew 路徑
if test -x /opt/homebrew/bin/brew || test -x /usr/local/bin/brew
    eval (/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)
end

# NVM 初始化
if test -d "$HOME/.nvm"
    set -gx NVM_DIR "$HOME/.nvm"
    # 載入 nvm（避免每次執行都啟動 Bash）
    if test -f "$NVM_DIR/nvm.sh"
        # 初始化 nvm（僅在 interactive shell 中）
        bass source "$NVM_DIR/nvm.sh"
        # 載入預設 Node.js 版本
        if nvm ls default >/dev/null 2>&1
            nvm use default >/dev/null
        end
    end
end

# Go 路徑
if command -v go >/dev/null
    set -q GOPATH || set -gx GOPATH (go env GOPATH)
    add_to_path "$GOPATH/bin" (go env GOROOT)/bin
end

# 設置常用別名
alias ll 'ls -la'
alias gs 'git status'
# 改進 git commit 別名，檢查是否提供 commit 訊息
function gc
    if test (count $argv) -eq 0
        echo "錯誤：請提供 commit 訊息，例如：gc 'Initial commit'"
        return 1
    end
    git commit -m $argv
end

# 自定義提示符（顯示當前目錄和 Git 分支）
function fish_prompt
    set_color cyan
    echo -n (prompt_pwd)
    # 顯示 Git 分支（如果在 Git 倉庫中）
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set_color yellow
        echo -n ' ('(git branch --show-current)')'
    end
    set_color normal
    echo -n ' $ '
end

# 添加常用路徑（確保不重複）
add_to_path /usr/local/bin /usr/bin /bin /usr/sbin /sbin
starship init fish | source
