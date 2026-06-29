# comfyui-runpod

面向 **RunPod Serverless** 的 ComfyUI worker 镜像与部署文档，配合上游中台 [comfyui-lab](https://github.com/dc8683/comfyui-lab)（调试 / 固化 ComfyUI workflow）使用。

本仓库以 **git submodule** 形式挂在 `comfyui-lab` 下的 `comfyui-runpod/` 目录，但保持独立历史：子仓库的提交会被父仓库以「指针」形式记录，父仓库的提交不影响子仓库。

## 内容

| 文件 | 用途 |
|---|---|
| `Image.Dockerfile` | 图像工作流 worker 镜像。基于 `runpod/worker-comfyui:5.8.6-base`，烤入 art-venture / KJNodes / RMBG 自定义节点 |
| `Video.Dockerfile` | 视频工作流 worker 镜像。同一 base，烤入 Easy-Use / WanMoeKSampler(SplitSigmasAtT) / art-venture / KJNodes / Custom-Scripts / Frame-Interpolation，并预下载 RIFE `rife49.pth`（serverless 自动下载不持久，故烤进镜像） |

## 构建

```bash
docker build -f Image.Dockerfile -t <registry>/comfyui-runpod-image:<tag> .
docker build -f Video.Dockerfile -t <registry>/comfyui-runpod-video:<tag> .
docker push <registry>/comfyui-runpod-image:<tag>
```

## 部署到 RunPod Serverless（要点）

1. 把镜像推到容器 registry（Docker Hub / GHCR 等）。
2. RunPod 新建 Serverless Endpoint，镜像指向上面的 tag。
3. **CUDA 版本过滤**：worker-comfyui 5.8.x 需较新的 CUDA（约 12.6+）。若 endpoint 落到老驱动主机，会一直 `In Queue` / `initializing` 崩溃循环——务必在 endpoint 设置里加 CUDA 版本过滤。
4. **冷启动**：大镜像 + scale-to-zero，首次在每台新主机要拉数十 GB，冷启动慢。需要稳定低延迟可设 `workersMin ≥ 1` 常驻，或改用网络卷挂模型。

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
