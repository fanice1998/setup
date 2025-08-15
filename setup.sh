#!/bin/bash
# 腳本名稱：setup.sh
# 功能：檢查並安裝工具，拉取 GitHub 配置，設定環境變數

# 強制設置 TERM
export TERM=xterm-256color

# 使用 tput 定義顏色
if command -v tput >/dev/null 2>&1; then
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    NC=$(tput sgr0)
else
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
fi

# 格式化輸出函數
print() {
    printf "%s%s%s\n" "$1" "$2" "$NC"
}

# 檢查系統
if [[ "$(uname)" == "Darwin" ]]; then
    OS="macOS"
elif [[ -f /etc/os-release ]] && grep -qi "ubuntu" /etc/os-release; then
    OS="Ubuntu"
else
    print "$RED" "錯誤：僅支持 macOS 或 Ubuntu"
    exit 1
fi

# 檢查並安裝 Git
if ! command -v git >/dev/null 2>&1; then
    print "$YELLOW" "未找到 Git，是否安裝？(y/n)"
    read -r install_git
    if [[ "$install_git" == "y" || "$install_git" == "Y" ]]; then
        if [[ "$OS" == "macOS" ]]; then
            if ! command -v brew >/dev/null 2>&1; then
                print "$RED" "需要 Homebrew，請先安裝：https://brew.sh"
                exit 1
            fi
            print "$YELLOW" "開始安裝 Git..."
            brew install git || {
                print "$RED" "Homebrew 安裝 Git 失敗，請檢查權限或 Homebrew 設定"
                exit 1
            }
            printf "%s\n" "$NC"
        else
            print "$YELLOW" "開始安裝 Git..."
            sudo apt update && sudo apt install -y git || {
                print "$RED" "apt 安裝 Git 失敗，請檢查管理員權限或網路"
                exit 1
            }
            printf "%s\n" "$NC"
        fi
    else
        print "$RED" "需要 Git 來拉取配置，退出"
        exit 1
    fi
fi

# 定義工具清單（helix 使用 hx 指令）
tools=("fish" "starship" "wezterm" "hx")

# 檢查並安裝工具
for tool in "${tools[@]}"; do
    if [[ -z "$tool" ]]; then
        print "$YELLOW" "警告：檢測到空工具名稱，跳過"
        continue
    fi
    if ! command -v "$tool" >/dev/null 2>&1; then
        print "$YELLOW" "未找到 $tool，是否安裝？(y/n)"
        read -r install_tool
        if [[ "$install_tool" == "y" || "$install_tool" == "Y" ]]; then
            if [[ "$OS" == "macOS" ]]; then
                [[ "$tool" == "hx" ]] && pkg="helix" || pkg="$tool"
                brew install "$pkg" || {
                    print "$RED" "Homebrew 安裝 $tool 失敗，請檢查權限或 Homebrew 設定"
                    exit 1
                }
            else
                if [[ "$tool" == "starship" ]]; then
                    if ! command -v curl >/dev/null 2>&1; then
                        print "$YELLOW" "未找到 curl，開始安裝..."
                        sudo apt update && sudo apt install -y curl || {
                            print "$RED" "curl 安裝失敗，請檢查管理員權限或網路"
                            exit 1
                        }
                    fi
                    print "$YELLOW" "正在 Ubuntu 上安裝 Starship..."
                    curl -sS https://starship.rs/install.sh | sh -s -- -y || {
                        print "$RED" "Starship 安裝失敗，請檢查網路或權限"
                        exit 1
                    }
                    # 檢查 Starship 版本
                    if command -v starship >/dev/null 2>&1; then
                        starship_version=$(starship --version | head -n 1)
                        print "$GREEN" "Starship 已安裝，版本：$starship_version"
                    fi
                elif [[ "$tool" == "wezterm" ]]; then
                    if ! command -v curl >/dev/null 2>&1; then
                        print "$YELLOW" "未找到 curl，開始安裝..."
                        sudo apt update && sudo apt install -y curl || {
                            print "$RED" "curl 安裝失敗，請檢查管理員權限或網路"
                            exit 1
                        }
                    fi
                    if ! command -v gpg >/dev/null 2>&1; then
                        print "$YELLOW" "未找到 gpg，開始安裝..."
                        sudo apt update && sudo apt install -y gnupg || {
                            print "$RED" "gpg 安裝失敗，請檢查管理員權限或網路"
                            exit 1
                        }
                    fi
                    print "$YELLOW" "正在 Ubuntu 上安裝 WezTerm..."
                    curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg || {
                        print "$RED" "添加 WezTerm GPG 密鑰失敗，請檢查網路或權限"
                        exit 1
                    }
                    echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list || {
                        print "$RED" "添加 WezTerm APT 儲存庫失敗，請檢查權限"
                        exit 1
                    }
                    sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg || {
                        print "$RED" "設定 WezTerm GPG 密鑰權限失敗，請檢查權限"
                        exit 1
                    }
                    sudo apt update && sudo apt install -y wezterm || {
                        print "$RED" "apt 安裝 WezTerm 失敗，請檢查管理員權限或網路"
                        exit 1
                    }
                    # 檢查 WezTerm 版本
                    if command -v wezterm >/dev/null 2>&1; then
                        wezterm_version=$(wezterm --version | head -n 1)
                        print "$GREEN" "WezTerm 已安裝，版本：$wezterm_version"
                    fi
                else
                    [[ "$tool" == "hx" ]] && pkg="helix" || pkg="$tool"
                    if [[ "$pkg" == "helix" ]]; then
                        sudo add-apt-repository ppa:maveonair/helix-editor -y || {
                            print "$RED" "添加 helix PPA 失敗，請檢查網路或權限"
                            exit 1
                        }
                    fi
                    sudo apt update && sudo apt install -y "$pkg" || {
                        print "$RED" "apt 安裝 $tool 失敗，請檢查管理員權限或網路"
                        exit 1
                    }
                fi
            fi
        else
            print "$YELLOW" "跳過 $tool 安裝"
        fi
    else
        print "$GREEN" "$tool 已安裝"
    fi
done

# 拉取最新儲存庫
REPO_URL="https://github.com/fanice1998/setup.git"
TEMP_DIR="/tmp/fanice1998_setup"
print "$YELLOW" "拉取最新配置從 $REPO_URL (main 分支)..."
rm -rf "$TEMP_DIR"
git clone --branch main "$REPO_URL" "$TEMP_DIR" || {
    print "$RED" "Git 拉取失敗，請檢查網路或 GitHub 存取權限"
    exit 1
}

# 定義設定檔映射
configs=(
    "fish:fish/config.fish:$HOME/.config/fish/config.fish"
    "starship:starship/starship.toml:$HOME/.config/starship/starship.toml"
    "wezterm:wezterm/.wezterm.lua:$HOME/.config/.wezterm.lua"
    "helix:helix/config.toml:$HOME/.config/helix/config.toml"
)

# 複製設定檔
for config in "${configs[@]}"; do
    IFS=":" read -r tool src dest <<< "$config"
    src_path="$TEMP_DIR/$src"
    dest_dir=$(dirname "$dest")
    if [[ -f "$src_path" ]]; then
        mkdir -p "$dest_dir"
        cp "$src_path" "$dest" || {
            print "$RED" "複製 $tool 設定檔失敗，請檢查權限"
            exit 1
        }
        print "$GREEN" "已複製 $tool 設定檔到 $dest"
    else
        print "$YELLOW" "未找到 $tool 設定檔 ($src_path)，跳過"
    fi
done

# 設定環境變數
ENV_FILE="$HOME/.env_setup"
cat > "$ENV_FILE" << EOF
# 環境變數 for terminal setup
export FISH_CONFIG="$HOME/.config/fish/config.fish"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
export WEZTERM_CONFIG="$HOME/.config/.wezterm.lua"
export HELIX_CONFIG="$HOME/.config/helix/config.toml"
EOF
print "$GREEN" "環境變數已寫入 $ENV_FILE"

# 在 shell 設定檔中加入 source
shell_files=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.config/fish/config.fish")
for file in "${shell_files[@]}"; do
    dir=$(dirname "$file")
    mkdir -p "$dir"
    touch "$file"
    if ! grep -q "source $ENV_FILE" "$file"; then
        echo "source $ENV_FILE" >> "$file"
        print "$GREEN" "已將 source $ENV_FILE 加入 $file"
    else
        print "$YELLOW" "$file 已包含 source $ENV_FILE，跳過"
    fi
done

# 初始化 Starship
if command -v starship >/dev/null 2>&1; then
    for file in "${shell_files[@]}"; do
        if [[ "$file" == *".bashrc" ]]; then
            if ! grep -q "starship init bash" "$file"; then
                echo 'eval "$(starship init bash)"' >> "$file"
                print "$GREEN" "已為 bash 初始化 Starship 在 $file"
            fi
        elif [[ "$file" == *".zshrc" ]]; then
            if ! grep -q "starship init zsh" "$file"; then
                echo 'eval "$(starship init zsh)"' >> "$file"
                print "$GREEN" "已為 zsh 初始化 Starship 在 $file"
            fi
        elif [[ "$file" == *".config/fish/config.fish" ]]; then
            if ! grep -q "starship init fish" "$file"; then
                echo 'starship init fish | source' >> "$file"
                print "$GREEN" "已為 fish 初始化 Starship 在 $file"
            fi
        fi
    done
fi

# 重載 shell
if [[ -n "$BASH" && -f "$HOME/.bashrc" ]]; then
    source "$HOME/.bashrc"
    print "$GREEN" "已重載 bash"
elif [[ -n "$ZSH_NAME" && -f "$HOME/.zshrc" ]]; then
    source "$HOME/.zshrc"
    print "$GREEN" "已重載 zsh"
fi
if command -v fish >/dev/null 2>&1; then
    fish -c "source $HOME/.config/fish/config.fish" 2>/dev/null
    print "$GREEN" "已重載 fish"
fi

print "$GREEN" "腳本執行完成！"
