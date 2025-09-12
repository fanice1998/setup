## config.fish

# NVM
#    自動檢測是否有 nvm 並安裝 fish-nvm
#    若沒有 nvm 則不會安裝 fish-nvm
# Go
#    自動檢測是否有安裝 go
#    如果 go 資料夾存在, 會新增到系統到環境變數 PATH 中

# 如果需要使用到 bass 指令
# 需要額外安裝 fisher, 安裝完成後再安裝 bass
# curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
# fisher install edc/bass

# 自動安裝 fisher
if not type -q fisher
    echo "Fisher 未安裝，正在嘗試安裝..."
    if curl -sL https://git.io/fisher | source
        echo "Fisher 安裝腳本已下載..."
        if fisher install jorgebucaran/fisher >/dev/null 2>&1
            echo "fisher 安裝成功"
            echo "fisher version: "(fisher --version)
        else
            echo "fisher 安裝失敗"
            exit 1
        end
    else
        echo "fisher 安裝腳本下載失敗"
        echo 請檢查網路
        exit 1
    end
end

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

# NVM 判斷以及初始化
# 1. 檢查 nvm 是否可用
# 2. nvm 不可用, 則查看是否已安裝 fish-nvm
# 3. fish-nvm 未安裝, 確認 "$NVM_DIR" 是否存在, 不存在則跳過
if set -q NVM_DIR; and not type -q nvm
    if type -q fisher; and not fisher list | grep -E "jorgebucaran/fish-nvm|jorgebucaran/nvm.fish" >/dev/null 2>&1
        echo "已安裝 fisher 但未安裝 fish-nvm"
        echo "\$NVM_DIR: "(set -q NVM_DIR && echo $NVM_DIR || echo "未設置")
    else
        echo "正在安裝 fish-nvm..."
        if fisher install jorgebucaran/fish-nvm >/dev/null 2>&1
            echo "fish-nvm 安裝成功"
            if not type -q nvm
                echo "WARRING: 找不到 nvm 指令或 NVM_DIR 異常"
                echo "安裝 nvm：curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash"
            else
                echo "fish-nvm 已安裝, 可正常使用 nvm"
            end
        else
            echo "fish-nvm 安裝失敗"
            echo "請檢查網路連線或 ~/.config/fish 目錄權限"
            exit 1
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

# Go 路徑
if not command -v go >/dev/null; and test -d /usr/local/go/bin; and test -f /usr/local/go/bin/go
    set -gx PATH "$PATH:/usr/local/go/bin"
end
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
source $HOME/.env_setup
starship init fish | source
source /home/fanice/.env_setup
