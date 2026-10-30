ARG PLAYWRIGHT_VERSION=1.64.1
FROM mcr.microsoft.com/playwright:v${PLAYWRIGHT_VERSION}-noble

# ARG declared before FROM is out of scope here, so declare it again.
ARG PLAYWRIGHT_VERSION
# Pin this (e.g. 0.1.0) for reproducible builds: `npm view @playwright/cli version`
ARG PLAYWRIGHT_CLI_VERSION=latest

ENV PLAYWRIGHT_VERSION=${PLAYWRIGHT_VERSION} \
    NPM_CONFIG_UPDATE_NOTIFIER=false \
    NPM_CONFIG_FUND=false \
    NPM_CONFIG_AUDIT=false

# Playwright CLI for browser automation (npm cache is reused between builds)
RUN --mount=type=cache,target=/root/.npm \
    npm install --global @playwright/cli@${PLAYWRIGHT_CLI_VERSION}

# Entrypoint: installs dependencies only when package-lock.json changes.
# sed strips Windows CRLF line endings so the script always runs on Linux.
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN sed -i 's/\r$//' /usr/local/bin/entrypoint.sh \
    && chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /workspace

ENTRYPOINT ["entrypoint.sh"]
CMD ["bash"]