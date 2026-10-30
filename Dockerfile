
ARG PLAYWRIGHT_VERSION=1.64.1

FROM mcr.microsoft.com/playwright:v${PLAYWRIGHT_VERSION}-noble

ARG INSTALL_CLAUDE=false
ARG INSTALL_OPENCODE=false

ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_ENV=development
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /workspace

# Install Claude Code.
RUN if [ "$INSTALL_CLAUDE" = "true" ]; then \
    curl -fsSL https://claude.ai/install.sh | bash; \
    fi

# Install OpenCode.
RUN if [ "$INSTALL_OPENCODE" = "true" ]; then \
    npm install -g @opencode/cli; \
    fi

# Install Playwright CLI.
RUN npm install -g @playwright/cli

CMD ["bash"]
