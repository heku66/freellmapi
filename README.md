# 🐳 freellmapi-docker

> Docker 部署方案 for [FreeLLMAPI](https://github.com/tashfeenahmed/freellmapi)  
> ✅ Node.js 20+ | ✅ Alpine 轻量 | ✅ GHCR 自动发布 | ✅ 健康检查 | ✅ 数据持久化

## 🚀 快速开始

### 方式 1：Docker Compose（推荐）

```bash
# 1. 克隆本仓库
git clone https://github.com/YOUR_USERNAME/freellmapi-docker.git
cd freellmapi-docker

# 2. 配置环境变量（生成加密密钥）
cp .env.example .env
echo "ENCRYPTION_KEY=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")" > .env

# 3. 启动服务
docker compose up -d

# 4. 查看状态
docker compose ps
docker compose logs -f freellmapi

# 5. 访问面板
open http://localhost:3001
