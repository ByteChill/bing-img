#!/usr/bin/env bash
set -euo pipefail

# 配置（若需修改）
EXPECTED_REMOTE_SUBSTR="github.com/ByteChill/bing-img"
TARGET_REMOTE="origin"
TARGET_BRANCH="main"
TEMP_BRANCH="clean"
COMMIT_MSG="chore: wipe history — single commit keeping current content"

# 检查当前目录是否为 git 仓库
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "错误: 当前目录不是 git 仓库。请在仓库根目录运行此脚本。"
  exit 1
fi

# 检查远端 URL 是否匹配预期仓库
REMOTE_URL=$(git remote get-url "${TARGET_REMOTE}" 2>/dev/null || true)
if [[ -z "${REMOTE_URL}" || "${REMOTE_URL}" != *"${EXPECTED_REMOTE_SUBSTR}"* ]]; then
  echo "远端 URL 检查失败。检测到的远端: ${REMOTE_URL}"
  echo "此脚本期望远端包含: ${EXPECTED_REMOTE_SUBSTR}"
  echo "如果这是正确仓库，请编辑脚本或手动运行命令。"
  exit 1
fi

echo "远端 URL: ${REMOTE_URL}"
echo "将在远端 '${TARGET_REMOTE}/${TARGET_BRANCH}' 上用单一提交覆盖历史。"
read -p "你确认要继续并覆盖远端历史吗？输入 YES 继续: " CONFIRM
if [[ "${CONFIRM}" != "YES" ]]; then
  echo "已取消。输入必须为 YES。"
  exit 0
fi

# 同步远端
git fetch "${TARGET_REMOTE}" --prune

# 创建孤立分支并提交当前工作树
git checkout --orphan "${TEMP_BRANCH}"
git reset --hard
git add -A
git commit -m "${COMMIT_MSG}"

# 将 clean 推为远端 main（直接覆盖）
git push "${TARGET_REMOTE}" "${TEMP_BRANCH}:${TARGET_BRANCH}" --force

# 本地重命名并设置上游
git branch -m "${TARGET_BRANCH}"
git branch --set-upstream-to="${TARGET_REMOTE}/${TARGET_BRANCH}" "${TARGET_BRANCH}"

echo "远端 ${TARGET_REMOTE}/${TARGET_BRANCH} 已被覆盖为单一提交。"

# 可选的本地清理提示
echo "如果你想回收本地不可达对象，运行："
echo "  git reflog expire --expire=now --all && git gc --prune=now --aggressive"
