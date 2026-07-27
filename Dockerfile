# Ollama with qwen2.5:3b + nomic-embed-text baked in
FROM ollama/ollama:latest

# Models to pre-pull into the image
ENV MODELS="qwen2.5:3b nomic-embed-text"

# Start the server temporarily, pull the models, then shut it down.
# This bakes the model weights into the image layer so the container
# is ready to serve immediately (no download on first run).
RUN ollama serve & \
    pid=$!; \
    # wait for the API to come up
    for i in $(seq 1 30); do \
        if ollama list >/dev/null 2>&1; then break; fi; \
        sleep 1; \
    done; \
    ollama pull qwen2.5:3b && \
    ollama pull nomic-embed-text && \
    ollama list && \
    kill $pid

# Ollama API port
EXPOSE 11434

# Required for ECS (both awsvpc and bridge networking): bind to all
# interfaces, not loopback, so the ALB / other tasks can reach the API.
ENV OLLAMA_HOST=0.0.0.0

# The base image's ENTRYPOINT is "ollama"; default it to "serve"
CMD ["serve"]
