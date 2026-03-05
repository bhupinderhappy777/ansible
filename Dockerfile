FROM fedora:43

# Metadata
LABEL org.opencontainers.image.title="ansible-dev-setup" \
      org.opencontainers.image.description="Container to run ansible-pull against a dotfiles repo" \
      org.opencontainers.image.licenses="MIT"

# Build-time arguments (can be overridden with --build-arg)
ARG REPO_URL=https://github.com/bhupinderhappy777/ansible
ARG REPO_REF=dotfiles
ARG SKIP_TAGS=gui
ARG PLAYBOOK=dev_env_setup.yml

# Expose sensible defaults as environment variables (runtime override with -e)
ENV PATH="/root/.local/bin:${PATH}" \
    REPO_URL="${REPO_URL}" \
    REPO_REF="${REPO_REF}" \
    SKIP_TAGS="${SKIP_TAGS}" \
    PLAYBOOK="${PLAYBOOK}" \
    ANSIBLE_VAULT_PASSWORD=""

# Install OS packages and pipx in a single layer and clean cache
RUN dnf -y --setopt=install_weak_deps=False install \
        git \
        openssh-clients \
        python3-pip \
        python3-virtualenv \
        pipx \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# Install a pinned Ansible via pipx for reproducibility
RUN pipx install --include-deps ansible;

WORKDIR /root

# Entrypoint builds its args from runtime environment variables so
# the repository, ref, tags and playbook are configurable with
# `docker run -e REPO_URL=... -e REPO_REF=...` without rebuilding.
# Uses ANSIBLE_VAULT_PASSWORD
ENTRYPOINT ["sh", "-c", "if [ -n \"${ANSIBLE_VAULT_PASSWORD}\" ]; then \
    trap 'rm -f /tmp/.vp' EXIT INT TERM; \
    echo \"${ANSIBLE_VAULT_PASSWORD}\" > /tmp/.vp && \
    exec ansible-pull -U ${REPO_URL} -C ${REPO_REF} -i localhost, --skip-tags ${SKIP_TAGS} --vault-id /tmp/.vp ${PLAYBOOK}; \
    else \
    exec ansible-pull -U ${REPO_URL} -C ${REPO_REF} -i localhost, --skip-tags ${SKIP_TAGS} ${PLAYBOOK}; \
    fi"]

# No default CMD required; allow overrides if desired
CMD []