import win32com.client
import pandas as pd
import os

mail_file_path = r"C:/Temp/outlook_send/mail.xlsx"
attached_dir_path = r"C:/Temp/outlook_send/attached/"
files_count = os.listdir(attached_dir_path)
mail_address = pd.read_excel(mail_file_path)
row_count = mail_address.shape[0]
column_count = mail_address.shape[1]


for i in range(row_count):
    mail_to_name = mail_address.iat[i, 0]
    mail_to_address = mail_address.iat[i, 1]
    attached_file_name = files_count[i]
    new_outlook = win32com.client.Dispatch("Outlook.Application").CreateItem(0)
    new_outlook.To = mail_to_address
    new_outlook.Subject = mail_address.iat[0, 2]
    attached_file = os.path.join(attached_dir_path, attached_file_name)
    new_outlook.Attachments.Add(attached_file)
    new_outlook.Body = "안녕하세요 " + mail_to_name + "\n" + mail_address.iat[0, 3]
    new_outlook.Send()
