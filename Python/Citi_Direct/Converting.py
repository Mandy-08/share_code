import os
import pandas as pd
from datetime import datetime

now = datetime.now()
full_date = now.strftime('%Y_%m_%d')



source_file = '[SOURCE_FILE_PATH\\FILE_NAME]'
text_file_path = '[TEXT_FILE_PATH]\\%s' % (now.year)
text_file_name = '[TEXT_FILE_NAME]_%s.txt' % (full_date)
text_file = os.path.join(text_file_path , text_file_name)



if not os.path.exists(text_file_path):
    os.makedirs(text_file_path)

df = pd.read_excel(source_file)

df.to_csv(text_file, sep='@', index=False, header=False, lineterminator='@\n')

with open(text_file, 'r', encoding='utf8') as f:
    text = f.read()

with open(text_file, 'w', encoding='ANSI') as f:
    f.write(text)


os.system(r"msg * /server:127.0.0.1 /v /w task done")
