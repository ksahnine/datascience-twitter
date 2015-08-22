#!/bin/sh

nb_tweets() {
    if [ $# -ne 2 ]
    then
        echo "Exemple : nb_tweets \"data/*.json\"  \"Tue Aug 11 2[0-2].*\""
        exit 1
    fi
    jq ".|select(.created_at|match(\"$2\"))|.created_at" $1 | wc -l
}

tab_retweeted_users() {
    if [ $# -ne 3 ]
    then
        echo "Exemple : tab_retweeted_users \"data/*.json\" \"Tue Aug 11 2[0-2].*\" 5"
        exit 1
    fi
    (echo "Nb_rtweet Nb_Followers Compte"; jq --raw-output "[.|select(.created_at|match(\"$2\"))|.retweeted_status.user.followers_count,.retweeted_status.user.screen_name] | @csv" $1 | tr ',' ' ' | sed '/^ *$/d;/^,$/d' | sort -k2 | uniq -cf1 | sort -k1rn | sed -e 's/^ *//' | head -$3 ) | csvlook -d' '
}

tab_mentions() {
    if [ $# -ne 3 ]
    then
        echo "Exemple : tab_mentions \"data/*.json\" \"Tue Aug 11 2[0-2].*\" 5"
        exit 1
    fi
    (echo "Nb,Compte"; jq ".|select(.created_at|match(\"$2\"))|.entities.user_mentions[].screen_name" $1 | sort | uniq -c | sed -e 's/^ *//;s/ /,/' | sort -rn | head -$3 ) | csvlook
}

tab_hashtag() {
    if [ $# -ne 3 ]
    then
        echo "Exemple : tab_hashtag \"data/*.json\" \"Tue Aug 11 2[0-2].*\" 5"
        exit 1
    fi
    (echo "Nb,Hashtag"; jq ".|select(.created_at|match(\"$2\"))|.entities.hashtags[].text" $1 | tr '[A-Z]' '[a-z]' | tr '[àâäéèêëîïôöùûü]' '[aaaeeeeiioouuu]' | sort | uniq -c | sed -e 's/^ *//;s/ /,/' | sort -rn | head -$3 ) | csvlook
}

tab_sources() {
    if [ $# -ne 3 ]
    then
        echo "Exemple : tab_source \"data/*.json\" \"Tue Aug 11 2[0-2].*\" 5"
        exit 1
    fi
    (echo "Nb,Source"; jq ".|select(.created_at|match(\"$2\"))|.source" $1 | sed 's/"\(<.*>\)\(.*\)\(<.*>\)"/\2/' | sort | uniq -c | sort -rn | head -$3 | sed -e 's/^ *//;s/ /,/' ) | csvlook
}

csv_tweets() {
    if [ $# -ne 3 ]
    then
        echo "Exemple : csv_tweets \"data/*.json\" \"Tue Aug 11 2[0-2].*\" 5"
        exit 1
    fi
    jq ".|select(.created_at|match(\"$2\"))|.user.screen_name" $1 | sort | uniq -c | sort -rn | head -$3
}

csv_retweeted_users() {
    if [ $# -ne 3 ]
    then
        echo "Exemple : csv_retweeted_users \"data/*.json\" \"Tue Aug 11 2[0-2].*\" 5"
        exit 1
    fi
    jq --raw-output "[.|select(.created_at|match(\"$2\"))|.retweeted_status.user.followers_count,.retweeted_status.user.screen_name,.retweeted_status.user.id] | @csv" $1 | tr ',' ' ' | sed '/^ *$/d;/^,$/d' | sort -k2 | uniq -cf1 | sort -k1rn | sed -e 's/^ *//;s/\"//g' | head -$3 | awk '{ print $4 "," $3 "," $2 } '
}

csv_tweeted_users() {
    if [ $# -ne 3 ]
    then
        echo "Exemple : csv_tweeted_users \"data/*.json\" \"Tue Aug 11 2[0-2].*\" 5"
        exit 1
    fi
    jq --raw-output "[.|select(.created_at|match(\"$2\"))|.user.followers_count,.user.screen_name,.user.id] | @csv" $1 | tr ',' ' ' | sed '/^ *$/d;/^,$/d' | sort -k2 | uniq -cf1 | sort -k1rn | sed -e 's/^ *//;s/\"//g' | head -$3 | awk '{ print $4 "," $3 "," $2 } '
}

csv_graph_sources() {
    LANG=en_US
    if [ $# -ne 1 ]
    then
        echo "Exemple : csv_graph_sources \"data/*.json\""
        exit 1
    fi
    # iPhone
    jq ".|select(.source|match(\"Twitter for iPhone\"))|.created_at" $1 | xargs -I ? date -j -f "%a %h %d %H:%M:%S %z %Y" "?" "+%Y-%m-%d_%H:00:00" | sort | uniq -c | sed -e 's/^ *//;s/ /,/' | awk -F"," '{ print $2 "," $1}' > iphone.csv
    # Android
    jq ".|select(.source|match(\"Twitter for Android\"))|.created_at" $1 | xargs -I ? date -j -f "%a %h %d %H:%M:%S %z %Y" "?" "+%Y-%m-%d_%H:00:00" | sort | uniq -c | sed -e 's/^ *//;s/ /,/' | awk -F"," '{ print $2 "," $1}' > android.csv
    # Web
    jq ".|select(.source|match(\"Twitter Web Client\"))|.created_at" $1 | xargs -I ? date -j -f "%a %h %d %H:%M:%S %z %Y" "?" "+%Y-%m-%d_%H:00:00" | sort | uniq -c | sed -e 's/^ *//;s/ /,/' | awk -F"," '{ print $2 "," $1}' > web.csv

    echo "Generation des fichiers iphone.csv, android.csv, web.csv"
}

usage() {
    echo "Routines disponibles :"
    typeset -F | sed 's/declare -f/  -/'
}

if [ $# -lt 1 ]
then
    usage
else
    if [ -z "`typeset -F | grep \"$1\"`" ]
    then
        echo "ERREUR. Parametres incorrects. "
        usage
        exit 1
    fi
    eval $1 \"$2\" \"$3\" $4
fi
