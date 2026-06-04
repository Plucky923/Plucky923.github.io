.PHONY: server deploy build clean draft new

# 显式使用本地安装的 Hugo 0.162.1，避免与 Homebrew 旧版本冲突
HUGO := $(HOME)/.local/bin/hugo

# 本地预览（包含草稿，自动清理缓存）
server:
	$(HUGO) server -D --gc

# 生产构建
build:
	$(HUGO) --gc --minify

# 清理项目构建产物（仅删除项目内目录，不影响 Hugo 全局模块缓存）
clean:
	rm -rf public/ resources/_gen/

# 部署：构建、提交并推送到 main，由 GitHub Actions 自动发布到 Pages
# 自动处理 SOCKS 代理：关闭代理 → push → 重新开启代理
deploy: build
	@echo "=== Deploying... ==="
	@if [ -n "$$(git status --porcelain)" ]; then \
		git add -A && \
		git commit -m "deploy: update site $$(date '+%Y-%m-%d %H:%M:%S')"; \
	else \
		echo "Nothing to commit..."; \
	fi
	@echo "Disabling SOCKS proxy for Git push..."
	@networksetup -setsocksfirewallproxystate Wi-Fi off
	git push origin main || { \
		echo "Push failed, re-enabling proxy..."; \
		networksetup -setsocksfirewallproxystate Wi-Fi on; \
		exit 1; \
	}
	@echo "Re-enabling SOCKS proxy..."
	@networksetup -setsocksfirewallproxystate Wi-Fi on
	@echo "=== Push done. Check GitHub Actions for deploy status ==="

# 创建一篇新文章（默认标题为 Untitled）
# 用法：make new TITLE="My Post Title"
TITLE ?= Untitled

new:
	@mkdir -p content/post
	@slug=$$(echo "$(TITLE)" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-'); \
	dir="content/post/$$(date +%Y-%m-%d)-$$slug"; \
	mkdir -p "$$dir"; \
	file="$$dir/index.md"; \
	echo "---" > "$$file"; \
	echo "title: \"$(TITLE)\"" >> "$$file"; \
	echo "date: $$(date +%Y-%m-%dT%H:%M:%S%z)" >> "$$file"; \
	echo "draft: true" >> "$$file"; \
	echo "description: \"\"" >> "$$file"; \
	echo "tags: []" >> "$$file"; \
	echo "---" >> "$$file"; \
	echo "" >> "$$file"; \
	echo "Created $$file"
