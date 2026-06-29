FROM runpod/worker-comfyui:5.8.6-base

RUN git clone https://github.com/yolain/ComfyUI-Easy-Use /comfyui/custom_nodes/comfyui-easy-use && pip install -r /comfyui/custom_nodes/comfyui-easy-use/requirements.txt || true
RUN git clone https://github.com/stduhpf/ComfyUI-WanMoeKSampler /comfyui/custom_nodes/SplitSigmasAtT && pip install -r /comfyui/custom_nodes/SplitSigmasAtT/requirements.txt || true
RUN git clone https://github.com/sipherxyz/comfyui-art-venture /comfyui/custom_nodes/comfyui-art-venture && pip install -r /comfyui/custom_nodes/comfyui-art-venture/requirements.txt || true
RUN git clone https://github.com/kijai/ComfyUI-KJNodes /comfyui/custom_nodes/comfyui-kjnodes && pip install -r /comfyui/custom_nodes/comfyui-kjnodes/requirements.txt || true
RUN git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts /comfyui/custom_nodes/comfyui-custom-scripts && pip install -r /comfyui/custom_nodes/comfyui-custom-scripts/requirements.txt || true
RUN git clone https://github.com/Fannovel16/ComfyUI-Frame-Interpolation /comfyui/custom_nodes/comfyui-frame-interpolation && pip install -r /comfyui/custom_nodes/comfyui-frame-interpolation/requirements.txt || true
# 预下载 RIFE VFI 模型（serverless 自动下载脆弱/不持久，故烤进镜像；无 || true：下载失败应让构建直接失败）
RUN mkdir -p /comfyui/custom_nodes/comfyui-frame-interpolation/ckpts/rife && \
    wget -O /comfyui/custom_nodes/comfyui-frame-interpolation/ckpts/rife/rife49.pth \
    "https://github.com/Fannovel16/ComfyUI-Frame-Interpolation/releases/download/models/rife49.pth"
