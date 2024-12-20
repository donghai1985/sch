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

def flash_rd_test():
    for i in range(1024):
        rd_data(i)

cfg_init()
flash_wr_test()
flash_rd_test()


# cfg_init()




