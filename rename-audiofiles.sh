#!/bin/bash

# 目标目录
directory="凡人修仙传"

# 遍历目标目录中的所有文件
for file in $directory/*; do
   # 获取文件名
   filename=$(basename -- "$file")
   # 获取文件名中的第一个数字 ,并去除数字前面的0
   num=$(echo "$filename" | sed -r 's/([^0-9]+)0*([0-9]+).*$/\2/g')
   # 替换文件名
   newfilename=$directory$num".m4a"
   # 执行mv命令
   mv "$file" "$directory/$newfilename"
done


