#include <iostream>
#include <memory>
#include <string>

#include <grpcpp/grpcpp.h>
#include "helloworld.grpc.pb.h"  // 包含生成的gRPC头文件

using grpc::Server;
using grpc::ServerBuilder;
using grpc::ServerContext;
using grpc::Status;
using helloworld::Greeter;
using helloworld::HelloRequest;
using helloworld::HelloReply;

// 服务实现类，继承自生成的基类
class GreeterServiceImpl final : public Greeter::Service {
  Status SayHello(ServerContext* context, 
                  const HelloRequest* request, 
                  HelloReply* reply) override {
    // 构建响应消息
    std::string prefix("Hello ");
    reply->set_message(prefix + request->name());
    
    std::cout << "Received request for: " << request->name() << std::endl;
    return Status::OK;  // 返回成功状态
  }
};

void RunServer() {
  std::string server_address("0.0.0.0:50051");  // 监听所有接口的50051端口
  GreeterServiceImpl service;

  ServerBuilder builder;
  // 添加监听端口
  builder.AddListeningPort(server_address, grpc::InsecureServerCredentials());
  // 注册服务
  builder.RegisterService(&service);
  // 构建并启动服务器
  std::unique_ptr<Server> server(builder.BuildAndStart());
  std::cout << "Server listening on " << server_address << std::endl;
  // 保持服务器运行
  server->Wait();
}

int main(int argc, char** argv) {
  RunServer();
  return 0;
}