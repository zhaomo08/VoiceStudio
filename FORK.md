# zhaomo08/VoiceStudio fork

自用学习/二开 fork，上游 [debpalash/VoiceStudio](https://github.com/debpalash/VoiceStudio)。

## 分支

| 分支 | 用途 | 规则 |
|---|---|---|
| `main` | 上游镜像 | 只快进到 `upstream/main`，绝不提交 |
| `develop` | 默认分支，自己开发 | 功能从这里切 `feat/*`，上游改动只用 `cherry-pick -x` 挑进来 |
| `backup/pre-sync-20260929` | 旧 Tauri 时代的自定义提交 `e98efe44` | 只读备份 |

## 跟进上游

```bash
scripts/sync-upstream.sh            # 快进 main 并推送，列出 develop 还没挑的上游提交
scripts/sync-upstream.sh --list     # 只看列表，不联网

git switch develop
git cherry-pick -x <sha>            # 普通提交
git cherry-pick -x -m 1 <sha>       # 上游 PR merge（列表里标了 [merge: -m 1]）
```

`-x` 会在提交里写 `cherry picked from commit <sha>`，脚本靠它判断哪些已经挑过，**别省略**。

新文件优先放在独立路径（如本文件），少改上游已有文件，降低以后 cherry-pick 冲突。
