#!/usr/bin/python

import sys
import re
import time

'''
V4: repair the bug for 'input signed abc;'
'''


if len(sys.argv) == 2:
    file_name = sys.argv[1]
else:
    print("ARGV numbers ERROR!\n")
    sys.exit(0)

file = file_name
# file = 'verilog_test_top.v'

cur_time = time.strftime("%Y/%m/%d", time.localtime())
module_name = ""
tb_module_name = ""
author_name = "Holt"
tab = '    '

param_list = []
input_list = []
output_list = []
input_output_list = []


# file = 'verilog_test_top.v'

def break_loop(line):
    search1 = re.search(r'^always', line)
    search2 = re.search(r'^function', line)
    search3 = re.search(r'^task', line)
    search4 = re.search(r'^\)\;', line)
    if search1 or search2 or search3 or search4:
        return 1
    else:
        return 0


def find_module():
    global module_name
    global tb_module_name
    with open(file, "r") as f:
        for line in f:
            line = str(line).replace("\r", "").replace("\n", "").replace("signed", "")
            if re.search(r'\A\s*\Z', line):
                continue
            line = re.sub(r'\A\s+|\s+\Z', "", line)
            search = re.search(r'\Amodule\s+([a-zA-Z0-9_]+)', line)  # module name
            if search:
                module_name = search.group(1)
                tb_module_name = "tb_" + module_name


def gen_param_list():
    global param_list
    with open(file, "r") as f:
        for line in f:
            line = str(line).replace("\r", "").replace("\n", "").replace("signed", "")
            if re.search(r'\A\s*\Z', line):
                continue
            if break_loop(line):
                break
            line = re.sub(r'\A\s+|\s+\Z', "", line)
            search1 = re.search(r'^,?parameter\s+(\[.+\])\s*(\w+)\s*=\s*(\w+)', line)
            search2 = re.search(r'^,?parameter\s+(\w+)\s*=\s*(\w+)', line)
            search3 = re.search(r'^,?parameter\s+(\w+)\s*=', line)
            if search1:
                # temp = "parameter " + search1.group(1) + ' ' + search1.group(2) + " = " + search1.group(3)
                temp = '{:<12}{:<38}{:<29}={:>20}'.format('parameter', search1.group(1), search1.group(2),
                                                          search1.group(3))
                param_list += [temp]  # append
            elif search2:
                # temp = "parameter " + search2.group(1) + " = " + search2.group(2)
                temp = '{:<50}{:<29}={:>20}'.format('parameter', search2.group(1), search2.group(2))
                param_list += [temp]  # append
            elif search3:
                line = line + ','
                pos1 = line.find('=')
                pos2 = line.find(',')
                var  = line[pos1+1:pos2]
                var  = var.replace(' ','')
                temp = '{:<50}{:<29}={:>20}'.format('parameter', search3.group(1),var)
                param_list += [temp]  # append
            else:
                continue


def gen_output_list():
    global output_list
    with open(file, "r") as f:
        for line in f:
            line = str(line).replace("\r", "").replace("\n", "").replace("signed", "")
            if re.search(r'\A\s*\Z', line):
                continue
            if break_loop(line):
                break
            line = re.sub(r'\A\s+|\s+\Z', "", line)
            search1 = re.search(r'^,?(output)\s+(\[.+\])\s*(\w+)', line)
            search2 = re.search(r'^,?(output)\s+(reg|wire)\s+(\[.+\])\s*(\w+)', line)
            search3 = re.search(r'^,?(output)\s+(\w+)', line)
            search4 = re.search(r'^,?(output)\s+(reg|wire)\s+(\w+)', line)
            if search1:
                # temp = search1.group(1) + ' ' + search1.group(2) + ' ' + search1.group(3)
                temp = '{:<12}{:<38}{:<50}'.format(search1.group(1), search1.group(2), search1.group(3))
                output_list += [temp]  # append
            elif search2:
                # temp = search2.group(1) + ' reg ' + search2.group(2) + ' ' + search2.group(3)
                temp = '{:<12}{:<38}{:<50}'.format(search2.group(1), search2.group(3), search2.group(4))
                output_list += [temp]  # append
            elif search4:
                # temp = search4.group(1) + ' reg ' + search4.group(2)
                temp = '{:<50}{:<50}'.format(search4.group(1), search4.group(3))
                output_list += [temp]  # append
            elif search3:
                # temp = search3.group(1) + ' ' + search3.group(2)
                temp = '{:<50}{:<50}'.format(search3.group(1), search3.group(2))
                output_list += [temp]  # append
            else:
                continue


def gen_input_list():
    global input_list
    with open(file, "r") as f:
        for line in f:
            line = str(line).replace("\r", "").replace("\n", "").replace("signed", "")
            if re.search(r'\A\s*\Z', line):
                continue
            if break_loop(line):
                break
            line = re.sub(r'\A\s+|\s+\Z', "", line)
            search1 = re.search(r'^,?(input|inout)\s+(\[.+\])\s*(\w+)', line)
            search2 = re.search(r'^,?(input|inout)\s+wire\s+(\[.+\])\s*(\w+)', line)
            search3 = re.search(r'^,?(input|inout)\s+(\w+)', line)
            search4 = re.search(r'^,?(input|inout)\s+wire\s+(\w+)', line)
            if search1:
                # temp = search1.group(1) + ' ' + search1.group(2) + ' ' + search1.group(3)
                temp = '{:<12}{:<38}{:<50}'.format(search1.group(1), search1.group(2), search1.group(3))
                input_list += [temp]  # append
            elif search2:
                # temp = search2.group(1) + ' ' + search2.group(2) + ' ' + search2.group(3)
                temp = '{:<12}{:<38}{:<50}'.format(search2.group(1), search2.group(2), search2.group(3))
                input_list += [temp]  # append
            elif search4:
                # temp = search4.group(1) + ' ' + search4.group(2)
                temp = '{:<50}{:<50}'.format(search4.group(1), search4.group(2))
                input_list += [temp]  # append
            elif search3:
                # temp = search3.group(1) + ' ' + search3.group(2)
                temp = '{:<50}{:<50}'.format(search3.group(1), search3.group(2))
                input_list += [temp]  # append
            else:
                continue


def gen_input_output_list():
    global input_output_list
    with open(file, "r") as f:
        for line in f:
            line = str(line).replace("\r", "").replace("\n", "").replace("signed", "")
            if re.search(r'\A\s*\Z', line):
                continue
            if break_loop(line):
                break
            line = re.sub(r'\A\s+|\s+\Z', "", line)
            search1 = re.search(r'^,?(input|inout)\s+(\[.+\])\s*(\w+)', line)
            search2 = re.search(r'^,?(input|inout)\s+wire\s+(\[.+\])\s*(\w+)', line)
            search3 = re.search(r'^,?(input|inout)\s+(\w+)', line)
            search4 = re.search(r'^,?(input|inout)\s+wire\s+(\w+)', line)
            search5 = re.search(r'^,?(output)\s+(\[.+\])\s*(\w+)', line)
            search6 = re.search(r'^,?(output)\s+(reg|wire)\s+(\[.+\])\s*(\w+)', line)
            search7 = re.search(r'^,?(output)\s+(\w+)', line)
            search8 = re.search(r'^,?(output)\s+(reg|wire)\s+(\w+)', line)
            if search1:
                temp = '{:<12}{:<38}{:<50}'.format(search1.group(1), search1.group(2), search1.group(3))
                input_output_list += [temp]  # append
            elif search2:
                temp = '{:<12}{:<38}{:<50}'.format(search2.group(1), search2.group(2), search2.group(3))
                input_output_list += [temp]  # append
            elif search4:
                temp = '{:<50}{:<50}'.format(search4.group(1), search4.group(2))
                input_output_list += [temp]  # append
            elif search3:
                temp = '{:<50}{:<50}'.format(search3.group(1), search3.group(2))

                input_output_list += [temp]  # append
            elif search5:
                temp = '{:<12}{:<38}{:<50}'.format(search5.group(1), search5.group(2), search5.group(3))
                input_output_list += [temp]  # append
            elif search6:
                temp = '{:<12}{:<38}{:<50}'.format(search6.group(1), search6.group(3), search6.group(4))
                input_output_list += [temp]  # append
            elif search8:
                temp = '{:<50}{:<50}'.format(search8.group(1), search8.group(3))
                input_output_list += [temp]  # append
            elif search7:
                temp = '{:<50}{:<50}'.format(search7.group(1), search7.group(2))
                input_output_list += [temp]  # append
            else:
                continue


find_module()
gen_param_list()
gen_input_list()
gen_output_list()
gen_input_output_list()

debug_print = 0
if debug_print:
    print(module_name)
    print(param_list)
    print(input_list)
    print(output_list)
    print(input_output_list)

declaration_of_param = ''
declaration_of_signal = ''
task_signal_initial = ''
module_inst = ''
module_inst_imp = ''


# -------------------tbv3-----------------------------------------------------
module_of_param = ''
def gen_module_of_param():
    global module_of_param
    for i in range(len(param_list)):
        signal_temp = param_list[i].split()
        param_name  = signal_temp[1]
        if i == (len(param_list) - 1):
            module_of_param += '    .{:<49}({:<49})  '.format(param_name, param_name)
        else:
            module_of_param += '    .{:<49}({:<49}),\n'.format(param_name, param_name)
# -------------------tbv3-----------------------------------------------------


def get_signal_name(str):
    a = str.split()
    return a[-1]


def gen_module_inst():
    global module_inst
    module_inst = 'u_{}( \n'.format(module_name)
    for i in range(len(input_list)):
        signal_name = get_signal_name(input_list[i])
        module_inst += '    .{:<49}({:<49}),\n'.format(signal_name, signal_name)
    module_inst += '    \n'
    for i in range(len(output_list)):
        signal_name = get_signal_name(output_list[i])
        if i == (len(output_list) - 1):
            module_inst += '    .{:<49}({:<49}) \n);'.format(signal_name, signal_name)
        else:
            module_inst += '    .{:<49}({:<49}),\n'.format(signal_name, signal_name)


def gen_module_inst_imp():
    global module_inst_imp
    module_inst_imp = 'u_{}( \n'.format(module_name)
    for i in range(len(input_output_list)):
        if 'input' in input_output_list[i]:
            temps = '//(i)'
        elif 'output' in input_output_list[i]:
            temps = '//(o)'
        else:
            temps = '//(io)'
        signal_name = get_signal_name(input_output_list[i])
        if i == (len(input_output_list) - 1):
            module_inst_imp += '    .{:<49}({:<49}) {}\n);'.format(signal_name, signal_name,temps)
        else:
            module_inst_imp += '    .{:<49}({:<49}),{}\n'.format(signal_name, signal_name,temps)



def gen_declaration_of_param():
    global declaration_of_param
    for i in range(len(param_list)):
        declaration_of_param += '    {}{:>}\n'.format(param_list[i], ';')


def gen_declaration_of_signal():
    global declaration_of_signal
    for i in range(len(input_list)):
        str = input_list[i].replace(' wire', '     ')
        str = str.replace('input', 'reg  ')
        declaration_of_signal += '    {}{}\n'.format(str, ';')
    declaration_of_signal += '    \n'
    for i in range(len(output_list)):
        str = output_list[i].replace(' reg', '    ')
        str = str.replace('output', 'wire  ')
        declaration_of_signal += '    {}{}\n'.format(str, ';')


def gen_declaration_of_signal_imp():
    global declaration_of_signal
    for i in range(len(input_output_list)):
        if 'input ' in input_output_list[i] or 'inout ' in input_output_list[i]:
            str = input_output_list[i].replace(' wire', '     ')
            str = str.replace('input', 'reg  ')
            str = str.replace('inout', 'wire ')
            declaration_of_signal += '    {}{}\n'.format(str, ';')
        elif 'output ' in input_output_list[i]:
            str = input_output_list[i].replace(' reg', '    ')
            str = str.replace('output', 'wire  ')
            declaration_of_signal += '    {}{}\n'.format(str, ';')


def gen_task_signal_initial():
    global task_signal_initial
    for i in range(len(input_list)):
        signal_name = get_signal_name(input_list[i])
        task_signal_initial += '    {:<40}={:>4} ;\n'.format(signal_name, '0')


gen_module_inst()
gen_module_inst_imp()
gen_module_of_param()
# print(module_inst)
gen_declaration_of_param()
# print(declaration_of_param)
# gen_declaration_of_signal()
gen_declaration_of_signal_imp()
# print(declaration_of_signal)
gen_task_signal_initial()

clk_gen = ''
rst_start = ''
rst_list = []
clk_list = []


def gen_clk_gen():
    global clk_gen
    global rst_list
    global clk_list
    for i in range(len(input_list)):
        signal_name = get_signal_name(input_list[i])
        if 'rst' in signal_name:
            if 'rst' == signal_name or 'rst_n' == signal_name:
                rst_list += [signal_name]
            elif '_rst' in signal_name:
                rst_list += [signal_name]
        elif 'clk' in signal_name:
            clk_gen += '    always #10    {:<20}  = ~ {:<20};\n'.format(signal_name, signal_name)
            clk_list += [signal_name]


def get_level(str, reverse=0):
    if '_n' in str:
        if reverse == 0:
            rst_level = '0'
        else:
            rst_level = '1'
    else:
        if reverse == 0:
            rst_level = '1'
        else:
            rst_level = '0'
    return rst_level


def gen_rst_start():
    global rst_start
    rst_start = '    #40;\n';
    for i in range(len(rst_list)):
        rst_start += '    {:<40}={:>4} ;\n'.format(rst_list[i], get_level(rst_list[i]))
    for i in range(len(clk_list)):
        rst_start += '    @(posedge {:<30});\n'.format(clk_list[i])
    rst_start += '    #40;\n';
    for i in range(len(rst_list)):
        rst_start += '    {:<40}={:>4} ;\n'.format(rst_list[i], get_level(rst_list[i], reverse=1))
    for i in range(len(clk_list)):
        rst_start += '    @(posedge {:<30});\n'.format(clk_list[i])


gen_clk_gen()
gen_rst_start()

tb = '// =================================================================================================\n'
tb += '// Copyright(C) 2020  All rights reserved.                                                          \n'
tb += '// =================================================================================================\n'
tb += '//                                                                                                  \n'
tb += '// =================================================================================================\n'
tb += '// Module         : {}                                                                              \n'.format(tb_module_name)
tb += '// Function       : testbench (File is generate by python.)                                         \n'
tb += '// Type           : RTL                                                                             \n'
tb += '// -------------------------------------------------------------------------------------------------\n'
tb += '// Update History :                                                                                 \n'
tb += '// -------------------------------------------------------------------------------------------------\n'
tb += '// Rev.Level  Date         Coded by         Contents                                                \n'
tb += '// 0.1.0      {}   holt             Create new                                                      \n'.format(cur_time)
tb += '//                                                                                                  \n'
tb += '// =================================================================================================\n'
tb += '                                                                                                    \n'
tb += '`timescale 1ns / 1ps                                                                                \n'
tb += '                                                                                                    \n'
tb += 'module {}();                                                                                        \n'.format(tb_module_name)
tb += '                                                                                                    \n'
tb += '    // -------------------------------------------------------------------------                    \n'
tb += '    // Internal Parameter Definition                                                                \n'
tb += '    // -------------------------------------------------------------------------                    \n'
tb += '{}                                                                                                  \n'.format(declaration_of_param)
tb += '                                                                                                    \n'
tb += '    // -------------------------------------------------------------------------                    \n'
tb += '    // Internal signal definition                                                                   \n'
tb += '    // -------------------------------------------------------------------------                    \n'
tb += '{}                                                                                                  \n'.format(declaration_of_signal)
tb += '                                                                                                    \n'
tb += '// =================================================================================================\n'
tb += '// RTL Body                                                                                         \n'
tb += '// =================================================================================================\n'
tb += '                                                                                                    \n'
tb += '{} #(                                                                                               \n'.format(module_name)
tb += '{}     \n'.format(module_of_param)
tb += '){}                                                                                                 \n'.format(module_inst_imp)

tb += '                                                                                                    \n'
tb += '                                                                                                    \n'
tb += '                                                                                                    \n'
tb += '// task signal initial                                                                              \n'
tb += 'task signal_initial;                                                                                \n'
tb += 'begin                                                                                               \n'
tb += '{}                                                                                                  \n'.format(task_signal_initial)
tb += 'end                                                                                                 \n'
tb += 'endtask                                                                                             \n'
tb += '                                                                                                    \n'
tb += '                                                                                                    \n'
tb += 'task rst_start;                                                                                     \n'
tb += 'begin                                                                                               \n'
tb += '{}                                                                                                  \n'.format(rst_start)
tb += 'end                                                                                                 \n'
tb += 'endtask                                                                                             \n'
tb += '                                                                                                    \n'
tb += '// initial                                                                                          \n'
tb += 'initial begin                                                                                       \n'
tb += '    signal_initial();                                                                               \n'
tb += '    rst_start();                                                                                    \n'
tb += '                                                                                                    \n'
tb += '    #10000;                                                                                         \n'
tb += '    $stop;                                                                                          \n'
tb += 'end                                                                                                 \n'
tb += '                                                                                                    \n'
tb += '{}                                                                                                  \n'.format(clk_gen)
tb += '                                                                                                    \n'
tb += 'endmodule                                                                                           \n'
tb += '                                                                                                    \n'
tb += '                                                                                                    \n'
tb += '                                                                                                    \n'
tb += '                                                                                                    \n'
tb += '                                                                                                    \n'
tb += '                                                                                                    \n'
tb += '                                                                                                    \n'
tb += '                                                                                                    \n'
tb += '                                                                                                    \n'
tb += '                                                                                                    \n'

# print(write_cxt)
file_tb_module_name = tb_module_name + '.sv'

with open(file_tb_module_name, "w") as f:
    f.write(tb)





























