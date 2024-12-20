import time
import csv
import math 
import sys


def input_para():
    wafer_radius = input("输入wafer半径(mm):")
    pitch = input("输入pitch大小(um):")
    beam_width = input("输入光斑宽度(um):")
    init_angular_speed = input("输入初始角速度(rpm):")
    max_angular_speed = input("输入最大角速度(rpm):")
    spot_space = input("主副光斑间隔(um):")
    spot_space_margin = input("Real-ACC 主副光斑margin间隔(um):")
    peak_search_window = input("peak_search_window(光斑倍率):")

    wafer_radius_temp = int(wafer_radius)
    wafer_radius_temp = wafer_radius_temp *1000
    return wafer_radius_temp,int(pitch),int(beam_width),int(init_angular_speed),int(max_angular_speed),int(spot_space),int(spot_space_margin),int(peak_search_window)


def helix_para(wafer_radius,pitch,init_angular_speed,max_angular_speed):
    wafer_radius_list = []
    angular_speed_list = []
    linear_speed_list = []
    track_time_list = []
    adc_number_list = []

    para_table_length = 0
    actu_radius = wafer_radius

    # 生成螺旋线半径列表 um
    while actu_radius>0 :
        wafer_radius_list.append(actu_radius)
        actu_radius = actu_radius - pitch
    
    # 螺旋线 track 数量
    para_table_length = len(wafer_radius_list)


    # 螺旋线 track 角速度列表 rpm
    max_angular_speed_posetion = 0
    init_linear_speed = wafer_radius * init_angular_speed
    angular_speed = init_angular_speed
    for i in range(para_table_length):
        if (angular_speed < max_angular_speed):
            angular_speed = init_linear_speed/wafer_radius_list[i]
            max_angular_speed_posetion = i
        else :
            angular_speed = max_angular_speed

        angular_speed_list.append(angular_speed)

    # 螺旋线 track 时间列表 us
    for i in range(para_table_length):
        track_time_list.append(60000000 / angular_speed_list[i])

    # 螺旋线 track 线速度列表,um/us
    for i in range(para_table_length):
        linear_speed_list.append(wafer_radius_list[i] * angular_speed_list[i] * 2 * math.pi / 60 / 1000000)

    # 螺旋线 track adc 数量, clk
    for i in range(para_table_length):
        adc_number_list.append(round(track_time_list[i] * 100))


    return para_table_length,wafer_radius_list,angular_speed_list,linear_speed_list,track_time_list,adc_number_list,int(max_angular_speed_posetion)


def data_density_para(para_table_length,wafer_radius_list,adc_number_list):
    data_density_list = []
    for i in range(para_table_length):
        data_density = adc_number_list[i]/(2 * math.pi * wafer_radius_list[i])
        data_density_list.append(data_density)

    data_density_unitize = data_density_list[0]

    adc_num_unitize_density_list = []
    
    for i in range(para_table_length):
        adc_num_unitize_density = data_density_unitize * (2 * math.pi * wafer_radius_list[i])
        adc_num_unitize_density_list.append(int(adc_num_unitize_density))

    return data_density_unitize,adc_num_unitize_density_list,data_density_list

def down_sample_para(para_table_length,adc_number_list,adc_num_unitize_density_list):

    down_sample_lost_list = []
    down_sample_mult_list = []
    lost_num_para_list = []
    down_sample_numerator_list = []
    down_sample_denominator_list = []
    supp_lost_num_list = []
    complete_lost_num_list = []
    
    for i in range(para_table_length):
        down_sample_lost = adc_number_list[i]-adc_num_unitize_density_list[i]

        if down_sample_lost == 0:
            down_sample_mult = 0
            down_sample_numerator = 0
            down_sample_denominator = 0
        else:
            down_sample_mult = adc_number_list[i]//down_sample_lost
            down_sample_numerator = adc_number_list[i] - down_sample_lost * down_sample_mult
            down_sample_gcd = math.gcd(int(down_sample_numerator),int(down_sample_lost))

            if down_sample_gcd != 0:
                down_sample_numerator = down_sample_numerator // down_sample_gcd
                down_sample_denominator = down_sample_lost // down_sample_gcd

        down_sample_numerator = down_sample_denominator - down_sample_numerator
        down_sample_denominator = down_sample_denominator - down_sample_numerator

        if(down_sample_denominator == 0):
            lost_num_para = 1

            supp_lost_num = 0
            complete_lost_num = 0

            down_sample_mult = down_sample_mult | 0x0000

        elif(down_sample_numerator == down_sample_denominator):
            lost_num_para = 1

            supp_lost_num = 0
            complete_lost_num = 0

            down_sample_mult = down_sample_mult | 0xC000

        elif(down_sample_numerator < down_sample_denominator):
            lost_num_para = down_sample_denominator // (down_sample_numerator+1)
            
            supp_lost_num = (down_sample_denominator - lost_num_para * down_sample_numerator)
            complete_lost_num = down_sample_numerator * 2

            down_sample_mult = down_sample_mult | 0x4000

        elif(down_sample_numerator > down_sample_denominator):
            lost_num_para = down_sample_numerator // (down_sample_denominator + 1)

            supp_lost_num = (down_sample_numerator - lost_num_para * down_sample_denominator)
            complete_lost_num = down_sample_denominator * 2

            down_sample_mult = down_sample_mult | 0x8000



        down_sample_lost_list.append(down_sample_lost)
        down_sample_mult_list.append(down_sample_mult)
        lost_num_para_list.append(lost_num_para)
        # down_sample_numerator_list.append(down_sample_numerator)
        # down_sample_denominator_list.append(down_sample_denominator)
        supp_lost_num_list.append(supp_lost_num)
        complete_lost_num_list.append(complete_lost_num)

    return down_sample_lost_list,down_sample_mult_list,lost_num_para_list,supp_lost_num_list,complete_lost_num_list

def acc_align_para(para_table_length,adc_number_list):

    delta_adc_num_list = []

    for i in range(para_table_length-1):
        delta_adc_num = adc_number_list[i] - adc_number_list[i+1]
        delta_adc_num_list.append(delta_adc_num)

    lose_point_list = []
    # delta_lose_point_list = []

    # print("delta_adc_num_list= ",delta_adc_num_list)
    for i in range(para_table_length-1):
        if(delta_adc_num_list[i]==0):
            lose_point_list.append(0)
        else :
            lose_point_list.append(int(adc_number_list[i]/delta_adc_num_list[i]))

    # for i in range(para_table_length-2):
    #     delta_lose_point_list.append(lose_point_list[i] - lose_point_list[i+1])

    # print("lose_point_list=",lose_point_list)
    # print("delta_lose_point_list=",delta_lose_point_list)

    return lose_point_list,delta_adc_num_list

def acc_delay_para(para_table_length,linear_speed_list,spot_space,spot_space_margin,peak_search_window,beam_width,data_density_unitize):
    spot_space_time = 0
    spot_space_time_list = []
    light_pitch_num_list = []
    spot_space_para_list = []

    for i in range(para_table_length):
        spot_space_time = (spot_space-spot_space_margin) / linear_speed_list[i]
        light_pitch_num = beam_width * data_density_unitize * peak_search_window
        # if(i==1):
        #     print("beam_width=",beam_width)
        #     print("data_density_unitize=",data_density_unitize)
        #     print("peak_search_window=",peak_search_window)
        #     print("light_pitch_num=",light_pitch_num)

        #     print("spot_space=",spot_space)
        #     print("spot_space_margin=",spot_space_margin)
        #     print("linear_speed_list[i]=",linear_speed_list[i])
        #     print("spot_space_time=",spot_space_time * 100)

        spot_space_time_list.append(round(spot_space_time * 100))
        light_pitch_num_list.append(round(light_pitch_num))

        spot_space_para_list.append((round(spot_space_time * 100) << 16) + round(light_pitch_num))

    # print('spot_space_time_list=',spot_space_time_list)

    # down_sample_num_list = []
    # cache_num_list = []
    # for i in range(para_table_length):
    #     spot_space_time_new = round(spot_space_time_list[i])
    #     down_sample_num = int(spot_space_time_new/1024)
    #     cache_num = int(spot_space_time_new/(down_sample_num+1))

    #     down_sample_num_list.append(down_sample_num)
    #     cache_num_list.append(cache_num)

    # return down_sample_num_list,cache_num_list
    
    return spot_space_time_list,spot_space_para_list

def test_input_para():
    wafer_radius = 150000
    pitch = 145
    beam_width = 4
    init_angular_speed = 2000
    max_angular_speed = 3000
    spot_space = 171
    spot_space_margin = 30
    peak_search_window = 4

    return int(wafer_radius),int(pitch),int(beam_width),int(init_angular_speed),int(max_angular_speed),int(spot_space),int(spot_space_margin),int(peak_search_window)


def get_fir_parameter(csv_file_path):

    # 用于存储CSV数据的列表
    data = []

    # 打开CSV文件进行读取
    with open(csv_file_path, mode='r', encoding='utf-8') as file:
        reader = csv.reader(file)
        
        # 遍历CSV文件中的每一行
        for row in reader:
            # 将当前行添加到数据列表中
            a = [int(item) for item in row]
            data.append(a)

    # 打印导入的数据
    # print('data:',type(data))
    # print('row:',type(row))
    return data


def clean_hex_str(hex_string):
    if hex_string.startswith('0x'):
        clean_string = hex_string[2:]
    else:
        clean_string = hex_string

    if len(clean_string) < 8 :
        for i in range(8-len(clean_string)):
            clean_string = '0' + clean_string
    
    return clean_string

def ACC_track_para_generate():
    wafer_radius,pitch,beam_width,init_angular_speed,max_angular_speed,spot_space,spot_space_margin,peak_search_window = input_para()

    # print( 'wafer_radius=',wafer_radius,type(wafer_radius))
    # print( 'pitch=',pitch,type(pitch))
    # print( 'init_angular_speed=',init_angular_speed,type(init_angular_speed))
    # print( 'max_angular_speed=',max_angular_speed,type(max_angular_speed))
    # print( 'spot_space=',spot_space,type(spot_space))

    # 生成track相关参数
    para_table_length,wafer_radius_list,angular_speed_list,linear_speed_list,track_time_list,adc_number_list,max_angular_speed_posetion = helix_para(wafer_radius,pitch,init_angular_speed,max_angular_speed)

    # 生成数据密度相关参数
    data_density_unitize,adc_num_unitize_density_list,data_density_list = data_density_para(para_table_length,wafer_radius_list,adc_number_list)

    # 生成下采样相关参数
    # down_sample_lost_list,down_sample_mult_list,down_sample_numerator_list,down_sample_denominator_list,ds_mult_rate_list,ds_mult_add_rate_list = down_sample_para(para_table_length,adc_number_list,adc_num_unitize_density_list)
    down_sample_lost_list,down_sample_mult_list,lost_num_para_list,supp_lost_num_list,complete_lost_num_list = down_sample_para(para_table_length,adc_number_list,adc_num_unitize_density_list)

    # 组合下采样参数，写入FPGA使用
    down_sample_parameter_h_list = []
    down_sample_parameter_l_list = []
    down_sample_parameter_h_str_list = []
    down_sample_parameter_l_str_list = []
    for i in range(len(down_sample_mult_list)):
        down_sample_parameter_h = (down_sample_mult_list[i] << 16) + lost_num_para_list[i]
        down_sample_parameter_l = (supp_lost_num_list[i] << 16) + complete_lost_num_list[i]
        down_sample_parameter_h_list.append(down_sample_parameter_h)
        down_sample_parameter_l_list.append(down_sample_parameter_l)
        down_sample_parameter_h_str = clean_hex_str(hex(down_sample_parameter_h))
        down_sample_parameter_l_str = clean_hex_str(hex(down_sample_parameter_l))
        down_sample_parameter_h_str_list.append(down_sample_parameter_h_str)
        down_sample_parameter_l_str_list.append(down_sample_parameter_l_str)

    # 生成前后track数据对齐相关丢点参数
    lose_point_list,delta_adc_num_list = acc_align_para(para_table_length,adc_num_unitize_density_list)

    track_align_para_list = []
    track_align_para_str_list = []
    for i in range(len(lose_point_list)):
        track_align_para = int(lose_point_list[i] << 16) + int(delta_adc_num_list[i])
        track_align_para_list.append(track_align_para)
        track_align_para_str = clean_hex_str(hex(track_align_para))
        track_align_para_str_list.append(track_align_para_str)


    # 生成原ACC主副光斑间隔查询参数
    spot_space_time_list,spot_space_para_list = acc_delay_para(para_table_length,linear_speed_list,spot_space,spot_space_margin,peak_search_window,beam_width,data_density_unitize)
    
    spot_space_time_str_list = []
    for spot_space_time in spot_space_time_list:
        spot_space_time_str_list.append(clean_hex_str(hex(spot_space_time)))

    spot_space_para_str_list = []
    for spot_space_para in spot_space_para_list:
        spot_space_para_str_list.append(clean_hex_str(hex(spot_space_para)))

    '''
    # 生成csv
    currentTime = time.localtime()
    # time.strftime("%Y%m%d%H%M%S", currentTime)
    file_name = time.strftime("%Y%m%d%H%M%S", currentTime)+'_'+'pitch='+str(pitch)+'angle_speed='+str(int(init_angular_speed))+'.csv'
    
    print(file_name)
    with open(file_name, 'w',newline='') as file:
        write = csv.writer(file)
        csv_header = ['track_index','pitch/um', 'track_radius/um','track_time/us','linear_speed/um/us','angular_speed/rpm',
                      'lose_point/clk','delta_adc_num_list/clk',
                      'down_sample_mode','down_sample_mult','lost_num_para','supp_lost_num','complete_lost_num',
                      'adc_number','adc_num_unitize_density','down_sample_lost','data_density_list',
                      'down_sample_parameter_h','down_sample_parameter_l','light_spot_parameter','spot_space_para_list','track_align_parameter']
        write.writerow(csv_header)
        
        csv_data = []
        for index in range(para_table_length-2):
            csv_data = [str(index), str(pitch), str(wafer_radius_list[index]), str(track_time_list[index]), str(linear_speed_list[index]), str(angular_speed_list[index]), 
                        str(lose_point_list[index]),str(delta_adc_num_list[index]), 
                        str((down_sample_mult_list[index] & 0xC000)>>14),str(down_sample_mult_list[index] & 0x3fff), str(lost_num_para_list[index]),str(supp_lost_num_list[index]),str(complete_lost_num_list[index]),
                        str(adc_number_list[index]),str(adc_num_unitize_density_list[index]),str(down_sample_lost_list[index]),str(data_density_list[index]),
                        down_sample_parameter_h_str_list[index],down_sample_parameter_l_str_list[index],spot_space_time_str_list[index],spot_space_para_str_list[index],track_align_para_str_list[index]]
            # print('csv_data=',csv_data)
            write.writerow(csv_data)
    # '''
    
    light_spot_spacing = data_density_unitize * spot_space


    return light_spot_spacing,down_sample_parameter_h_list,down_sample_parameter_l_list,spot_space_para_list,track_align_para_list


def register_wr(addr,data):
    print()
    return


if __name__ == '__main__':

    light_spot_spacing,down_sample_parameter_h_list,down_sample_parameter_l_list,spot_space_para_list,track_align_para_list = ACC_track_para_generate()
    # print("len(down_sample_parameter_h_list)=",len(down_sample_parameter_h_list))
    # print("len(down_sample_parameter_l_list)=",len(down_sample_parameter_l_list))
    # print("len(spot_space_time_list_str)=",len(spot_space_para_list))
    # print("len(track_align_para_list)=",len(track_align_para_list))


    # 获取 FIR track parameter, 胜伟传递回的fir参数，每一行就是一个track，在每行2、3、4、5处插入ACC需要的参数组成新的参数表下发。每一行的参数量保持128*4字节，多余补零。
    FIR_para_filepath = r"D:/work/FIR/FIR_parameter/20240531140610.csv"

    fir_para_data = get_fir_parameter(FIR_para_filepath)

    # print("len(fir_para_data)=",len(fir_para_data))
    # print("fir_para_data[0]=",fir_para_data[0])

    # print("track_align_para_list[0]=",track_align_para_list[0])
    # print("spot_space_para_list[0]=",spot_space_para_list[0])
    # print("down_sample_parameter_l_list[0]=",down_sample_parameter_l_list[0])
    # print("down_sample_parameter_h_list[0]=",down_sample_parameter_h_list[0])

    for index in range(len(fir_para_data)):
        fir_para_data[index].insert(1,track_align_para_list[index])
        fir_para_data[index].insert(1,spot_space_para_list[index])
        fir_para_data[index].insert(1,down_sample_parameter_l_list[index])
        fir_para_data[index].insert(1,down_sample_parameter_h_list[index])

    currentTime = time.localtime()
    parameter_file_name = time.strftime("%Y%m%d%H%M%S", currentTime)+'_'+'ACC&FIR_track_parameter'+'.csv'
    print(parameter_file_name)
    with open(parameter_file_name, 'w',newline='') as file:
        write = csv.writer(file)
        
        csv_data = []
        for index in fir_para_data:
            csv_data = index
            write.writerow(csv_data)

    # print("light_spot_spacing=",light_spot_spacing)
    # register_wr('0xFF0034',light_spot_spacing)   # 设置PMT板内0x0034寄存器

    # print("fir_para_data[0]=",fir_para_data[0])
