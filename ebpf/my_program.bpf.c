#include "vmlinux.h"   // 包含内核数据类型
#include <bpf/bpf_helpers.h>    // BPF辅助函数
#include <bpf/bpf_tracing.h>   // 追踪相关宏
SEC("kprobe/__x64_sys_socket") // 定义程序段和挂载点
int BPF_PROG(bpf_prog1, struct pt_regs *ctx_) 
{
    bpf_printk("sys_socket called\n"); // 打印信息
    return 0;
}

char _license[] SEC("license") = "GPL"; // 必须声明许可证