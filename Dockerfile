# Dockerfile

# 重要：在这里为 ZOTERO_PDF2ZH_FROM_IMAGE 提供一个默认值

ARG ZOTERO_PDF2ZH_FROM_IMAGE=ubuntu:22.04
FROM ${ZOTERO_PDF2ZH_FROM_IMAGE}


ARG ZOTERO_PDF2ZH_SERVER_FILE_DOWNLOAD_URL

WORKDIR /app

# --- apt 包管理相关（可选，根据你的环境决定是否取消注释）---
# 如果在中国大陆环境打包，取消注释以下行以使用阿里云的 Debian 镜像源，加速 apt-get。
# RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources && \
#    sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources

# 更新 apt 包列表，并清理缓存以减小镜像大小。
RUN apt-get update && \
    rm -rf /var/lib/apt/lists/*

# --- Python 依赖安装 ---
# 注意：你的 Dockerfile 使用了 `uv pip install`。
# 如果 `uv` 没有预装在基础镜像中，你需要先安装它（例如：RUN pip install uv）。
# 这里假设 `uv` 已经可用，或者你的基础镜像包含了它。

# 如果在中国大陆环境打包，取消注释以下行以使用清华大学的 PyPI 镜像源，加速 pip 安装。
# RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
#    pip config set global.extra-index-url "https://pypi.tuna.tsinghua.edu.cn/simple"

RUN apt-get update && apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/*
RUN python3 -m pip install --upgrade pip
RUN pip install --system -U flask waitress pypdf


# --- 添加应用程序文件 ---
# 从指定 URL 下载服务器文件并添加到 /app 目录。
ADD "${ZOTERO_PDF2ZH_SERVER_FILE_DOWNLOAD_URL}" /app/

# 修复 server.py 中的 Bug，用于在 Linux 环境下运行。
RUN sed -i '/path = path\.replace/ s/ #//' /app/server.py

# --- 容器配置 ---
# 暴露应用程序监听的端口。
EXPOSE 8888

# 定义容器启动时执行的命令。
CMD ["python", "server.py", "8888"]
