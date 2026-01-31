find_program(BPF_TOOL_EXE NAMES bpftool)

add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/vmlinux.h
    COMMAND sudo
    ARGS
    ${BPF_TOOL_EXE} btf dump file /sys/kernel/btf/vmlinux format c > ${CMAKE_BINARY_DIR}/vmlinux.h
)

add_custom_target(vmlinux_header ALL DEPENDS ${CMAKE_BINARY_DIR}/vmlinux.h)

function(create_ebpf_target TARGET SOURCE OBJECT)
    set(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${OBJECT})
    get_filename_component(ABSTRACT_SOURCE ${SOURCE} ABSOLUTE)

    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        list(APPEND OPTIONS -g)
    endif()

    list(APPEND OPTIONS -target bpf
        -Wall
        -Werror
        -O2
        -emit-llvm
        -c
        -o ${OUTPUT}
        -I ${CMAKE_BINARY_DIR})

    if(CMAKE_C_COMPILER_ID STREQUAL "Clang")
        add_library(${TARGET} OBJECT)
        target_sources(${TARGET} PRIVATE ${ABSTRACT_SOURCE})
        target_compile_options(${TARGET} PRIVATE ${OPTIONS})
        set_target_properties(${TARGET} PROPERTIES OUTPUT_NAME ${OBJECT})
    else()
        find_program(CLANG_EXE NAMES clang)
        add_custom_target(
            ${TARGET} ALL
            COMMAND ${CLANG_EXE}
            ${OPTIONS}
            ${ABSTRACT_SOURCE}
        )
    endif()
    add_dependencies(${TARGET} vmlinux_header)
endfunction(create_ebpf_target)
