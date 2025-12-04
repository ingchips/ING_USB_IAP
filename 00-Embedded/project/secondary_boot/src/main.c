#include <stdint.h>
#include <string.h>
#include "eflash.h"

#define DEF_UPDATE_FLAG     0x5A5A5A5A

typedef struct block_info
{
    uint32_t size;
    uint32_t dst;
    uint32_t src;
    uint32_t magic;
} block_info_t;

// 把数据从 Flash 拷贝到 Flash 的辅助函数：逐扇区读入内存再写入
static int flash_to_flash(uint32_t src, uint32_t dst, uint8_t *buffer, uint32_t size)
{
    while (size > 0)
    {
        int r;
        uint32_t block = size;
        if (block >= EFLASH_ERASABLE_SIZE) block = EFLASH_ERASABLE_SIZE;

        memcpy(buffer, (const void *)src, block);
        r = program_flash(dst, buffer, block);
        if (r) return r;

        dst += block;
        src += block;
        size -= block;
    }
    return 0;
}

// 可以在这里做升级前的检查，可酌情设计检查方法
// 这里检查了目标地址是否按扇区对齐
static int check_fota_blocks(const block_info_t *p)
{
    while (p->magic == DEF_UPDATE_FLAG)
    {
        if (p->dst & (EFLASH_SECTOR_SIZE - 1))
            return -1;
        p--;
    }
    return 0;
}

void do_fota(void)
{
    const block_info_t *p = (const block_info_t *)(FLASH_BASE +
        EFLASH_SECTOR_SIZE * 2 - sizeof(block_info_t));
    if (check_fota_blocks(p) == 0)
    {
        // 检查通过，逐项拷贝
        while (p->magic == DEF_UPDATE_FLAG)
        {
            // 注意：内存直接使用，不定义变量
            flash_to_flash(p->src, p->dst, (void *)0x20002000, p->size);
            p--;
        }
    }

    // 擦除元信息
    // 只有在这个动作执行期间电源失效，才有可能导致固件损坏
    erase_flash_sector(FLASH_BASE + EFLASH_SECTOR_SIZE);

    // 重启
    NVIC_SystemReset();
}
