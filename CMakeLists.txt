cmake_minimum_required(VERSION 3.0)
project(FTPSProject)

# 设置C标准
set(CMAKE_C_STANDARD 99)

# OpenSSL库
find_package(OpenSSL REQUIRED)
include_directories(${OPENSSL_INCLUDE_DIR})

# 编译client
add_executable(client
    client/main.c
    client/ftps_client.c
    client/ssl_utils.c
    client/network_utils.c
    client/command_handler.c
    client/file_transfer.c
    client/thread_pool.c
    client/logger.c
)

target_link_libraries(client pthread ${OPENSSL_LIBRARIES})

# 编译service
add_executable(service
    service/main.c
    service/ftps_server.c
    service/ssl_utils.c
    service/network_utils.c
    service/command_handler.c
    service/file_transfer.c
    service/thread_pool.c
    service/logger.c
)

target_link_libraries(service pthread ${OPENSSL_LIBRARIES})