# !/bin/bash
ITEM_FILE="$1"
DATA_FILE="$2"
USER_FILE="$3"

echo "--------------------------"
echo "User Name: yoonjiwon"
echo "Student Number: 12203690"
echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of action genre movies from 'u.item'"
echo "3. Get the average 'rating' of the movie identified by specific 'movie id' from 'u.data'"
echo "4. Delete the 'IMDb URL' from 'u.item'"
echo "5. Get the data about users from 'u.user'"
echo "6. Modify the format of 'release date' in 'u.item'"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "--------------------------"

read -p "Enter your choice [ 1-9 ] " choice
echo ""

while [ "$choice" -ne 9 ]
do

case $choice in
    1)
        read -p "Please enter 'movie id'(1~1682): " movie_id
        echo ""
	cat u.item | awk -F\ -v id="$movie_id" '$1 == id { print $0 }'
        ;;
    2) 
	read -p "Do you want to get the data of 'action' genre movies from 'u.item'?(y/n) : " action_choice
	echo ""
        if [[ "$action_choice" == "y" ]]; then
             cat u.item | awk -F\ | '$7 == 1 {print $1, $2}' | head -10
        fi
        ;;
    3)  
	read -p "Please enter 'movie id'(1~1682) : " movie_id
        echo ""
	avg_rating=$(cat u.data | awk -F"\t" -v id="$movie_id" '$2 == id { total += $3; count++ } END { if (count > 0) printf "%.5f", total/count }')
        echo "average rating of $movie_id : $avg_rating"
        ;;

     4) 
	read -p "Do you want to delete the 'IMDb URL' from 'u.item'? (y/n) : " confirm
        if [[ $confirm == "y" ]]; then
            head -10 cat u.item | sed 's/http[^|]*|/|/g'
        else
            echo "Operation cancelled."
        fi
        ;;

     5) 
	read -p "Do you want to get the data about users from 'u.user'? (y/n) : " confirm
        if [[ $confirm == "y" ]]; then
            head -10 cat u.user | sed -E 's/([0-9]+)\|([0-9]+)\|([MF])\|([^|]+)\|.*$/user \1 is \2 years old \3 \4/'
        else
            echo "Operation cancelled."
        fi
        ;;

     6)
	read -p "Do you want to Modify the format of 'release data' in 'u.item'? (y/n) : " confirm
        if [[ $confirm == "y" ]]; then
            tail -10 cat u.item | awk -F"|" '{
                split($3, date, "-");
                if (date[2] == "Jan") month="01";
                if (date[2] == "Feb") month="02";
                if (date[2] == "Mar") month="03";
                if (date[2] == "Apr") month="04";
                if (date[2] == "May") month="05";
                if (date[2] == "Jun") month="06";
                if (date[2] == "Jul") month="07";
                if (date[2] == "Aug") month="08";
                if (date[2] == "Sep") month="09";
                if (date[2] == "Oct") month="10";
                if (date[2] == "Nov") month="11";
                if (date[2] == "Dec") month="12";
                new_date=date[3] month date[1];
                $3=new_date;
                print $0
            }' OFS="|"
        else
            echo "Operation cancelled."
        fi
        ;;

     7) 
        read -p "Please enter the 'user id' (1~943) : " user_id
        movie_ids=$(cat u.item | awk -F'|' -v uid="$user_id" '$1 == uid {print $2}'| sort -n | tr '\n' '|')
        echo "$movie_ids"
	echo ""

        cat u.item | awk -F\ -v ids="$movie_ids" 'BEGIN {split(ids, array, "|")} 
          {for (i in array) if ($1 == array[i]) {print $1 "|" $2; delete array[i]}}' | head -10
        ;;

     8)
	read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'? (y/n) : " confirm
        if [[ "$confirm" != "y" ]]; then
            exit 0
        fi
        user_ids=$(cat u.user | awk -F\ '$2 >= 20 && $2 <= 29 && $4 == "programmer" {print $1}')
        
        for user_id in $user_ids; do
           cat u.data | awk -F\ -v uid="$user_id" '$1 == uid {sum+=$3; count++} END {if (count > 0) printf "%d %.5f\n", uid, sum/count}'
        done | sort -t' ' -k2 -n
        ;;


    9)
        echo "Bye!"
        exit 0
        ;;
    *)
        echo "Invalid choice."
        exit 1
        ;;

esac
    read -p "Enter your choice [ 1-9 ] " choice
    echo ""
done


