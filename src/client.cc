#include <iostream>
#include <memory>
#include <string>

#include <grpcpp/grpcpp.h>
#include "helloworld.grpc.pb.h"  // 包含生成的 gRPC 头文件

using grpc::Channel;
using grpc::ClientContext;
using grpc::Status;
using helloworld::Greeter;
using helloworld::HelloRequest;
using helloworld::HelloReply;

class GreeterClient {
public:
    // 构造函数，接收一个 gRPC 通道
    GreeterClient(std::shared_ptr<Channel> channel)
        : stub_(Greeter::NewStub(channel)) {}

    // 执行远程调用的核心方法
    std::string SayHello(const std::string& user) {
        // 准备请求消息
        HelloRequest request;
        request.set_name(user);

        // 准备响应容器
        HelloReply reply;

        // 设置调用上下文
        ClientContext context;

        // 执行实际的 RPC 调用
        Status status = stub_->SayHello(&context, request, &reply);

        // 处理响应
        if (status.ok()) {
            return reply.message();
        } else {
            std::cout << "RPC failed: " << status.error_code() 
                      << ": " << status.error_message() << std::endl;
            return "RPC failed";
        }
    }

private:
    std::unique_ptr<Greeter::Stub> stub_;  // 客户端存根，用于调用远程方法
};

int main(int argc, char** argv) {
    // 创建客户端并连接到服务器
    GreeterClient client(grpc::CreateChannel(
        "localhost:50051", grpc::InsecureChannelCredentials()));
    
    // 准备测试数据
    std::string user("world");
    
    // 执行 RPC 调用
    std::string reply = client.SayHello(user);
    
    // 输出结果
    std::cout << "Greeter received: " << reply << std::endl;

    return 0;
}