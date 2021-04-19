.DEFAULT_GOAL := help

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

down: ## Stop containers
	@docker-compose down

up: ## Start containers (dev only!)
	@docker-compose up

nvidia: ## Start containers with nVidia runtime (needs nvidia-container-toolkit!)
	@docker-compose -f docker-compose.yml -f docker-compose.nvidia.yml up -d