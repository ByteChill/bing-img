#!/bin/bash

# change directory to where the script resides.
BASEDIR=$(dirname $0)
cd "$BASEDIR"

# for i in {1..1650} 
# do
#     # if [ -f item/$i.html ];then
#     #     continue
#     # else
#     #     echo "$i" >> mis.txt
#     #     url=$(sed -n "${i}p" item.txt)
#     #     code=$(curl -s -I -L $url | head -n 1|cut -d$' ' -f2 )
#     #     if [ "$code" = "403" ]
#     #     then
#     #         echo "catch the cat !!!"
#     #         exit 1
#     #     else
#     #         curl -s -L $url > item/$i.html
#     #     fi
#     # fi

#     item=$(cat item/$i.html)
#     downloadUrl="$(grep -o '/photo/[^"]*?force=download' <<< $item)"
#     date=$(grep -o '<p class="calendari icon icon-calendar"><em class="t">[^<]*' <<< $item |cut -d '>' -f3|sed 's/-//g')
#     en_name=$(echo $downloadUrl| cut -d '/' -f3- | cut -d '?' -f1)
#     name=$(grep -o '<p class="title">[^<]*' <<< $item| cut -d '>' -f2)
#     content=$(grep -o 'class="sub"[^<]*' <<< $item| cut -d '>' -f2)
#     echo "${date}|${en_name}|${name}|${downloadUrl}|${content}" >> ioliu.txt
#     echo "downloadUrl : ${downloadUrl}"
#     echo "date : ${date}"
#     echo "en_name : ${en_name}"
#     echo "name : ${name}"
#     echo "content : ${content}"
#     echo "${date}|${en_name}|${name}|${downloadUrl}|${content}" >> record.txt
# done


# filename="temp_record.txt"
# i=1
# while read line
# do
#     echo -e "\nitem $i"
#     #parse
    
#     #date
#     date=$(echo $line | cut -d '|' -f1)
#     year=${date:0:4}
#     month=${date:4:2}
#     echo "data : ${date}"
#     echo "year : ${year}"
#     echo "month : ${month}"
#     mkdir -p pic/${year}/${month}

#     #name
#     en_name=$(echo $line | cut -d '|' -f2)
#     name=$(echo $line | cut -d '|' -f3 | cut -d '(' -f1 |rev | cut -d ' ' -f2-|rev)
#     echo "en_name : ${en_name}"
#     echo "name : ${name}"

#     #url
    
#     urlPre='https://www.bing.com/th?id=OHR.'
#     urlhd='_1920x1080'
#     urlUHD='_UHD'
#     picExt='.jpg'
#     picURL="${urlPre}${en_name}${urlhd}${picExt}"
#     picUHD="${urlPre}${en_name}${urlUHD}${picExt}"
#     echo "picURL : ${picURL}"
#     echo "picUHD : ${picUHD}"
    

#     #file
#     file="pic/${year}/${month}/$date - ${name}$picExt" 
#     echo "file : ${file}"

#     # exist uhd ?
#     uhd_code=$(curl -s -L -I ${picUHD} | head -n 1|cut -d ' ' -f2 | sed "s/$(printf '\r')\$//")
#     echo "UHD code : $uhd_code"
#     if [[ "$uhd_code" = "200" ]]
#     then
#         echo "exist uhd file"
#         picActURL=${picUHD}
#     else
#         hd_code=$(curl -s -L -I ${picURL} | head -n 1|cut -d ' ' -f2 | sed "s/$(printf '\r')\$//")
#         echo "HD code : $uhd_code"
#         if [[ "$hd_code" = "200" ]]
#         then
#             picActURL=${picURL}
#         else
#             echo "$line" >> miss_url.txt
#         fi
#     fi

    

#     #download  
#     echo "picActURL : ${picActURL}"
#     if [ -f "$file" ]
#     then
#         filesize=$(wc -c < "$file")
#         filesize=$(($filesize)) # parseInt
#         actualsize="$(curl -s -L -I $picActURL | awk -v IGNORECASE=1 '/^Content-Length/ { print $2 }')"
#         actualsize=$(echo $actualsize | sed "s/$(printf '\r')\$//") # remove carriage return on macOS   
#         echo "filesize : $filesize"
#         echo "actualsize : $actualsize"
#         if [[ "$filesize" -eq "$actualsize" ]]
#         then
#             echo "$(date) - '$file' already downloaded"
#         else
#             curl -s "$picActURL" > "$file"
#             echo "$(date) - image saved as $file"
#         fi
#     else
#         curl -s "$picActURL" > "$file"
#         echo "$(date) - image saved as $file"
#     fi 

#     let i+=1;
# done < $filename

filename="miss_url.txt"
i=1
while read line
do
    echo -e "\nitem $i"
    #parse
    
    #date
    date=$(echo $line | cut -d '|' -f1)
    year=${date:0:4}
    month=${date:4:2}
    echo "data : ${date}"
    echo "year : ${year}"
    echo "month : ${month}"
    mkdir -p pic/${year}/${month}

    #name
    en_name=$(echo $line | cut -d '|' -f2)
    name=$(echo $line | cut -d '|' -f3 | cut -d '(' -f1 |rev | cut -d ' ' -f2-|rev)
    echo "en_name : ${en_name}"
    echo "name : ${name}"

    #url
    
    urlPre='https://bing.ioliu.cn'
    urlPrex=$(echo $line | cut -d '|' -f4)
    picActURL="${urlPre}${urlPrex}"

    #file
    file="pic/${year}/${month}/$date - ${name}.jpg" 
    echo "file : ${file}"

    

    

    #download  
    if [[ -f "${file}" ]];then
        echo "exsit"
    else
        echo "picActURL : ${picActURL}"
        code=$(curl -s -L -I ${picActURL} | head -n 1|cut -d ' ' -f2 | sed "s/$(printf '\r')\$//")
        echo "code : $code"
        if [[ "$code" = "403" ]];then
            echo "catch the cat  !!!"
            echo $line
            exit 1
        else if [[ "$code" = "200" ]];then
                echo "cat gooo !!!"
            else 
                echo $line
                exit 1
            fi
        fi
        curl -s "$picActURL" > "$file"
        
        echo "$(date) - image saved as $file"
    fi
    let i+=1;
done < $filename