# SRE Demo — 高可用 Flask 服务

> 基于 Docker Compose 的可观测性实践项目，涵盖负载均衡、健康检查、监控告警全链路。

```
Internet
    │
  Nginx  ←── 负载均衡 / 健康剔除
  ┌─┴─┐
Flask1  Flask2   ←── 双实例，最少连接算法
  └─┬─┘
 MySQL              ←── 持久化存储
    │
Prometheus ──→ Grafana   ←── 指标采集 + 可视化
```

## 技术栈

| 层次 | 组件         | 用途                                 |
| ---- | ------------ | ------------------------------------ |
| 网关 | Nginx Alpine | 反向代理、负载均衡、访问日志（JSON） |
| 应用 | Flask × 2    | 业务逻辑，暴露 `/metrics` 端点       |
| 存储 | MySQL 5.7    | 关系型数据，Volume 持久化            |
| 采集 | Prometheus   | 15s 间隔拉取指标，保留 7 天          |
| 展示 | Grafana      | 实时 Dashboard，告警规则             |

## 快速开始

```bash
# 1. 克隆仓库
git clone https://github.com/<your-username>/sre-demo.git && cd sre-demo

# 2. 配置环境变量（不要把真实密码提交到 Git）
cp .env.example .env
vim .env

# 3. 一键启动
docker-compose up -d

# 4. 验证服务
curl localhost:8080/health          # 应用健康检查
curl localhost:8080/                # 业务接口
open http://localhost:3000          # Grafana（admin / 见 .env）
open http://localhost:9090          # Prometheus
```

## 项目结构

```
sre-demo/
├── docker-compose.yml       # 服务编排主文件
├── .env.example             # 环境变量模板（不含真实密码）
├── nginx/
│   └── nginx.conf           # upstream 池 + JSON 访问日志
├── mysql/
│   └── init.sql             # 初始化 DDL
├── app/
│   ├── Dockerfile
│   └── app.py               # Flask 应用（含 /health /metrics）
└── monitoring/
    ├── prometheus.yml        # 抓取配置
    └── grafana/
        └── provisioning/    # Dashboard 自动导入
```

## 关键设计决策

**为什么用 `least_conn` 而不是默认的轮询？**
轮询假设每个请求耗时相同，而真实场景中慢请求会堆积在某个实例上。`least_conn` 将新连接路由到当前活跃连接最少的实例，在请求耗时不均时表现更好。

**为什么 MySQL 密码不放在 `docker-compose.yml` 里？**
硬编码密码一旦仓库设为 public 就会泄露。通过 `.env` 文件注入，并在 `.gitignore` 中排除，是 12-Factor App 的标准做法。

**为什么 Prometheus 只保留 7 天？**
阿里云 2C2G 服务器磁盘有限。7 天足够排查大多数线上问题，超出部分可导出到对象存储（OSS）归档。

**healthcheck `start_period` 的意义？**
MySQL 启动需要约 20-30s 初始化数据目录，没有 `start_period` 时健康检查会连续失败并触发重启循环（restart loop）。`start_period: 30s` 让容器在这段时间内的失败不计入重试次数。

## 可观测性

服务启动后，Grafana 自动导入以下 Dashboard：

- **请求速率（RPS）**：`rate(http_requests_total[1m])`
- **错误率**：`rate(http_requests_total{status=~"5.."}[1m])`
- **P99 延迟**：`histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m]))`
- **实例存活**：`up{job="flask-instances"}`

## 压测验证

```bash
# 安装 hey（轻量 HTTP 压测工具）
go install github.com/rakyll/hey@latest

# 100 并发，持续 30s
hey -c 100 -z 30s http://localhost:8080/

# 观察 Grafana 中两个实例的 RPS 是否均衡
```

## 已知局限 & 后续规划

- [ ] 无 Kubernetes：受服务器资源限制，未部署 K8s；可用 `kind` 在本地模拟
- [ ] 无 TLS：生产环境需在 Nginx 配置 Let's Encrypt 证书
- [ ] MySQL 单点：可升级为主从复制或迁移至云数据库 RDS
- [ ] 日志收集：Nginx JSON 日志已结构化，下一步接入 Loki 实现日志聚合
