﻿修改日期：2020.11.20
修改人：牛振羽
版本：V1.1.1
此版本在XDMA-多板卡程序添加了，两个寄存器逻辑。
 1. 是0x1C寄存器，此寄存器是在上行结束后，发给FPGA的，告诉FPGA需要再给PC机给一个DMA大小的数据，目的是解决通道Busy状态所导致的数据丢失问题。
 2. 是0x20寄存器，此寄存器是在FPGA收到0x1C后，将最后一包传过来的实际数据大小传给PC，为了让PC存盘数据准确。

修改日期：2020.12.11
修改人：牛振羽
版本：V2.1.0
    此版本为双路光纤板卡项目，对应的版本。
    此版本在V1.1.1版本基础上，添加了通道选择寄存器0x24。为0表示选择第一路数据，为1表示选择第2路数据，以此类推。

修改日期：2021.03.23
修改人：牛振羽
版本：V2.1.1
    此版本再V2.1.0基础上，将板卡ID约束取消了。用于测试XDMA版本

修改日期：2021.04.15
修改人：牛振羽
版本：V2.1.2
    此版本再V2.1.1基础上，将造数据使能改为勾选时使用，而非只能在上行时使用了。
    以解决单独下行不好使的情况。
    并修复了最后一包取数据逻辑问题。

修改日期：2021.04.27
修改人：牛振羽
版本：V2.1.3
    此版本再V2.1.2基础上，添加了接收DMA大小设置，为了将最后一包计数（必须是8M）问题解决
