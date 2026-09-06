#!/usr/bin/env bash
# ============================================================
# Ops SkillHub 一键安装脚本
# 支持：单 skill、按分类、全量、列表、卸载、更新
# 跨平台：Linux / macOS / Windows (Git Bash)
# ============================================================

set -e

REPO_URL="https://github.com/yx119924/ops_skillhub.git"
REPO_BRANCH="main"
CACHE_DIR="${HOME}/.workbuddy/.skillhub-cache"
SKILLS_DIR="${HOME}/.workbuddy/skills"

# 颜色（Git Bash 兼容）
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    NC='\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; BLUE=''; CYAN=''; NC=''
fi

print_header() {
    echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║       Ops SkillHub Installer v0.1.0         ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
    echo ""
}

print_help() {
    cat << 'EOF'
Ops SkillHub 一键安装脚本

📦 用法:
    ./install.sh                             # 安装所有 skill
    ./install.sh all                         # 同上
    ./install.sh <skill-name>                # 安装单个 skill
    ./install.sh --category <cat-name>       # 安装某分类下所有 skill
    ./install.sh --list                      # 列出所有可用 skill
    ./install.sh --update                    # 仅更新缓存（不安装）
    ./install.sh --uninstall <skill-name>    # 卸载某个 skill
    ./install.sh --path                      # 显示路径信息
    ./install.sh --help                      # 显示帮助

📝 示例:
    ./install.sh ops-ssh-troubleshoot
    ./install.sh --category 02-disk-storage
    ./install.sh --uninstall ops-ssh-troubleshoot

📂 默认路径:
    缓存目录: ~/.workbuddy/.skillhub-cache
    安装目录: ~/.workbuddy/skills/

🔗 仓库: https://github.com/yx119924/ops_skillhub
EOF
}

# 确保缓存是最新的
ensure_cache() {
    if [ ! -d "${CACHE_DIR}/.git" ]; then
        echo -e "${YELLOW}→ 首次运行，克隆仓库到本地缓存...${NC}"
        rm -rf "${CACHE_DIR}"
        git clone --depth 1 --branch "${REPO_BRANCH}" "${REPO_URL}" "${CACHE_DIR}"
    else
        echo -e "${BLUE}→ 同步最新版本...${NC}"
        (cd "${CACHE_DIR}" && git pull --quiet --depth 1 origin "${REPO_BRANCH}" 2>/dev/null || \
         cd "${CACHE_DIR}" && git fetch --quiet origin && git reset --hard origin/"${REPO_BRANCH}" --quiet)
    fi
}

# 检测分类目录
is_category_dir() {
    local dirname="$1"
    [[ "${dirname}" =~ ^[0-9]+- ]] && return 0 || return 1
}

# 安装单个 skill
install_skill() {
    local skill_name="$1"
    local skill_path=""
    
    # 在所有分类下查找
    while IFS= read -r path; do
        if [ -n "$path" ]; then
            skill_path="$path"
            break
        fi
    done < <(find "${CACHE_DIR}" -type d -name "${skill_name}" -not -path "*/.git/*" 2>/dev/null)
    
    if [ -z "${skill_path}" ] || [ ! -d "${skill_path}" ]; then
        echo -e "${RED}✗ 未找到 skill: ${skill_name}${NC}"
        echo -e "${YELLOW}  提示: 运行 ./install.sh --list 查看所有可用 skill${NC}"
        return 1
    fi
    
    if [ ! -f "${skill_path}/SKILL.md" ]; then
        echo -e "${RED}✗ 该目录下没有 SKILL.md，文件结构异常: ${skill_path}${NC}"
        return 1
    fi
    
    mkdir -p "${SKILLS_DIR}"
    rm -rf "${SKILLS_DIR}/${skill_name}"
    cp -r "${skill_path}" "${SKILLS_DIR}/"
    echo -e "${GREEN}✓ 已安装: ${skill_name}${NC}"
    echo -e "  路径: ${SKILLS_DIR}/${skill_name}"
}

# 安装某分类下所有 skill
install_category() {
    local category="$1"
    local category_path="${CACHE_DIR}/${category}"
    
    if [ ! -d "${category_path}" ]; then
        echo -e "${RED}✗ 未找到分类: ${category}${NC}"
        echo -e "${YELLOW}  可用分类:${NC}"
        for dir in "${CACHE_DIR}"/*/; do
            [ -d "$dir" ] && is_category_dir "$(basename "$dir")" && echo "    • $(basename "$dir")"
        done
        return 1
    fi
    
    mkdir -p "${SKILLS_DIR}"
    local count=0
    for skill_dir in "${category_path}"*/; do
        [ -d "${skill_dir}" ] || continue
        local skill_name=$(basename "${skill_dir}")
        if [[ "${skill_name}" == ops-* ]] || [[ "${skill_name}" == sop-* ]]; then
            cp -r "${skill_dir}" "${SKILLS_DIR}/"
            echo -e "${GREEN}✓ ${skill_name}${NC}"
            count=$((count + 1))
        fi
    done
    
    if [ ${count} -eq 0 ]; then
        echo -e "${YELLOW}⚠ 分类 ${category} 下暂无 skill${NC}"
    else
        echo ""
        echo -e "${GREEN}✓ 共安装 ${count} 个 skill${NC}"
    fi
}

# 安装所有 skill
install_all() {
    mkdir -p "${SKILLS_DIR}"
    local count=0
    for category_dir in "${CACHE_DIR}"/*/; do
        [ -d "${category_dir}" ] || continue
        is_category_dir "$(basename "${category_dir}")" || continue
        
        for skill_dir in "${category_dir}"*/; do
            [ -d "${skill_dir}" ] || continue
            local skill_name=$(basename "${skill_dir}")
            if [[ "${skill_name}" == ops-* ]] || [[ "${skill_name}" == sop-* ]]; then
                cp -r "${skill_dir}" "${SKILLS_DIR}/"
                echo -e "${GREEN}✓ ${skill_name}${NC}"
                count=$((count + 1))
            fi
        done
    done
    
    if [ ${count} -eq 0 ]; then
        echo -e "${YELLOW}⚠ 仓库中暂无任何 skill${NC}"
    else
        echo ""
        echo -e "${GREEN}✓ 共安装 ${count} 个 skill 到 ${SKILLS_DIR}${NC}"
    fi
}

# 列出所有可用 skill
list_skills() {
    echo -e "${CYAN}可用 Skill 列表:${NC}"
    echo "─────────────────────────────────────────────────"
    local total=0
    for category_dir in "${CACHE_DIR}"/*/; do
        [ -d "${category_dir}" ] || continue
        is_category_dir "$(basename "${category_dir}")" || continue
        
        local category=$(basename "${category_dir}")
        echo ""
        echo -e "${YELLOW}[${category}]${NC}"
        
        for skill_dir in "${category_dir}"*/; do
            [ -d "${skill_dir}" ] || continue
            local skill_name=$(basename "${skill_dir}")
            if [[ "${skill_name}" == ops-* ]] || [[ "${skill_name}" == sop-* ]]; then
                # 读取 SKILL.md 第一段作为简介
                local desc="-"
                if [ -f "${skill_dir}/SKILL.md" ]; then
                    desc=$(awk '/^description:/{flag=1; next} flag && /^[a-z]/ && !/^description:/{exit} flag' "${skill_dir}/SKILL.md" | head -1 | sed 's/^[[:space:]]*//' | cut -c1-60)
                    [ -z "$desc" ] && desc="-"
                fi
                
                # 检查是否已安装
                local mark=""
                if [ -d "${SKILLS_DIR}/${skill_name}" ]; then
                    mark="${GREEN}✓${NC}"
                else
                    mark="${BLUE}○${NC}"
                fi
                
                echo -e "  ${mark} ${skill_name}"
                echo -e "    ${desc}..."
                total=$((total + 1))
            fi
        done
    done
    echo ""
    echo -e "${CYAN}共 ${total} 个 skill (✓=已安装 ○=未安装)${NC}"
}

# 卸载 skill
uninstall_skill() {
    local skill_name="$1"
    if [ -d "${SKILLS_DIR}/${skill_name}" ]; then
        rm -rf "${SKILLS_DIR}/${skill_name}"
        echo -e "${GREEN}✓ 已卸载: ${skill_name}${NC}"
    else
        echo -e "${YELLOW}⚠ 未安装: ${skill_name}${NC}"
    fi
}

# 显示路径信息
show_paths() {
    echo "📂 路径信息:"
    echo "  缓存目录: ${CACHE_DIR}"
    echo "  安装目录: ${SKILLS_DIR}"
    echo ""
    echo "📊 当前状态:"
    if [ -d "${CACHE_DIR}/.git" ]; then
        echo -e "  缓存: ${GREEN}已初始化${NC}"
        local commits=$(cd "${CACHE_DIR}" && git log --oneline -1 2>/dev/null | head -1)
        echo "  最新版本: ${commits}"
    else
        echo -e "  缓存: ${YELLOW}未初始化${NC}"
    fi
    
    local installed_count=0
    if [ -d "${SKILLS_DIR}" ]; then
        installed_count=$(find "${SKILLS_DIR}" -maxdepth 2 -name "SKILL.md" 2>/dev/null | wc -l)
    fi
    echo "  已安装 skill: ${installed_count} 个"
}

# 仅更新缓存
update_only() {
    ensure_cache
    echo -e "${GREEN}✓ 缓存已更新到最新版本${NC}"
}

# ====== 主逻辑 ======

print_header

case "${1:-}" in
    "")
        ensure_cache
        install_all
        ;;
    all)
        ensure_cache
        install_all
        ;;
    --list|list|-l)
        ensure_cache
        list_skills
        ;;
    --category|--cat|-c)
        if [ -z "$2" ]; then
            echo -e "${RED}✗ 缺少分类名${NC}"
            print_help
            exit 1
        fi
        ensure_cache
        install_category "$2"
        ;;
    --update|update|-u)
        update_only
        ;;
    --uninstall|uninstall|remove)
        if [ -z "$2" ]; then
            echo -e "${RED}✗ 缺少 skill 名${NC}"
            print_help
            exit 1
        fi
        uninstall_skill "$2"
        ;;
    --path|path|-p)
        show_paths
        ;;
    --help|help|-h)
        print_help
        ;;
    ops-*|sop-*)
        ensure_cache
        install_skill "$1"
        ;;
    *)
        echo -e "${RED}✗ 未知参数: $1${NC}"
        echo ""
        print_help
        exit 1
        ;;
esac

echo ""
echo -e "${CYAN}提示: 重启 AI 工具后新安装的 skill 即可生效${NC}"