
import os


def alter(file, old_str, new_str):
    """
    替换文件中的字符串
    :param file:文件名
    :param old_str:就字符串
    :param new_str:新字符串
    :return:
    """
    file_data = ""
    with open(file, "r", encoding="utf-8") as f:
        for line in f:
            if old_str in line:
                line = line.replace(old_str, new_str)
            file_data += line
    #print(file)
    #new_file_name = file + 'xyz'
    file_dir = list(os.path.split(file))
    new_file = file_dir[0] + '\\' + 'copy_' + file_dir[1]
    print(new_file)
    with open(new_file, "w", encoding="utf-8") as f:
       f.write(file_data)
    os.remove(file)


def listdir_abspath(path):
    listdir = os.listdir(path)
    allfile = []
    for file in listdir:
        allfile.append(path + '\\' + file)
    return allfile


def find_file(dir_path,mystr):
    all_file_or_dir = listdir_abspath(dir_path)
    for i in range(len(all_file_or_dir)):
        try:
            if os.path.isfile(all_file_or_dir[i]):
                if all_file_or_dir[i].endswith(mystr):  # file_path[-3:] == ".py"
                    # print(all_file_or_dir[i])
                    alter(all_file_or_dir[i],"ABCDEFGHIJKL","ABCDEFGHIJKL")
            elif os.path.isdir(all_file_or_dir[i]):
                tf = os.path.join(dir_path, all_file_or_dir[i])
                find_file(tf, mystr)
            else:
                continue
        except:
            continue


def rename_file(dir_path,mystr):
    all_file_or_dir = listdir_abspath(dir_path)
    for i in range(len(all_file_or_dir)):
        try:
            if os.path.isfile(all_file_or_dir[i]):
                if all_file_or_dir[i].endswith(mystr) and "copy_" in all_file_or_dir[i] :  # file_path[-3:] == ".py"
                    name = all_file_or_dir[i].replace("copy_","")
                    os.rename(all_file_or_dir[i], name)
            elif os.path.isdir(all_file_or_dir[i]):
                tf = os.path.join(dir_path, all_file_or_dir[i])
                rename_file(tf, mystr)
            else:
                continue
        except:
            continue


find_file(os.getcwd(),'.v')
rename_file(os.getcwd(),'.v')









