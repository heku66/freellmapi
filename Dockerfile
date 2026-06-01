# =============================
# Stage 1: 构建依赖
# =============================
FROM node:20-alpine AS builder

# 安装 Git（Alpine 基础镜像不含 git）
RUN apk add --no-cache git

# 设置工作目录
WORKDIR /opt/freellmapi

# 克隆项目源码（可替换为你的 fork 或特定分支）
RUN git clone --depth 1 https://github.com/tashfeenahmed/freellmapi.git . 

# 复制 package 文件并安装全部依赖（含 dev，用于 build）
COPY package*.json ./
RUN npm ci

# 复制全部源码（确保与克隆版本一致，也可省略此步）
COPY . .

# 创建 .env 占位文件（实际值通过运行时环境变量注入）
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# 执行构建
RUN npm run build

# =============================
# Stage 2: 生产运行镜像
# =============================
FROM node:20-alpine AS runner

# 安装少量必要工具（wget 用于健康检查）
RUN apk add --no-cache wget

# 创建非特权用户（安全最佳实践）
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs

# 设置工作目录
WORKDIR /opt/freellmapi

# 从 builder 阶段复制构建产物
COPY --from=builder --chown=nodejs:nodejs /opt/freellmapi ./

# 仅安装生产依赖（减小镜像体积）
RUN npm ci --omit=dev --ignore-scripts

# 暴露应用端口（freellmapi 面板默认 3001）
EXPOSE 3001

# 健康检查（根据项目实际接口调整路径）
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3001/health || exit 1

# 切换为非特权用户运行
USER nodejs

# 设置默认环境变量（可被 docker run -e 覆盖）
ENV PORT=3001 \
    NODE_ENV=production

# 启动命令
CMD ["npm", "run", "dev"]
