# ============================================================
# Ops SkillHub 一键安装脚本 (Windows PowerShell 5.1+)
# 用法: .\install.ps1                        # 安装所有
#       .\install.ps1 ops-ssh-troubleshoot   # 安装单个
#       .\install.ps1 --list                  # 列出
#       .\install.ps1 --category 02-disk-storage
#       .\install.ps1 --uninstall ops-ssh-troubleshoot
# ============================================================

$ErrorActionPreference = "Stop"

$RepoUrl    = "https://github.com/yx119924/ops_skillhub.git"
$RepoBranch = "main"
$CacheDir   = Join-Path $env:USERPROFILE ".workbuddy\.skillhub-cache"
$SkillsDir  = Join-Path $env:USERPROFILE ".workbuddy\skills"

function Print-Header {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Ops SkillHub Installer v0.1.0 (PS)  " -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

function Print-Help {
    @"
Ops SkillHub 一键安装脚本 (Windows PowerShell)

📦 用法:
    .\install.ps1                             # 安装所有
    .\install.ps1 <skill-name>                # 安装单个
    .\install.ps1 --category <cat-name>       # 安装某分类所有
    .\install.ps1 --list                      # 列出所有
    .\install.ps1 --update                    # 仅更新缓存
    .\install.ps1 --uninstall <skill-name>    # 卸载
    .\install.ps1 --path                      # 路径信息
    .\install.ps1 --help                      # 帮助

📂 默认路径:
    缓存: $CacheDir
    安装: $SkillsDir
"@
}

function Ensure-Cache {
    if (-not (Test-Path (Join-Path $CacheDir ".git"))) {
        Write-Host "→ 首次运行，克隆仓库..." -ForegroundColor Yellow
        if (Test-Path $CacheDir) { Remove-Item -Recurse -Force $CacheDir }
        git clone --depth 1 --branch $RepoBranch $RepoUrl $CacheDir
    } else {
        Write-Host "→ 同步最新版本..." -ForegroundColor Blue
        Push-Location $CacheDir
        try {
            git pull --depth 1 origin $RepoBranch 2>&1 | Out-Null
        } catch {
            git fetch origin 2>&1 | Out-Null
            git reset --hard origin/$RepoBranch 2>&1 | Out-Null
        }
        Pop-Location
    }
}

function Install-Skill {
    param([string]$SkillName)
    $found = Get-ChildItem -Path $CacheDir -Directory -Recurse -Filter $SkillName -ErrorAction SilentlyContinue |
             Where-Object { $_.Name -eq $SkillName } | Select-Object -First 1

    if (-not $found) {
        Write-Host "✗ 未找到 skill: $SkillName" -ForegroundColor Red
        Write-Host "  提示: 运行 .\install.ps1 --list 查看" -ForegroundColor Yellow
        return
    }

    if (-not (Test-Path (Join-Path $found.FullName "SKILL.md"))) {
        Write-Host "✗ 目录结构异常（缺少 SKILL.md）: $($found.FullName)" -ForegroundColor Red
        return
    }

    if (-not (Test-Path $SkillsDir)) { New-Item -ItemType Directory -Path $SkillsDir | Out-Null }
    $dest = Join-Path $SkillsDir $SkillName
    if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
    Copy-Item -Recurse -Path $found.FullName -Destination $dest
    Write-Host "✓ 已安装: $SkillName" -ForegroundColor Green
    Write-Host "  路径: $dest"
}

function Install-Category {
    param([string]$Category)
    $catPath = Join-Path $CacheDir $Category
    if (-not (Test-Path $catPath)) {
        Write-Host "✗ 未找到分类: $Category" -ForegroundColor Red
        return
    }
    if (-not (Test-Path $SkillsDir)) { New-Item -ItemType Directory -Path $SkillsDir | Out-Null }

    $count = 0
    Get-ChildItem -Path $catPath -Directory | Where-Object { $_.Name -like "ops-*" -or $_.Name -like "sop-*" } | ForEach-Object {
        $dest = Join-Path $SkillsDir $_.Name
        if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
        Copy-Item -Recurse -Path $_.FullName -Destination $dest
        Write-Host "✓ $($_.Name)" -ForegroundColor Green
        $count++
    }
    Write-Host ""
    Write-Host "✓ 共安装 $count 个 skill" -ForegroundColor Green
}

function Install-All {
    if (-not (Test-Path $SkillsDir)) { New-Item -ItemType Directory -Path $SkillsDir | Out-Null }
    $count = 0
    Get-ChildItem -Path $CacheDir -Directory | Where-Object { $_.Name -match '^\d{2}-' } | ForEach-Object {
        Get-ChildItem -Path $_.FullName -Directory | Where-Object { $_.Name -like "ops-*" -or $_.Name -like "sop-*" } | ForEach-Object {
            $dest = Join-Path $SkillsDir $_.Name
            if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
            Copy-Item -Recurse -Path $_.FullName -Destination $dest
            Write-Host "✓ $($_.Name)" -ForegroundColor Green
            $count++
        }
    }
    Write-Host ""
    Write-Host "✓ 共安装 $count 个 skill 到 $SkillsDir" -ForegroundColor Green
}

function List-Skills {
    Write-Host "可用 Skill 列表:" -ForegroundColor Cyan
    Write-Host "─────────────────────────────────────────────────"
    $total = 0
    Get-ChildItem -Path $CacheDir -Directory | Where-Object { $_.Name -match '^\d{2}-' } | ForEach-Object {
        Write-Host ""
        Write-Host "[$($_.Name)]" -ForegroundColor Yellow
        Get-ChildItem -Path $_.FullName -Directory | Where-Object { $_.Name -like "ops-*" -or $_.Name -like "sop-*" } | ForEach-Object {
            $mark = if (Test-Path (Join-Path $SkillsDir $_.Name)) { "✓" } else { "○" }
            $color = if (Test-Path (Join-Path $SkillsDir $_.Name)) { "Green" } else { "Blue" }
            Write-Host "  $($mark) $($_.Name)" -ForegroundColor $color
            $total++
        }
    }
    Write-Host ""
    Write-Host "共 $total 个 skill (✓=已安装 ○=未安装)" -ForegroundColor Cyan
}

function Uninstall-Skill {
    param([string]$SkillName)
    $dest = Join-Path $SkillsDir $SkillName
    if (Test-Path $dest) {
        Remove-Item -Recurse -Force $dest
        Write-Host "✓ 已卸载: $SkillName" -ForegroundColor Green
    } else {
        Write-Host "⚠ 未安装: $SkillName" -ForegroundColor Yellow
    }
}

function Show-Paths {
    Write-Host "📂 路径信息:"
    Write-Host "  缓存目录: $CacheDir"
    Write-Host "  安装目录: $SkillsDir"
    Write-Host ""
    $installed = 0
    if (Test-Path $SkillsDir) {
        $installed = (Get-ChildItem -Path $SkillsDir -Directory -Recurse -Filter "SKILL.md" -ErrorAction SilentlyContinue).Count
    }
    Write-Host "  已安装 skill: $installed 个"
}

# ====== 主逻辑 ======
Print-Header

$arg = $args[0]
switch ($arg) {
    "" { Ensure-Cache; Install-All }
    "all" { Ensure-Cache; Install-All }
    { $_ -in @("--list", "list", "-l") } { Ensure-Cache; List-Skills }
    { $_ -in @("--category", "--cat", "-c") } {
        if (-not $args[1]) { Write-Host "✗ 缺少分类名" -ForegroundColor Red; exit 1 }
        Ensure-Cache; Install-Category $args[1]
    }
    { $_ -in @("--update", "update", "-u") } {
        Ensure-Cache
        Write-Host "✓ 缓存已更新" -ForegroundColor Green
    }
    { $_ -in @("--uninstall", "uninstall", "remove") } {
        if (-not $args[1]) { Write-Host "✗ 缺少 skill 名" -ForegroundColor Red; exit 1 }
        Uninstall-Skill $args[1]
    }
    { $_ -in @("--path", "path", "-p") } { Show-Paths }
    { $_ -in @("--help", "help", "-h") } { Print-Help }
    { $_ -like "ops-*" -or $_ -like "sop-*" } { Ensure-Cache; Install-Skill $arg }
    default {
        Write-Host "✗ 未知参数: $arg" -ForegroundColor Red
        Print-Help
        exit 1
    }
}

Write-Host ""
Write-Host "提示: 重启 AI 工具后新安装的 skill 即可生效" -ForegroundColor Cyan