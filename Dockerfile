FROM ollama/ollama:latest AS full
RUN ollama serve & \
    pid=$!; \
    for i in $(seq 1 60); do \
        if ollama list >/dev/null 2>&1; then break; fi; \
        sleep 1; \
    done; \
    ollama pull qwen3:14b && \
    ollama pull nomic-embed-text && \
    ollama list && \
    kill $pid || true
RUN rm -rf /usr/lib/ollama/mlx_cuda_v13 \
           /usr/lib/ollama/cuda_v12 \
           /usr/lib/ollama/cuda_v13 \
           /usr/lib/ollama/vulkan \
           /usr/lib/ollama/include

FROM ubuntu:24.04
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates libstdc++6 libgomp1 && \
    rm -rf /var/lib/apt/lists/*
COPY --from=full /usr/bin/ollama   /usr/bin/ollama
COPY --from=full /usr/lib/ollama   /usr/lib/ollama
COPY --from=full /root/.ollama     /root/.ollama
ENV OLLAMA_HOST=0.0.0.0:11434 \
    OLLAMA_MODELS=/root/.ollama/models
EXPOSE 11434
ENTRYPOINT ["/usr/bin/ollama"]
CMD ["serve"]
