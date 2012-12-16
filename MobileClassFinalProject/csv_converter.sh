#/bin/bash

sed 's/\"\"\"/\"/g
s/\([^,]*\),\([^,]*\),\([^,]*\),\"\(.*\)\",\"\(.*\)\",\([^,]*\),\([0-9]*\)/INSERT INTO food_items \(english_category, chinese_category, name, introduction, ingredients, chinese_name, id\) VALUES\('\''\1'\'','\''\2'\'','\''\3'\'','\''\4'\'','\''\5'\'','\''\6'\''\, \7);INSERT INTO images\(image_name, food_id\) VALUES\('\''image\7_1.jpg'\'', \7);INSERT INTO images\(image_name, food_id\) VALUES\('\''image\7_2.jpg'\'', \7); /g' < $1 > sqlcommands.txt
