#!/bin/bash

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$SCRIPT_DIR"
JAR_FILE="target/xiaozhi-esp32-api.jar"  # 根据你的实际 JAR 文件名修改
LOG_FILE="$APP_DIR/setup.log"

# 检查是否是 root 用户（可选）
# if [ "$EUID" -ne 0 ]; then
#     echo "请以 root 权限运行此脚本"
#     exit 1
# fi

# 获取当前进程中的 Java 进程 PID（根据你项目的类名或 JAR 名匹配）
function kill_existing_java() {
    echo "正在查找并终止现有的 Java 进程..."
    ps aux | grep "[j]ava" | grep "$JAR_FILE" | awk '{print $2}' | xargs -r kill -9
    echo "旧的 Java 进程已终止。"
}

# 启动 Java 应用
function start_app() {
    cd "$APP_DIR" || exit
    echo "启动应用: java -jar $JAR_FILE"
    nohup java -jar "$JAR_FILE" >> "$LOG_FILE" 2>&1 &
    echo "应用已启动，日志输出到 $LOG_FILE"
}

# 执行构建
function build_app() {
    echo "开始构建项目..."
    cd "$APP_DIR" || exit
    mvn clean package
    if [ $? -eq 0 ]; then
        echo "构建成功！"
    else
        echo "构建失败，退出..."
        exit 1
    fi
}

# 主逻辑
if [ "$1" == "rebuild" ]; then
    echo "执行 rebuild 模式：先构建再启动..."
    build_app
    kill_existing_java
    start_app
else
    echo "执行正常启动模式..."
    kill_existing_java
    start_app
fi