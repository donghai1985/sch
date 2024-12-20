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
low_precision_delay(0.5)  # 低精度延迟500毫秒
high_precision_delay(0.001)  # 高精度延迟1毫秒