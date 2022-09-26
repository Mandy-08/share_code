import os
import shutil
import json
import argparse


# argument set
parser = argparse.ArgumentParser(description='program select')
parser.add_argument('-sel_pro', help="essential only=1, essential + options1=2, essential + options2=3, ALL=4")
parser.add_argument('-sel_print', help="essential + options1=1, essential + options2=2")


#read the json file
with open("./auto_test.json", "r") as file_list:
    list_data = json.load(file_list)

with open("./auto_test_print.json", "r") as file_list_print:
    list_print_data = json.load(file_list_print)

args = parser.parse_args()

#check for program of argument
if args.sel_pro == '1':
    array_program = list_data["program_list"]["group_1"]

elif args.sel_pro == '2':
    array_program =list_data["program_list"]["group_1"] + list_data["program_list"]["group_2"]

elif args.sel_pro == '3':
    array_program = list_data["program_list"]["group_1"] + list_data["program_list"]["group_3"]

elif args.sel_pro == '4':
    array_program = list_data["program_list"]["group_1"] + list_data["program_list"]["group_2"] + list_data["program_list"]["group_3"]

else:
    print("again select program")
    quit()


#check for print of argument
if args.sel_print == '1':
    array_print = list_print_data["print_list"]["print_group_1"] + list_print_data["print_list"]["print_group_2"]

elif args.sel_print == '2':
    array_print = list_print_data["print_list"]["print_group_1"] + list_print_data["print_list"]["print_group_3"]

else:
    print("again select print")
    quit()



#connect the network drive
os.system(r"net use z: \\[NETWORK ROUTE] /user:[ID] [PW]")


#store set
src_dir = '[ROUTE]'
dst_dir = '[ROUTE]'

#check for dst_dir and create the dst_dir
if not os.path.exists(dst_dir):
    os.makedirs(dst_dir)


#file copy & install
for i in range(len(array_program)):
    
    src_path = os.path.join(src_dir , array_program[i]["name"])
    dst_path = os.path.join(dst_dir , array_program[i]["name"])

    if os.path.isfile(src_path):
        shutil.copyfile(src_path, dst_path)
        os.system(r"ping 127.0.0.1 -n 5")
        os.system(array_program[i]["install"])

    else:
        shutil.copytree(src_path, dst_path)
        os.system(r"ping 127.0.0.1 -n 5")
        os.system(array_program[i]["install"])
        

#config the print
for k in range(len(array_print)):
    os.system(array_print[i]["install"])
    os.system(r"ping 127.0.0.1 -n 5")





#disconnect the network drive
os.system(r"net use * /d /y")
