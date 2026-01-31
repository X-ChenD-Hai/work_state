cmake_minimum_required(VERSION 3.10)

project(work_state)

include(cmake/protobuf.cmake)
include(cmake/ebpf.cmake)

# 2. 设置生成的代码文件路径
set(PROTO_FILE "proto/helloworld.proto")
generate_grpc_code(${PROTO_FILE} SRCS GRPC)
create_ebpf_target(my_program ebpf/my_program.bpf.c my_program.bpf.o)
add_executable(server src/server.cc ${SRCS})
include_directories(${CMAKE_BINARY_DIR}/proto)
target_link_libraries(server
  gRPC::grpc++
  gRPC::grpc++_reflection
  protobuf::libprotobuf)
target_include_directories(server PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
add_executable(client src/client.cc ${SRCS})
target_link_libraries(client
  gRPC::grpc++
  gRPC::grpc++_reflection
  protobuf::libprotobuf)
target_include_directories(client PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

add_dependencies(server my_program)