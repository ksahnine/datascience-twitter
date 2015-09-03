#!/bin/sh

nb_tweets() {
    if [ $# -ne 2 ]
    then
        echo "Exemple : nb_tweets \"data/*.json\"  \"Tue Aug 11 2[0-2].*\""
        exit 1
    fi
    jq ".|select(.created_at|match(\"$2\"))|.created_at" $1 | wc -l
}

nb_twittos() {
    if [ $# -ne 2 ]
    then
        echo "Exemple : nb_twittos \"data/*.json\"  \"Tue Aug 11 2[0-2].*\""
        exit 1
    fi
    jq "select(.created_at|match(\"$2\"))|.user.screen_name" $1 | sort -u | wc -l
}

tab_top_tweets() {
    if [ $# -lt 2 ]
    then
        echo "Exemple : tab_top_tweets \"data/*.json\"  350"
        exit 1
    fi
    (echo "Nb_rtweet\tTexte\tUser"; jq --raw-output "select(.retweeted_status == null and .retweet_count > $2)|[.retweet_count,.text,.user.screen_name] | @tsv" $1 | sort -t$'\t' -k1rn ) | csvlook -d$'\t'
}

tab_retweeted_users() {
    if [ $# -ne 3 ]
    then
        echo "Exemple : tab_retweeted_users \"data/*.json\" \"Tue Aug 11 2[0-2].*\" 5"
        exit 1
    fi
    (echo "Nb_rtweet Nb_Followers Compte"; jq --raw-output "[.|select(.created_at|match(\"$2\"))|.retweeted_status.user.followers_count,.retweeted_status.user.screen_name] | @csv" $1 | tr ',' ' ' | sed '/^ *$/d;/^,$/d' | sort -k2 | uniq -cf1 | sort -k1rn | sed -e 's/^ *//' | head -$3 ) | csvlook -d' '
}

tab_tweeted_users() {
    if [ $# -ne 3 ]
    then
        echo "Exemple : tab_tweeted_users \"data/*.json\" \"Tue Aug 11 2[0-2].*\" 5"
        exit 1
    fi
    (echo "Nb_tweet Nb_Followers Compte"; jq --raw-output "[.|select(.created_at|match(\"$2\"))|.user.followers_count,.user.screen_name] | @csv" $1 | tr ',' ' ' | sed '/^ *$/d;/^,$/d' | sort -k2 | uniq -cf1 | sort -k1rn | sed -e 's/^ *//' | head -$3 ) | csvlook -d' '
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
    (echo "Nb,Hashtag"; jq ".|select(.created_at|match(\"$2\"))|.entities.hashtags[].text" $1 | tr '[A-Z]' '[a-z]' | tr '[àâäéèêëÉîïôöùûüç]' '[aaaeeeeeiioouuuc]' | sort | uniq -c | sed -e 's/^ *//;s/ /,/' | sort -rn | head -$3 ) | csvlook
}

tab_top_photos() {
    if [ $# -ne 2 ]
    then
        echo "Exemple : tab_top_photos \"data/*.json\" 5"
        exit 1
    fi
    (echo "Nb occ,Photo"; jq --raw-output 'select(.entities.media!=null)|select(.entities.media[].type="photo")|.entities.media[].media_url' $1 | sort | uniq -c | sort -rn | sed 's/^ *//;s/ /,/' | head -$2 ) | csvlook
}

tab_sources() {
    if [ $# -ne 3 ]
    then
        echo "Exemple : tab_source \"data/*.json\" \"Tue Aug 11 2[0-2].*\" 5"
        exit 1
    fi
    (echo "Nb,Source"; jq ".|select(.created_at|match(\"$2\"))|.source" $1 | sed 's/"\(<.*>\)\(.*\)\(<.*>\)"/\2/' | sort | uniq -c | sort -rn | head -$3 | sed -e 's/^ *//;s/ /,/' ) | csvlook
}

csv_accounts_created_at() {
    if [ $# -ne 2 ]
    then
        echo "Exemple : csv_accounts_created_at \"data/*.json\"  \"Tue Aug 11 2[0-2].*\""
        exit 1
    fi
    jq ".|select(.user.created_at|match(\"$2\"))|.user.created_at" $1 | sed 's/"\([A-Z][a-z][a-z]\) \([A-Z][a-z][a-z] [0-9][0-9]\) \(.*\) \([0-9][0-9][0-9][0-9]\)/\2 \4/' | sort | uniq -c | sort -n -k3 | sed 's/^ *//;s/ /,/'
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

csv_graph_tweets() {
    LANG=en_US
    if [ $# -ne 2 ]
    then
        echo "Exemple : csv_graph_tweets \"data/*.json\""
        exit 1
    fi
    jq ".created_at" $1 | xargs -I ? date -j -f "%a %h %d %H:%M:%S %z %Y" "?" "+%Y-%m-%d_%H:00:00" | sort | uniq -c | sed -e 's/^ *//;s/ /,/' | awk -F"," '{ print $2 "," $1}' 
}

csv_graph_sources() {
    LANG=en_US
    if [ $# -ne 2 ]
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

all_stats() {
    echo "** Nb tweets **"
    NbTweets=`nb_tweets "$1" ".*"`
    echo $NbTweets
    echo ""
    echo "** Nb utilisateurs **"
    NbTwittos=`nb_twittos "$1" ".*"`
    echo $NbTwittos
    echo ""
    echo "** Nb tweets/user **"
    echo "scale=2; $NbTweets / $NbTwittos" | bc
    echo ""
    echo "** Top tweets **"
    tab_top_tweets "$1" 300
    echo ""
    echo "** Les 5 photos les plus diffusées **"
    tab_top_photos "$1" 5
    echo ""
    echo "** Les 4 canaux principaux **"
    tab_sources "$1" ".*" 4
    echo ""
    echo "** Les 20 comptes les plus retweetes **"
    tab_retweeted_users "$1" ".*" 20
    echo ""
    echo "** Les 20 comptes ayant le plus tweeté **"
    tab_tweeted_users "$1" ".*" 20
    echo ""
    echo "** Les 20 hashtags les plus utilisés **"
    tab_hashtag "$1" ".*" 20
    echo ""
    echo "** Les 20 comptes les plus mentionnés **"
    tab_mentions "$1" ".*" 20
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
