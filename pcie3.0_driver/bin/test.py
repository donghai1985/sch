
import struct
 
def int16_to_bytes(num):
    return struct.pack('>h', num)
 
# 示例
num = -100  # 16位整数0x1234
bytes_pair = int16_to_bytes(num)
print(bytes_pair)  # 输出: b'\x34\x12' (小端模式)

print(struct.unpack('>h',bytes_pair)[0])




