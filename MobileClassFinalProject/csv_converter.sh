#/bin/bash

sed 's/\"\"\"/\"/g
s/\([^,]*\),\([^,]*\),\([^,]*\),\"\(.*\)\",\"\(.*\)\",\([^,]*\)/INSERT INTO food_items \(english_category, chinese_category, name, introduction, ingredients, chinese_name\) VALUES\('\''\1'\'','\''\2'\'','\''\3'\'','\''\4'\'','\''\5'\'','\''\6'\''\);/g' < $1 > sqlcommands.txt
