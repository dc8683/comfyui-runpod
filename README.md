# comfyui-runpod

面向 **RunPod Serverless** 的 ComfyUI worker 镜像与部署文档，配合上游中台 [comfyui-lab](https://github.com/dc8683/comfyui-lab)（调试 / 固化 ComfyUI workflow）使用。

本仓库以 **git submodule** 形式挂在 `comfyui-lab` 下的 `comfyui-runpod/` 目录，但保持独立历史：子仓库的提交会被父仓库以「指针」形式记录，父仓库的提交不影响子仓库。

## 内容

| 文件 | 用途 |
|---|---|
| `Qwen.Dockerfile` | 图像工作流 worker 镜像。基于 `runpod/worker-comfyui:5.8.6-base`，烤入 art-venture / KJNodes / RMBG 自定义节点 |
| `Wan.Dockerfile` | 视频工作流 worker 镜像。同一 base，烤入 Easy-Use / WanMoeKSampler(SplitSigmasAtT) / art-venture / KJNodes / Custom-Scripts / Frame-Interpolation，并预下载 RIFE `rife49.pth`（serverless 自动下载不持久，故烤进镜像） |

## 部署到 RunPod Serverless（要点）

1. RunPod 新建 Serverless Endpoint，选择 `Deploy from GitHub` 进行部署，没有 connect github 的话先在 RunPod 个人设置里 connect github。
2. 选择对应的 Github 仓库，dc8683/comfyui-runpod，分支（Branch）选择 main，Dockerfile path 根据 Endpoint 类型选择 `Qwen.Dockerfile` 或 `Wan.Dockerfile`，然后点击 Deploy。
3. 其它配置，Endpoint type 选择 `Queue`，Worker type 选择 `GPU`，GPU configuration 根据情况选择，Environment variables 里比较重要的是填入 S3 相关的环境变量，[详情链接](https://docs.runpod.io/serverless/development/environment-variables#s3-bucket-configuration)，主要就是三个环境变量，`BUCKET_ENDPOINT_URL`、`BUCKET_ACCESS_KEY_ID`、`BUCKET_SECRET_ACCESS_KEY`，都是从 cloudflare R2 里获取的，填入后点击 Deploy 即可。
4. 部署后，还需要修改的配置就是在 Endpoint - Manage - Edit Endpoint 里，修改 `Advanced` 配置，比较核心的是选择 Network volumes（可多选），选择 Network volumes 后，Data Center 将被锁定在 Network volumes 所在的 Data Center；Minimum CUDA version 选择 `12.6`；Enabled GPU types 基本上可以全部勾选，以下是其它核心的参数配置
    - `Max workers`: 可并发的 worker 上限，兼做成本刹车
    - `Active workers`: 常驻热 worker 数，24h 计费但零冷启动
    - `Idle timeout`: 跑完一单后 worker 还热着待命多久（这段也计费），默认 5s
    - `Enable execution timeout`: 是否启用执行超时，单任务最长运行，超时即失败停机，默认 600s
    - `Queue delay`: 队列延迟，默认 0s，若队列里有任务，延迟时间内不再拉新 worker，避免频繁拉起 worker 导致成本上升

## 克隆与 SSH（重要）

本仓库走 SSH 别名 `github-dc8683`（多账号隔离 + 经 `ssh.github.com:443`），其 URL `git@github-dc8683:dc8683/comfyui-runpod.git` 写在父仓库 `comfyui-lab` 的 `.gitmodules` 里。**任意机器克隆 / 更新前，`~/.ssh/config` 必须有该别名**，否则拉不动（直连 `github.com:22` 在本网络被挡）：

```sshconfig
Host github-dc8683
  HostName ssh.github.com
  User git
  Port 443
  IdentityFile ~/.ssh/id_ed25519_account_dc8683
  IdentitiesOnly yes
  # 本机额外经本地代理（视网络环境而定）：
  # ProxyCommand nc -x 127.0.0.1:7897 -X 5 %h %p
```

连子模块一起克隆父仓库：

```bash
git clone --recurse-submodules git@github-dc8683:dc8683/comfyui-lab.git
# 已克隆过父仓库则：
git submodule update --init
```

## 日常

```bash
# 在父仓库 comfyui-lab/ 下：
cd comfyui-runpod
# 改动 → 提交 → 推送（子仓库自身历史）
git add . && git commit -m "..." && git push
# 让父仓库记录这次进展（推进指针）：
cd .. && git add comfyui-runpod && git commit -m "chore: bump comfyui-runpod"
```
