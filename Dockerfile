# Stage 1: build environment with dev tools
FROM python:3.11-slim as builder

# Install system build tools needed for Python packages
RUN apt-get update && apt-get install -y \
    git build-essential libssl-dev libffi-dev libxml2-dev libxslt1-dev \
    && rm -rf /var/lib/apt/lists/*

# Upgrade packaging tools
RUN pip install --upgrade pip setuptools wheel

# Clone SET repository
RUN git clone https://github.com/trustedsec/social-engineer-toolkit /opt/setoolkit
WORKDIR /opt/setoolkit

# Install dependencies (will error out with details if a package fails)
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir .

# Stage 2: final runtime
FROM python:3.11-slim
RUN apt-get update && apt-get install -y libssl-dev libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy built SET from builder
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /opt/setoolkit /opt/setoolkit

WORKDIR /opt/setoolkit
EXPOSE 10000

CMD ["setoolkit", "--cli", "--web-host", "0.0.0.0", "--web-port", "10000"]
