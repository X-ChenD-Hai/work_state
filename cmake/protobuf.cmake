
find_package(gRPC CONFIG REQUIRED)
find_package(Protobuf REQUIRED)

find_program(Protobuf_PROTOC_EXECUTABLE NAMES protoc REQUIRED)
find_program(GRPC_CPP_PLUGIN grpc_cpp_plugin REQUIRED) # 或者使用 get_target_property

function(generate_grpc_code PROTO_FILE SRCS)
    get_filename_component(SOURCE ${PROTO_FILE} ABSOLUTE)
    get_filename_component(SOURCE_LOCATION ${SOURCE} PATH)
    string(REPLACE ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR} OUTPUT_DIR ${SOURCE_LOCATION})
    string(REPLACE ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR} OUTPUT_FILE ${SOURCE})
    get_filename_component(PROTO_FILE_NAME ${PROTO_FILE} NAME_WE)
    set(OUTPUT_PREFIX "${OUTPUT_DIR}/${PROTO_FILE_NAME}")
    file(MAKE_DIRECTORY ${OUTPUT_DIR})
    cmake_parse_arguments(
        ARG
        "GRPC"
        "DIRECTORY"
        ""
        ${ARGN}
    )

    if(ARG_DIRECTORY)
        set(OUTPUT_DIR ${ARG_DIRECTORY})
        file(MAKE_DIRECTORY ${OUTPUT_DIR})
    endif()

    if(ARG_GRPC)
        message(STATUS "enable grpc code")
    endif()


    set(FLAGS)
    set(OUTPUT_TARGETS "${OUTPUT_PREFIX}.pb.cc" "${OUTPUT_PREFIX}.pb.h")
    list(APPEND FLAGS --cpp_out=${OUTPUT_DIR} -I ${SOURCE_LOCATION})

    if(ARG_GRPC)
        if(NOT GRPC_CPP_PLUGIN)
            message(FATAL_ERROR "not found grpc cpp plugin")
        endif()

        list(APPEND OUTPUT_TARGETS "${OUTPUT_PREFIX}.grpc.pb.cc" "${OUTPUT_PREFIX}.grpc.pb.h")
        list(APPEND FLAGS
            --plugin=protoc-gen-grpc=${GRPC_CPP_PLUGIN}
            --grpc_out=${OUTPUT_DIR})
    endif()
    add_custom_command(
        OUTPUT ${OUTPUT_TARGETS}
        COMMAND ${Protobuf_PROTOC_EXECUTABLE}
        ARGS ${FLAGS} ${SOURCE}
        DEPENDS ${PROTO_FILE}
        COMMENT "generate grpc code: ${OUTPUT_TARGETS}"
        VERBATIM
    )
    set(${SRCS} ${OUTPUT_TARGETS} PARENT_SCOPE)
endfunction(generate_grpc_code)
