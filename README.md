一个基于 Docker Compose 的高可用 Flask + MySQL 服务，通过 Nginx 实现负载均衡。
浏览器
   ↓
Nginx
 ↓   ↓
Flask Flask
   ↓
 MySQL

一键启动 docker-compose up -d
验证方式 curl localhost:8080
技术栈
Docker
Docker Compose
Nginx
Flask
MySQL
