#!/bin/bash

# 创建 client 目录并进入
mkdir -p client
cd client

# 创建客户端文件
touch main.c
touch ftps_client.h ftps_client.c
touch ssl_utils.h ssl_utils.c
touch network_utils.h network_utils.c
touch command_handler.h command_handler.c
touch file_transfer.h file_transfer.c
touch thread_pool.h thread_pool.c
touch logger.h logger.c

# 返回项目根目录
cd ..

# 创建 service 目录并进入
mkdir -p service
cd service

# 创建服务端文件
touch main.c
touch ftps_server.h ftps_server.c
touch ssl_utils.h ssl_utils.c
touch network_utils.h network_utils.c
touch command_handler.h command_handler.c
touch file_transfer.h file_transfer.c
touch thread_pool.h thread_pool.c
touch logger.h logger.c

# 返回项目根目录
cd ..

# 创建其他文件
touch CMakeLists.txt
touch README.md

echo "所有文件和目录已成功创建。"
