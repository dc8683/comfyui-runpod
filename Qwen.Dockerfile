FROM runpod/worker-comfyui:5.8.6-base

RUN git clone https://github.com/sipherxyz/comfyui-art-venture /comfyui/custom_nodes/comfyui-art-venture && pip install -r /comfyui/custom_nodes/comfyui-art-venture/requirements.txt || true
RUN git clone https://github.com/kijai/ComfyUI-KJNodes /comfyui/custom_nodes/comfyui-kjnodes && pip install -r /comfyui/custom_nodes/comfyui-kjnodes/requirements.txt || true
RUN git clone https://github.com/1038lab/ComfyUI-RMBG /comfyui/custom_nodes/comfyui-rmbg && pip install -r /comfyui/custom_nodes/comfyui-rmbg/requirements.txt || true
