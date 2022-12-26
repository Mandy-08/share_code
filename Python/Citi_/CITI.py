import pandas as pd
import os
import openpyxl

#File
file = [SOURCE FILE]
text_file = [RESULT FILE]
df = pd.read_excel(file)

#Check for row & column count
row_count = df.shape[0]
column_count = df.shape[1]

#Data Conversion
df_tmp=df.fillna('@')
df_new=df_tmp.astype('str')

#Create File
create_file = open(text_file, 'w')
create_file.close()

k = 0

for i in range(row_count):
    
    for j in range(column_count):
        write_file=open(text_file, 'a')

        if df_new.iat[k, j] == '@':
            write_file.write('@')
            write_file.close()

        else:
            write_file.write(df_new.iat[k, j])
            write_file.write('@')
            write_file.close()

    k = k+1

    if i != row_count-1:
        write_file = open(text_file, 'a')
        write_file.write("\n")
        write_file.close()
