import os
import re
import time
 
def get_command_output(command):
    output = os.popen(command).read().strip()
    return output

def rd_reg(addr):
    cmd      = 'xdma_rw.exe user read {} -l 4'.format(hex(addr)) 
    reg_str  = os.popen(cmd).read().strip()
    reg_list = re.search(r'\w\w \w\w \w\w \w\w',reg_str).group(0).split()
    reg      = reg_list[3] + reg_list[2] + reg_list[1] + reg_list[0]
    reg_hex  = int(reg,16)
    return   reg_hex

def wr_reg(addr,data):
    data0 =   data & 0x000000FF
    data1 =  (data & 0x0000FF00) >> 8
    data2 =  (data & 0x00FF0000) >> 16
    data3 =  (data & 0xFF000000) >> 24
    cmd      = 'xdma_rw.exe user write {} -l 4 {} {} {} {}'.format(hex(addr),hex(data0),hex(data1),hex(data2),hex(data3)) 
    # print(cmd)
    # os.system(cmd)
    os.popen(cmd).read()


ERASE_EN_ADDR    = 0x000000D8 
ERASE_NUM_ADDR   = 0x000000B8 

WR_EN_ADDR       = 0x000000BC 
WR_ADDR_ADDR     = 0x000000C0 
WR_DIN_ADDR      = 0x000000C4 

CFG_EN_ADDR      = 0x000000C8 

RD_EN_ADDR       = 0x000000AC
RD_ADDR_ADDR     = 0x000000B0 
RD_DATA_ADDR     = 0x00000084 


def cfg_init():
    wr_reg(CFG_EN_ADDR,0x01)
    wr_reg(CFG_EN_ADDR,0x00)
    time.sleep(0.1)


def unlock_erase(blk_num):
    wr_reg(ERASE_NUM_ADDR,blk_num)
    wr_reg(ERASE_EN_ADDR,0x01)
    wr_reg(ERASE_EN_ADDR,0x00)
    time.sleep(0.1)

def unlock_erase_imp(blk_num):
    unlock_erase(blk_num)
    while (rd_data_back(blk_num) != 0xFFFF) or (rd_data_back(blk_num + 100) != 0xFFFF) :
        unlock_erase(blk_num)

def wr_data(addr,data):
    # while rd_data_back(addr) != data:
        wr_reg(WR_ADDR_ADDR,addr)
        wr_reg(WR_DIN_ADDR,data)
        wr_reg(WR_EN_ADDR ,0x01)
        wr_reg(WR_EN_ADDR,0x00)
    # time.sleep(0.1)

def rd_data_back(addr):
    wr_reg(RD_ADDR_ADDR,addr)
    wr_reg(RD_EN_ADDR ,0x01)
    wr_reg(RD_EN_ADDR,0x00)
    # time.sleep(0.1) 
    return rd_reg(RD_DATA_ADDR)

def rd_data(addr):
    wr_reg(RD_ADDR_ADDR,addr)
    wr_reg(RD_EN_ADDR ,0x01)
    wr_reg(RD_EN_ADDR,0x00)
    # time.sleep(0.1) 
    print('0x{:0>8x}'.format(rd_reg(RD_DATA_ADDR)))

def flash_wr_test():
    for i in range(64):
        unlock_erase(i)
    time.sleep(1)
    for j in range(1024):
        wr_data(j,j)

def flash_rd_test(addr,byte_num):
    num = int(byte_num/2)
    for i in range(num):
        rd_data(addr+i)


def flash_wr_bin2():
    cfg_init()
    cfg_init()
    for i in range(256): # 16M Bytes
        unlock_erase(i)
    time.sleep(1)
    wr_reg(0x000000E4,0x00000200) # wr_len
    wr_reg(0x000000E8,0x00000000) # base_addr
    wr_reg(0x000000E0,0x00000000)
    wr_reg(0x000000E0,0x00000001) # trig
    wr_reg(0x000000E0,0x00000000)
    time.sleep(0.001)
    wr_reg(0x000000E4,0x00000200) # wr_len
    wr_reg(0x000000E8,0x00000100) # base_addr
    wr_reg(0x000000E0,0x00000000)
    wr_reg(0x000000E0,0x00000001) # trig
    wr_reg(0x000000E0,0x00000000)
    time.sleep(0.001)
    wr_reg(0x000000E4,0x00000200) # wr_len
    wr_reg(0x000000E8,0x00000200) # base_addr
    wr_reg(0x000000E0,0x00000000)
    wr_reg(0x000000E0,0x00000001) # trig
    wr_reg(0x000000E0,0x00000000)
    time.sleep(0.001)
    wr_reg(0x000000E4,0x00000200) # wr_len
    wr_reg(0x000000E8,0x00000300) # base_addr
    wr_reg(0x000000E0,0x00000000)
    wr_reg(0x000000E0,0x00000001) # trig
    wr_reg(0x000000E0,0x00000000)

def flash_wr_bin():
    cfg_init()
    # for i in range(256): # 16M Bytes
    #     num = int(i) * 64 * 1024
    #     unlock_erase_imp(num)
    #     print(hex(num))
    time.sleep(1)
    wr_reg(0x000000E4,0x01000000) # wr_len
    wr_reg(0x000000E8,0x00000000) # base_addr
    wr_reg(0x000000E0,0x00000000)
    wr_reg(0x000000E0,0x00000001) # trig
    wr_reg(0x000000E0,0x00000000)



cfg_init()
flash_wr_bin()

# unlock_erase(1)
# time.sleep(1)
# flash_rd_test(0x00400000,512)





# #################TEST1###########################
# for i in range(256): # 16M Bytes
#     num = int(i) * 64 * 1024
#     unlock_erase_imp(num)
#     print(hex(num))

# flash_rd_test(0x00400000,512)
# flash_rd_test(0x004E0000,512)

# #################TEST2###########################
# unlock_erase(0)
# flash_rd_test(0x00000000,512)
# flash_rd_test(0x00008000,512)
# unlock_erase(0x00010000)
# time.sleep(1)
# flash_rd_test(0x00010000,512)
# flash_rd_test(0x00018000,512)
# flash_rd_test(0x00020000,512)