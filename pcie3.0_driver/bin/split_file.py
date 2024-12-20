# -*- coding: utf-8 -*-
 
#按照大小分割文件
 
import os
import binascii
import math
 
# 需要进行分割的文件，请修改文件名
filename = "pcie_ddr_top.bin"  

# 分割大小约256K
# size = 256 * 1024
# 分割大小约8M
size = 8 * 1024 * 1024
 
def mk_SubFile(srcName,sub,buf):
    [des_filename, extname] = os.path.splitext(srcName)
    filename  = des_filename + '_' + str(sub) + extname
    print( '正在生成子文件: %s' %filename)
    with open(filename,'wb') as fout:
        fout.write(buf)
        return sub+1    
            
def split_By_size(filename,size):
    with open(filename,'rb') as fin:
        buf = fin.read(size)
        sub = 1
        while len(buf)>0:
            sub = mk_SubFile(filename,sub,buf)
            buf = fin.read(size)  
    print("ok")
            

def split_by_size(filename,size):
    with open(filename,'rb') as fin:
        fsize = os.path.getsize(filename)  
        num = math.ceil(fsize / size) 
        for i in range(num):
            buf = fin.read(size)  
            if len(buf) < size :
                buf = buf + b'\x00' * (size - len(buf))
            mk_SubFile(filename,i,buf)

def split_file_wr(filename,size):
    with open(filename,'rb') as fin:
        fsize = os.path.getsize(filename)
        num = math.ceil(fsize / size)
        for i in range(num):
            buf = fin.read(size)
            if len(buf) < size :
                buf = buf + b'\x00' * (size - len(buf))
            mk_SubFile(filename,i,buf)
        for i in range(num):
            [des_filename, extname] = os.path.splitext(filename)
            fname = des_filename + '_' + str(i) + extname
            cmd = 'xdma_rw.exe h2c_0 write 0x00000000 -b -f {} -l 8388608'.format(fname)
            print(cmd)
            os.popen(cmd).read()

# split_by_size(filename, size)
# cmd = 'xdma_rw.exe h2c_0 write 0x00000000 -b -f pcie_ddr_top_0.bin -l 8388608'
# os.popen(cmd).read()
# cmd = 'xdma_rw.exe h2c_0 write 0x00800000 -b -f pcie_ddr_top_1.bin -l 8388608'
# os.popen(cmd).read()

split_file_wr(filename, size)

