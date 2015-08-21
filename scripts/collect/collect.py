#!/usr/bin/python
# -*- coding: utf-8 -*-
# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4

__author__  = "Kadda SAHNINE"
__contact__ = "ksahnine@gmail.com"
__license__ = 'GPL v3'

import tweepy
from tweepy import OAuthHandler
import getopt
import json
import time
import os
import sys

# Vecteurs d'accreditation a renseigner
# apres creation dans le gestionnaire d'applications Twitter 
# cf : https://apps.twitter.com/
consumer_key = ""
consumer_secret = ""
access_token = ""
access_token_secret = ""

# Constantes
maxTweets = 10000000   # Nombre de tweet max a recuperer
tw_block_size = 100    # Nombre de Tweet par requete
sinceId = None         # Recuperation des tweets du plus recent au plus ancien

auth = OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)
api = tweepy.API(auth, wait_on_rate_limit=True, wait_on_rate_limit_notify=True)

def usage():
    """
    Display usage
    """
    sys.stderr.write( "Usage: collect.py -s <hashtag> | --search=<hashtag>\n"+
                      "                 [-o <output-dir> | --output-dir=<output-dir>]\n"+
                      "                 [-m <max-id> | --maxid=<max-id>]\n")

def main(argv):
    """
    Collecte des tweets associe a un hashtag.
    """
    tweetCount = 0
    search_query = None
    max_id = -1L
    output_dir = "."

    try:
        opts, args = getopt.getopt(argv, "ho:s:m:", ["help","output-dir=","search=","maxid="])
    except getopt.GetoptError:
        usage()
        sys.exit(1)

    for o, a in opts:
        if o in ("-h", "--help"):
            usage()
            sys.exit(0)
        if o in ("-s", "--search" ):
            search_query = a
        if o in ("-o", "--output-dir" ):
            output_dir = a
        if o in ("-m", "--maxid" ):
            max_id = long(a)

    if not search_query:
        usage()
        sys.exit(2)

    print("Parametres de la collecte :")
    print(" - Hashtag    : {0}".format(search_query))
    print(" - Repertoire : {0}".format(output_dir))
    print(" - Max ID     : {0}".format(max_id))
    print("")

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    while tweetCount < maxTweets:
         try:
             if (max_id <= 0):
                 if (not sinceId):
                     new_tweets = api.search(q=search_query, count=tw_block_size)
                 else:
                     new_tweets = api.search(q=search_query, count=tw_block_size, since_id=sinceId)
    
             else:
                 if (not sinceId):
                     new_tweets = api.search(q=search_query, count=tw_block_size, max_id=str(max_id - 1))
                 else:
                     new_tweets = api.search(q=search_query, count=tw_block_size, max_id=str(max_id - 1), since_id=sinceId)
    
             if not new_tweets:
                 print("Collecte terminee.")
                 break
             for tweet in new_tweets:
                 day = tweet.created_at.strftime('%Y-%m-%d')
                 with open( "%s/%s_tweets.json" % (output_dir, day), 'a') as f:
                     f.write(json.dumps(tweet._json))
                     f.write('\n')
             tweetCount += len(new_tweets)
             print("{0} tweets téléchargés".format(tweetCount))
             max_id = new_tweets[-1].id
         except tweepy.TweepError as e:
             print("Une erreur est intervenue. Pour poursuivre le processus de collecte, relancer la commande suivante :")
             print("python collect.py -s {0} -o {1} -u {2}".format(search_query, output_dir, max_id))
             print("")
             print("Error : " + str(e))
             break
    
if __name__ == "__main__":
    main(sys.argv[1:])
