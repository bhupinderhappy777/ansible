# Variables
PLAYBOOK = site.yml
LOG_DIR = logs
TIMESTAMP = $(shell date +%F_%H-%M)

.PHONY: help lint bootstrap security all clean

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

lint: ## Run ansible-lint and save to a log file
	@mkdir -p $(LOG_DIR)
	ansible-lint $(PLAYBOOK) | tee $(LOG_DIR)/lint-$(TIMESTAMP).log

bootstrap: ## Run the bootstrap role to setup management node and target users
	@mkdir -p $(LOG_DIR)
	ansible-playbook $(PLAYBOOK) -t bootstrap | tee $(LOG_DIR)/bootstrap-$(TIMESTAMP).log

security: ## Run the security hardening tasks and updates
	@mkdir -p $(LOG_DIR)
	ansible-playbook $(PLAYBOOK) -t security | tee $(LOG_DIR)/security-$(TIMESTAMP).log

all: ## Run the entire playbook (Full Deploy)
	@mkdir -p $(LOG_DIR)
	ansible-playbook $(PLAYBOOK) | tee $(LOG_DIR)/full-deploy-$(TIMESTAMP).log

clean: ## Remove all log files
	rm -rf $(LOG_DIR)/*.log
