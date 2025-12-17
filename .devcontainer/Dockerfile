FROM node:20

ARG TZ
ENV TZ="$TZ"

ARG CLAUDE_CODE_VERSION=latest

# Install basic development tools, iptables/ipset, and build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
  less \
  git \
  procps \
  sudo \
  fzf \
  zsh \
  man-db \
  unzip \
  gnupg2 \
  gh \
  iptables \
  ipset \
  iproute2 \
  dnsutils \
  aggregate \
  jq \
  nano \
  vim \
  # Build dependencies for Python and Rust
  build-essential \
  libssl-dev \
  pkg-config \
  clang \
  # Mold linker for Rust
  mold \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# ============================================================
# Go Installation
# ============================================================
ARG GO_VERSION=1.23.4
RUN ARCH=$(dpkg --print-architecture) && \
  wget -q "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz" && \
  tar -C /usr/local -xzf "go${GO_VERSION}.linux-${ARCH}.tar.gz" && \
  rm "go${GO_VERSION}.linux-${ARCH}.tar.gz"
ENV PATH=$PATH:/usr/local/go/bin:/home/node/go/bin

# Install golangci-lint
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /usr/local/bin

# ============================================================
# Terraform Installation
# ============================================================
ARG TERRAFORM_VERSION=1.9.8
RUN ARCH=$(dpkg --print-architecture) && \
  curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip" -o tf.zip && \
  unzip -q tf.zip && \
  mv terraform /usr/local/bin/ && \
  rm tf.zip

# ============================================================
# Trivy Security Scanner
# ============================================================
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Ensure default node user has access to /usr/local/share
RUN mkdir -p /usr/local/share/npm-global && \
  chown -R node:node /usr/local/share

ARG USERNAME=node

# Persist bash history.
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  && mkdir /commandhistory \
  && touch /commandhistory/.bash_history \
  && chown -R $USERNAME /commandhistory

# Set `DEVCONTAINER` environment variable to help with orientation
ENV DEVCONTAINER=true

# Create workspace and config directories and set permissions
RUN mkdir -p /workspace /home/node/.claude && \
  chown -R node:node /workspace /home/node/.claude

WORKDIR /workspace

ARG GIT_DELTA_VERSION=0.18.2
RUN ARCH=$(dpkg --print-architecture) && \
  wget "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  sudo dpkg -i "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  rm "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb"

# Set up non-root user
USER node

# Install global packages
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# Set the default shell to zsh rather than sh
ENV SHELL=/bin/zsh

# Set the default editor and visual
ENV EDITOR=nano
ENV VISUAL=nano

# ============================================================
# Rust Installation (user-level via rustup)
# ============================================================
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
ENV PATH=$PATH:/home/node/.cargo/bin

# Configure Rust to use Mold linker
RUN mkdir -p ~/.cargo && \
  echo '[target.x86_64-unknown-linux-gnu]' >> ~/.cargo/config.toml && \
  echo 'linker = "clang"' >> ~/.cargo/config.toml && \
  echo 'rustflags = ["-C", "link-arg=-fuse-ld=mold"]' >> ~/.cargo/config.toml

# ============================================================
# Python via uv (user-level)
# ============================================================
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH=$PATH:/home/node/.local/bin

# Install Python 3.13 via uv and set as default
RUN /home/node/.local/bin/uv python install 3.13 && \
  /home/node/.local/bin/uv python pin 3.13

# Install Ruff (Python linter)
RUN curl -LsSf https://astral.sh/ruff/install.sh | sh

# ============================================================
# Bun Installation (user-level)
# ============================================================
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH=$PATH:/home/node/.bun/bin

# ============================================================
# pnpm Installation
# ============================================================
RUN npm install -g pnpm

# Default powerline10k theme
ARG ZSH_IN_DOCKER_VERSION=1.2.0
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v${ZSH_IN_DOCKER_VERSION}/zsh-in-docker.sh)" -- \
  -p git \
  -p fzf \
  -a "source /usr/share/doc/fzf/examples/key-bindings.zsh" \
  -a "source /usr/share/doc/fzf/examples/completion.zsh" \
  -a "export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  -x

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

# Install Beads (AI-native issue tracking)
# The installer puts bd in ~/.local/bin which is already in PATH
RUN curl -sSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash

# Copy and set up firewall script
COPY init-firewall.sh /usr/local/bin/
USER root
RUN chmod +x /usr/local/bin/init-firewall.sh && \
  echo "node ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" > /etc/sudoers.d/node-firewall && \
  chmod 0440 /etc/sudoers.d/node-firewall
USER node
