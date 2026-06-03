.PHONY: server deploy build clean draft

# 本地预览（包含草稿，自动清理缓存）
server:
	hugo server -D --gc

# 生产构建
build:
	hugo --gc --minify

# 清理构建产物和缓存
clean:
	rm -rf public/ resources/_gen/

# 部署：构建、提交并推送到 main，由 GitHub Actions 自动发布到 Pages
deploy: build
	@echo "=== Deploying... ==="
	@if [ -n "$$(git status --porcelain)" ]; then \
		git add -A && \
		git commit -m "deploy: update site $$(date '+%Y-%m-%d %H:%M:%S')" && \
		git push origin main; \
		echo "=== Push done. Check GitHub Actions for deploy status ==="; \
	else \
		echo "Nothing to commit, pushing latest changes..."; \
		git push origin main; \
	fi
