###define variable###

#variable for Date set
$date_str = get-date -format "yyyy-MM-dd"
$date_yy = get-date -format "yyyy"
$date_mm = get-date -format "MM"
$date_dd = get-date -format "dd"
$date_path = "${date_yy}\${date_mm}\${date_dd}"

$holiday = "2022-10-10", "2023-01-23", "2023-01-24","2023-03-01","2023-05-05","2023-06-06","2023-08-15","2023-09-28","2023-09-29","2023-10-03","2023-10-09","2023-12-25"

$check_holiday = $holiday | Select-String -Pattern $date_str

if ($check_holiday -eq 0) {
    exit
}

#variable for PATH
$sharepoint_source = "[SHREPOINT PATH]" #Go Live
#$sharepoint_source = "[SHREPOINT PATH]\deploy_test" #Deploy TEST
$sharepoint_source_date = "${sharepoint_source}\${date_path}"
$audit_file_path = "${sharepoint_source}\${date_yy}\ALL_RESULT"


#variable for the where_to_buy FILE
$erp_list_where_to_buy_file = "${sharepoint_source_date}\ERP\${date_str}_erp_where_to_buy.txt"
$result_where_to_buy_all_file = "${sharepoint_source_date}\RESULT\where_to_buy\${date_str}_where_to_buy_result_all.txt" 
$result_where_to_buy_match_file = "${sharepoint_source_date}\RESULT\where_to_buy\${date_str}_result_where_to_buy_only_match.txt"
$result_where_to_buy_match_file_temp = "${sharepoint_source_date}\RESULT\where_to_buy\${date_str}_result_where_to_buy_only_match_temp.txt"


#variable for the vendor_1 FILE
$erp_list_vendor_1_file = "${sharepoint_source_date}\ERP\${date_str}_erp_vendor_1.txt"
$result_vendor_1_all_file = "${sharepoint_source_date}\RESULT\vendor_1\${date_str}_result_vendor_1_all.txt" 
$result_vendor_1_match_file = "${sharepoint_source_date}\RESULT\vendor_1\${date_str}_result_vendor_1_only_match.txt"
$result_vendor_1_match_file_temp = "${sharepoint_source_date}\RESULT\vendor_1\${date_str}_result_vendor_1_only_match_temp.txt"


#variable for the vendor_2 FILE
$erp_list_vendor_2_file = "${sharepoint_source_date}\ERP\${date_str}_erp_vendor_2.txt"
$result_vendor_2_all_file = "${sharepoint_source_date}\RESULT\vendor_2\${date_str}_result_vendor_2_all.txt" 
$result_vendor_2_match_file = "${sharepoint_source_date}\RESULT\vendor_2\${date_str}_result_vendor_2_only_match.txt"
$result_vendor_2_match_file_temp = "${sharepoint_source_date}\RESULT\vendor_2\${date_str}_result_vendor_2_only_match_temp.txt"


#variable for CSL & AUDIT
$csl_list_file = "${sharepoint_source_date}\CSL\${date_str}_csl.csv"
$audit_file = "${audit_file_path}\${date_str}_resualt_all.txt"


#variable for the segement count
$match_count_where_to_buy = 0
$match_count_vendor_2 = 0
$match_count_vendor_1 = 0


###Preliminary TASK###

#directory check and create
if ( -not (Test-Path ${sharepoint_source_date}) ) {
    New-Item $sharepoint_source_date\CSL -Type Directory | Out-Null
    New-Item $sharepoint_source_date\ERP -Type Directory | Out-Null
    New-Item $sharepoint_source_date\RESULT\where_to_buy -Type Directory | Out-Null
    New-Item $sharepoint_source_date\RESULT\vendor_1 -Type Directory | Out-Null
    New-Item $sharepoint_source_date\RESULT\vendor_2 -Type Directory | Out-Null
}

if ( -not (Test-Path ${audit_file_path}) ) {
    New-Item ${audit_file_path} -Type Directory | Out-Null
}


#Download csl source file
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$csl_file_download = new-object system.net.webclient
$csl_file_download.DownloadFile("http://api.trade.gov/static/consolidated_screening_list/consolidated.csv",$csl_list_file)


#Download ERP source file
sqlcmd -s localhost -E -i "[SQL FILE PATH]" -h -1 -W -o "$erp_list_where_to_buy_file"
sqlcmd -s localhost -E -i "[SQL FILE PATH]" -h -1 -W -o "$erp_list_vendor_1_file"
sqlcmd -s localhost -E -i "[SQL FILE PATH]" -h -1 -W -o "$erp_list_vendor_2_file"


#read the erp_list
$erp_list_where_to_buy = Get-Content $erp_list_where_to_buy_file
$erp_list_vendor_1 = Get-Content $erp_list_vendor_1_file
$erp_list_vendor_2 = Get-Content $erp_list_vendor_2_file

#read the csl_list
$csl_list = import-csv -Path $csl_list_file


###START MAIN TASK###

#where_to_buy for
for ($i=0; $i -lt $erp_list_where_to_buy.Length; $i++) {
$csl_list_check_for_where_to_buy = $csl_list.name | Select-string -Pattern $erp_list_where_to_buy[$i]
if ($csl_list_check_for_where_to_buy.Length -eq 0) {
Write-Output "--------------------------------------------------" >> $result_where_to_buy_all_file
Write-Output 'searched for' $erp_list_where_to_buy[$i] >> $result_where_to_buy_all_file
Write-Output "no result" >> $result_where_to_buy_all_file
Write-Output "--------------------------------------------------" >> $result_where_to_buy_all_file
}

else {
$match_count_where_to_buy = $match_count_where_to_buy + 1
Write-Output "--------------------------------------------------" >> $result_where_to_buy_all_file
Write-Output $erp_list_where_to_buy[$i] 'Find!' >> $result_where_to_buy_all_file
Write-Output $csl_list_check_for_where_to_buy >> $result_where_to_buy_all_file
Write-Output "--------------------------------------------------" >> $result_where_to_buy_all_file

Write-Output "--------------------------------------------------" >> $result_where_to_buy_match_file
Write-Output $erp_list_where_to_buy[$i] 'Find!' >> $result_where_to_buy_match_file
Write-Output $csl_list_check_for_where_to_buy >> $result_where_to_buy_match_file
Write-Output "--------------------------------------------------" >> $result_where_to_buy_match_file
}
}

if ( (test-path $result_where_to_buy_match_file) ) {
$re_only_where_to_buy = Get-Content $result_where_to_buy_match_file
Write-Output "The number of keywords matched is ${match_count_where_to_buy}" > $result_where_to_buy_match_file
Write-Output "The number of keywords matched is ${match_count_where_to_buy}" > $result_where_to_buy_match_file_temp
Write-Output $re_only_where_to_buy >> $result_where_to_buy_match_file

}


#vendor_1 for
for ($j=0; $j -lt $erp_list_vendor_1.Length; $j++) {

$csl_list_check_for_vendor_1 = $csl_list.name | Select-string -Pattern $erp_list_vendor_1[$j]

if ($csl_list_check_for_vendor_1.Length -eq 0) {
Write-Output "--------------------------------------------------" >> $result_vendor_1_all_file
Write-Output 'searched for' $erp_list_vendor_1[$j] >> $result_vendor_1_all_file
Write-Output "no result" >> $result_vendor_1_all_file
Write-Output "--------------------------------------------------" >> $result_vendor_1_all_file
}

else {
$match_count_vendor_1 = $match_count_vendor_1 + 1
Write-Output "--------------------------------------------------" >> $result_vendor_1_all_file
Write-Output $erp_list_vendor_1[$j] 'Find!' >> $result_vendor_1_all_file
Write-Output $csl_list_check_for_vendor_1 >> $result_vendor_1_all_file
Write-Output "--------------------------------------------------" >> $result_vendor_1_all_file

Write-Output "--------------------------------------------------" >> $result_vendor_1_match_file
Write-Output $erp_list_vendor_1[$j] 'Find!' >> $result_vendor_1_match_file
Write-Output $csl_list_check_for_vendor_1 >> $result_vendor_1_match_file
Write-Output "--------------------------------------------------" >> $result_vendor_1_match_file
}
}

if ( (test-path $result_vendor_1_match_file) ) {
$re_only_vendor_1 = Get-Content $result_vendor_1_match_file
Write-Output "The number of keywords matched is ${match_count_vendor_1}" > $result_vendor_1_match_file
Write-Output "The number of keywords matched is ${match_count_vendor_1}" > $result_vendor_1_match_file_temp
Write-Output $re_only_vendor_1 >> $result_vendor_1_match_file

}


#vendor_2 for
for ($k=0; $k -lt $erp_list_vendor_2.Length; $k++) {
    
$csl_list_check_for_vendor_2 = $csl_list.name | Select-string -Pattern $erp_list_vendor_2[$k]

if ($csl_list_check_for_vendor_2.Length -eq 0) {
Write-Output "--------------------------------------------------" >> $result_vendor_2_all_file
Write-Output 'searched for' $erp_list_vendor_2[$k] >> $result_vendor_2_all_file
Write-Output "no result" >> $result_vendor_2_all_file
Write-Output "--------------------------------------------------" >> $result_vendor_2_all_file
}

else {
$match_count_vendor_2 = $match_count_vendor_2 + 1
Write-Output "--------------------------------------------------" >> $result_vendor_2_all_file
Write-Output $erp_list_vendor_2[$k] 'Find!' >> $result_vendor_2_all_file
Write-Output $csl_list_check_for_vendor_2 >> $result_vendor_2_all_file
Write-Output "--------------------------------------------------" >> $result_vendor_2_all_file

Write-Output "--------------------------------------------------" >> $result_vendor_2_match_file
Write-Output $erp_list_vendor_2[$k] 'Find!' >> $result_vendor_2_match_file
Write-Output $csl_list_check_for_vendor_2 >> $result_vendor_2_match_file
Write-Output "--------------------------------------------------" >> $result_vendor_2_match_file
}
}

if ( (test-path $result_vendor_2_match_file) ) {
    $re_only_vendor_2 = Get-Content $result_vendor_2_match_file
    Write-Output "The number of keywords matched is ${match_count_vendor_2}" > $result_vendor_2_match_file
    Write-Output "The number of keywords matched is ${match_count_vendor_2}" > $result_vendor_2_match_file_temp
    Write-Output $re_only_vendor_2 >> $result_vendor_2_match_file

}


#MERGE AUDIT FILE
$merge_where_to_buy = Get-Content $result_where_to_buy_all_file
$merge_vendor_1 = Get-Content $result_vendor_1_all_file
$merge_vendor_2 = Get-Content $result_vendor_2_all_file
Write-Output $merge_where_to_buy >> $audit_file
Write-Output $merge_vendor_1 >> $audit_file
Write-Output $merge_vendor_2 >> $audit_file
