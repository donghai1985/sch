import socket
import os
import binascii
import math
import time
from datetime import datetime



import time
from multiprocessing.dummy import Pool as ThreadPool
 
# 使用time.sleep实现低精度延迟
def low_precision_delay(duration):
    time.sleep(duration)
 
# 使用多线程实现高精度延迟
def high_precision_delay(duration):
    with ThreadPool(1) as pool:
        pool.apply_async(time.sleep, (duration,)).get()
 
# 示例使用
# low_precision_delay(0.5)  # 低精度延迟500毫秒
# high_precision_delay(0.001)  # 高精度延迟1毫秒



def ReadFile():
    filepath='mfpga_top.bin'         
    binfile = open(filepath, 'rb')   
    ## 获得文件大小
    size = os.path.getsize(filepath)  
    ## 打印文件大小
    print('文件大小为: {} Bytes'.format(size))                       
    ## 遍历输出文件内容
    num = math.ceil(size / 256) 
    print(num)
    for i in range(num):            
        data = binfile.read(256)        
        print(data)
        decode_data = binascii.hexlify(data).decode('utf-8')
        print(decode_data)
    binfile.close()                  

def main():
    #  1.创建udp套接字
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    # 可选(接收时的端口 ('',端口))
    local_address = ('', 1234)
    udp_socket.bind(local_address)

    filepath='fir_coe2.bin'         
    binfile = open(filepath, 'rb')   
    size = os.path.getsize(filepath)  
    print('文件大小为: {} Bytes'.format(size))   
    cfg_len = 1024
    cfg_len = 512
    times   = 5
    num = math.ceil(size / cfg_len) 
    # num = 2
    print(num)
    now = datetime.now()
    formatted_time = now.strftime("%Y-%m-%d %H:%M:%S.%f")
    print(formatted_time)

    for i in range(num):  
        # data = binfile.read(cfg_len)        
        data = b'\x00\x00\x10\x00'
        for j in range(int(cfg_len/4)):
            temp = binfile.read(4)
            # print(type(temp))
            data = data + temp[::-1]
        udp_socket.sendto(data, ('192.168.99.11', 1234))
        udp_socket.sendto(data, ('192.168.99.16', 1234))
        high_precision_delay(0.0001)



    now = datetime.now()
    formatted_time = now.strftime("%Y-%m-%d %H:%M:%S.%f")
    print(formatted_time)
    # data = b'\x00\x00\x10\x01\x00\x00\x00\x01'
    # udp_socket.sendto(data, ('192.168.99.11', 1234))

    udp_socket.close()
    binfile.close()     


main()









# import time
 
# timestamp = time.time()
# local_time = time.localtime(timestamp)
# formatted_time = time.strftime("%Y-%m-%d %H:%M:%S", local_time)
# print(formatted_time)





# from datetime import datetime

# now = datetime.now()
# formatted_time = now.strftime("%Y-%m-%d %H:%M:%S.%f")
# print(formatted_time)