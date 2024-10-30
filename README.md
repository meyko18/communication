# 0. 资料区

## 构建过程详解

### CMake 配置过程

运行 `cmake ..` 命令时会发生以下操作：

1. **配置阶段**：

   - **读取 CMakeLists.txt**：CMake 从指定的目录（上级目录，由 `..` 表示）读取 `CMakeLists.txt` 文件。
   - **确定生成器**：根据系统和可用的编译器自动选择最适合的生成器（如 Makefiles, Ninja, Visual Studio 等）。
   - **检查编译器和依赖**：检查系统上的编译器（如 gcc, clang, msvc 等）及项目所需的任何依赖。
   - **生成构建文件**：基于 `CMakeLists.txt` 中的指令，CMake 生成必要的构建文件（如 Makefiles），这些文件指定了如何编译和链接项目。
2. **生成过程**：

   - 此过程不涉及实际编译，仅为编译过程准备和配置环境。

### Make 编译过程

在 `build` 目录中运行 `make` 命令后会进行如下操作：

1. **编译阶段**：

   - **执行 Makefile**：使用 CMake 生成的 Makefile 来编译源代码。
   - **编译源文件**：根据 `CMakeLists.txt` 中的设置（如编译器选项、包含的库等），编译源代码文件（例如 `helloworld.cpp`）。
   - **生成可执行文件**：链接编译后的对象文件（如果项目中包含多个源文件），生成最终的可执行文件（例如 `helloworld`）。
2. **输出**：

   - 如果编译成功，`make` 将在 `build` 目录中生成可执行文件。
   - 如果编译失败，将显示错误信息，指示失败原因。

# 1. FTPS

## 1.1 客户端流程图

+-----------------------------+
|        程序启动与初始化      |
+-------------+---------------+
              |
              v
+-----------------------------+
|     连接到 FTPS 服务器       |
+-------------+---------------+
              |
              v
+-----------------------------+
|         用户认证            |
+-------------+---------------+
              |
              v
+-----------------------------+
|   设置传输模式和加密级别     |
+-------------+---------------+
              |
              v
+-----------------------------+
|         文件操作            |
|  (LIST/RETR/STOR 等命令)     |
+-------------+---------------+
              |
              v
+-----------------------------+
|         结束会话            |
+-------------+---------------+
              |
              v
+-----------------------------+
|         程序退出            |
+-----------------------------+

## 1.2 服务端流程图

+-----------------------------+
|     程序启动与初始化         |
+-------------+---------------+
              |
              v
+-----------------------------+
|  初始化 SSL 库，加载证书等    |
+-------------+---------------+
              |
              v
+-----------------------------+
|   创建服务器套接字并监听      |
+-------------+---------------+
              |
              v
+-----------------------------+
|  等待并接受客户端连接（循环） |
+-------------+---------------+
              |
              v
+-----------------------------+
|     建立 SSL 会话（握手）     |
+-------------+---------------+
              |
              v
+-----------------------------+
|        用户认证（USER/PASS）  |
+-------------+---------------+
              |
              v
+-----------------------------+
|     进入命令处理循环（处理FTP命令） |
+-------------+---------------+
              |
              v
+-----------------------------+
|    根据命令执行相应操作     |
| （数据连接管理，文件传输等）|
+-------------+---------------+
              |
              v
+-----------------------------+
|   关闭连接并清理资源（单个客户端） |
+-------------+---------------+
              |
              v
+-----------------------------+
|   返回等待客户端连接的循环    |
+-----------------------------+

## 1.3 客户端大纲

| 序号 | 函数名称                         | 函数原型                                                                                   | 功能描述                                                |
| ---- | -------------------------------- | ------------------------------------------------------------------------------------------ | ------------------------------------------------------- |
| 1    | `load_client_config`           | `void load_client_config(const char *config_file);`                                      | 加载客户端配置，如服务器地址、端口、证书路径等。        |
| 2    | `initialize_ssl_client`        | `SSL_CTX *initialize_ssl_client(const char *cert_file);`                                 | 初始化SSL库，创建SSL上下文，加载客户端证书（如需要）。  |
| 3    | `connect_to_server`            | `int connect_to_server(const char *server_ip, int port);`                                | 创建套接字并连接到FTPS服务器。                          |
| 4    | `establish_ssl_client_session` | `SSL *establish_ssl_client_session(SSL_CTX *ctx, int sock);`                             | 在已连接的套接字上建立SSL会话，完成SSL握手。            |
| 5    | `authenticate_user`            | `int authenticate_user(SSL *ssl, const char *username, const char *password);`           | 通过发送 `USER`和 `PASS`命令进行用户认证。          |
| 6    | `set_protection_level`         | `int set_protection_level(SSL *ssl, const char *level);`                                 | 设置数据连接的保护级别（如 `PROT P`）。               |
| 7    | `send_command`                 | `int send_command(SSL *ssl, const char *cmd, const char *arg);`                          | 发送FTP命令和参数给服务器。                             |
| 8    | `receive_response`             | `int receive_response(SSL *ssl, char *buffer, size_t size);`                             | 接收服务器的响应消息。                                  |
| 9    | `parse_response_code`          | `int parse_response_code(const char *response);`                                         | 从服务器响应中解析出响应码。                            |
| 10   | `enter_passive_mode`           | `int enter_passive_mode(SSL *ssl, char *ip, int *port);`                                 | 发送 `PASV`命令，解析服务器返回的被动模式IP和端口。   |
| 11   | `establish_data_connection`    | `int establish_data_connection(const char *ip, int port, SSL_CTX *ctx, SSL **data_ssl);` | 建立数据连接并进行SSL握手。                             |
| 12   | `download_file`                | `int download_file(SSL *ssl_control, SSL *ssl_data, const char *filename);`              | 从服务器下载文件。                                      |
| 13   | `upload_file`                  | `int upload_file(SSL *ssl_control, SSL *ssl_data, const char *filename);`                | 向服务器上传文件。                                      |
| 14   | `close_ssl_session`            | `void close_ssl_session(SSL *ssl);`                                                      | 关闭SSL会话并释放相关资源。                             |
| 15   | `close_socket`                 | `void close_socket(int sockfd);`                                                         | 关闭套接字。                                            |
| 16   | `cleanup_ssl_client`           | `void cleanup_ssl_client(SSL_CTX *ctx);`                                                 | 释放SSL上下文，清理SSL库。                              |
| 17   | `handle_error`                 | `void handle_error(const char *message);`                                                | 处理错误，输出错误信息并进行必要的清理。                |
| 18   | `log_client_message`           | `void log_client_message(const char *format, ...);`                                      | 记录客户端运行状态和事件。                              |
| 19   | `thread_function`              | `void *thread_function(void *arg);`                                                      | 线程函数，用于处理并发的文件传输操作。                  |
| 20   | `start_file_transfer_thread`   | `int start_file_transfer_thread(const char *filename, int operation);`                   | 启动新的线程进行文件传输，`operation`指示上传或下载。 |
| 21   | `main`                         | `int main(int argc, char *argv[]);`                                                      | 程序入口，解析参数，启动客户端主流程。                  |

### 1.3.1 client 目录下的文件

1. `main.c`

   * 功能 ：客户端程序的入口，解析命令行参数，初始化并启动客户端主流程。
   * 内容 ：调用初始化函数，处理用户输入的命令，启动文件传输线程等。
2. `ftps_client.h`

   * 功能 ：客户端核心功能的头文件，声明主要的客户端函数和数据结构。
   * 内容 ：函数声明、宏定义、数据结构等。
3. `ftps_client.c`

   * 功能 ：实现客户端核心功能，如连接服务器、用户认证等。
   * 内容 ：`connect_to_server`、`authenticate_user`等函数的实现。
4. `ssl_utils.h`

   * 功能 ：SSL/TLS相关的工具函数的头文件。
   * 内容 ：SSL初始化、会话建立等函数的声明。
5. `ssl_utils.c`

   * 功能 ：实现SSL/TLS相关的工具函数。
   * 内容 ：`initialize_ssl_client`、`establish_ssl_client_session`等函数的实现。
6. `network_utils.h`

   * 功能 ：网络通信相关的工具函数的头文件。
   * 内容 ：创建套接字、连接服务器等函数的声明。
7. `network_utils.c`

   * 功能 ：实现网络通信相关的工具函数。
   * 内容 ：`create_socket`、`connect_to_server`等函数的实现。
8. `command_handler.h`

   * 功能 ：FTP命令处理相关函数的头文件。
   * 内容 ：发送和接收FTP命令、解析响应等函数的声明。
9. `command_handler.c`

   * 功能 ：实现FTP命令处理相关函数。
   * 内容 ：`send_command`、`receive_response`、`parse_response_code`等函数的实现。
10. `file_transfer.h`

    * 功能 ：文件传输相关函数的头文件。
    * 内容 ：上传、下载文件等函数的声明。
11. `file_transfer.c`

    * 功能 ：实现文件传输相关函数。
    * 内容 ：`download_file`、`upload_file`等函数的实现。
12. `thread_pool.h`

    * 功能 ：线程池或多线程处理相关的头文件。
    * 内容 ：线程函数、线程池管理等函数的声明。
13. `thread_pool.c`

    * 功能 ：实现线程池或多线程处理相关的函数。
    * 内容 ：`start_file_transfer_thread`、`thread_function`等函数的实现。
14. `logger.h`

    * 功能 ：日志记录相关函数的头文件。
    * 内容 ：日志记录函数的声明。
15. `logger.c`

    * 功能 ：实现日志记录相关函数。
    * 内容 ：`log_client_message`、`handle_error`等函数的实现。

## 1.4 服务端大纲

| 序号 | 函数名称                         | 函数原型                                                                                     | 功能描述                                                   |
| ---- | -------------------------------- | -------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| 1    | `load_server_config`           | `void load_server_config(const char *config_file);`                                        | 加载服务器配置，如监听端口、证书路径、最大连接数等。       |
| 2    | `initialize_ssl_server`        | `SSL_CTX *initialize_ssl_server(const char *cert_file, const char *key_file);`             | 初始化 SSL 库，创建 SSL 上下文，加载服务器证书和私钥。     |
| 3    | `create_server_socket`         | `int create_server_socket(int port);`                                                      | 创建套接字并绑定到指定端口，开始监听客户端连接。           |
| 4    | `accept_client`                | `int accept_client(int server_sockfd);`                                                    | 接受客户端的连接请求，返回客户端套接字。                   |
| 5    | `establish_ssl_server_session` | `SSL *establish_ssl_server_session(SSL_CTX *ctx, int client_sockfd);`                      | 在客户端套接字上建立 SSL 会话，完成 SSL 握手。             |
| 6    | `handle_client`                | `void *handle_client(void *arg);`                                                          | 线程函数，处理单个客户端的连接和请求。                     |
| 7    | `authenticate_user`            | `int authenticate_user(SSL *ssl);`                                                         | 接收并验证客户端的 `USER`和 `PASS`命令，进行用户认证。 |
| 8    | `send_response`                | `int send_response(SSL *ssl, int code, const char *message);`                              | 向客户端发送 FTP 响应码和消息。                            |
| 9    | `receive_command`              | `int receive_command(SSL *ssl, char *buffer, size_t size);`                                | 接收客户端发送的 FTP 命令。                                |
| 10   | `parse_command`                | `int parse_command(const char *buffer, char *cmd, char *arg);`                             | 解析客户端发送的命令和参数。                               |
| 11   | `execute_command`              | `int execute_command(SSL *ssl_control, SSL **ssl_data, const char *cmd, const char *arg);` | 根据命令执行相应的操作，如文件传输、目录操作等。           |
| 12   | `enter_passive_mode`           | `int enter_passive_mode(SSL *ssl_control, int *data_sockfd, int *data_port);`              | 处理 `PASV`命令，进入被动模式，创建数据连接套接字。      |
| 13   | `establish_data_connection`    | `SSL *establish_data_connection(SSL_CTX *ctx, int data_sockfd, int is_passive);`           | 在数据连接套接字上建立 SSL 会话，用于数据传输。            |
| 14   | `send_file`                    | `int send_file(SSL *ssl_data, const char *filename);`                                      | 通过数据连接将文件发送给客户端。                           |
| 15   | `receive_file`                 | `int receive_file(SSL *ssl_data, const char *filename);`                                   | 通过数据连接从客户端接收文件。                             |
| 16   | `close_ssl_session`            | `void close_ssl_session(SSL *ssl);`                                                        | 关闭 SSL 会话并释放相关资源。                              |
| 17   | `close_socket`                 | `void close_socket(int sockfd);`                                                           | 关闭套接字。                                               |
| 18   | `cleanup_ssl_server`           | `void cleanup_ssl_server(SSL_CTX *ctx);`                                                   | 释放 SSL 上下文，清理 SSL 库。                             |
| 19   | `handle_error`                 | `void handle_error(const char *message);`                                                  | 处理错误，输出错误信息并进行必要的清理。                   |
| 20   | `log_server_message`           | `void log_server_message(const char *format, ...);`                                        | 记录服务器运行状态和事件。                                 |
| 21   | `main`                         | `int main(int argc, char *argv[]);`                                                        | 程序入口，初始化服务器并开始监听客户端连接。               |

### 1.4.1 service 目录下文件

* **`main.c`**
  * **功能** ：服务器程序的入口，初始化服务器并开始监听客户端连接。
  * **内容** ：调用初始化函数，启动主循环，处理终止信号等。
* **`ftps_server.h`**
  * **功能** ：服务器核心功能的头文件，声明主要的服务器函数和数据结构。
  * **内容** ：函数声明、宏定义、数据结构等。
* **`ftps_server.c`**
  * **功能** ：实现服务器核心功能，如接受客户端连接、用户认证等。
  * **内容** ：`create_server_socket`、`handle_client`等函数的实现。
* **`ssl_utils.h`**
  * **功能** ：SSL/TLS相关的工具函数的头文件。
  * **内容** ：SSL初始化、会话建立等函数的声明。
* **`ssl_utils.c`**
  * **功能** ：实现SSL/TLS相关的工具函数。
  * **内容** ：`initialize_ssl_server`、`establish_ssl_server_session`等函数的实现。
* **`network_utils.h`**
  * **功能** ：网络通信相关的工具函数的头文件。
  * **内容** ：创建套接字、绑定和监听等函数的声明。
* **`network_utils.c`**
  * **功能** ：实现网络通信相关的工具函数。
  * **内容** ：`create_server_socket`、`accept_client`等函数的实现。
* **`command_handler.h`**
  * **功能** ：FTP命令处理相关函数的头文件。
  * **内容** ：接收和解析FTP命令、发送响应等函数的声明。
* **`command_handler.c`**
  * **功能** ：实现FTP命令处理相关函数。
  * **内容** ：`receive_command`、`execute_command`等函数的实现。
* **`file_transfer.h`**
  * **功能** ：文件传输相关函数的头文件。
  * **内容** ：发送、接收文件等函数的声明。
* **`file_transfer.c`**
  * **功能** ：实现文件传输相关函数。
  * **内容** ：`send_file`、`receive_file`等函数的实现。
* **`thread_pool.h`**
  * **功能** ：线程池或多线程处理相关的头文件。
  * **内容** ：线程函数、线程池管理等函数的声明。
* **`thread_pool.c`**
  * **功能** ：实现线程池或多线程处理相关的函数。
  * **内容** ：`start_client_handler_thread`、`client_thread_function`等函数的实现。
* **`logger.h`**
  * **功能** ：日志记录相关函数的头文件。
  * **内容** ：日志记录函数的声明。
* **`logger.c`**
  * **功能** ：实现日志记录相关函数。
  * **内容** ：`log_server_message`、`handle_error`等函数的实现。
