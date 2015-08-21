#!/usr/bin/python
# -*- coding: utf-8 -*-
# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4

__author__  = "Kadda SAHNINE"
__contact__ = "ksahnine@gmail.com"
__license__ = 'GPL v3'

import tweepy
from tweepy import OAuthHandler
from tweepy import Stream
import json
import time
import getopt
import sys
import os.path

# Vecteurs d'accreditation a renseigner
# apres creation dans le gestionnaire d'applications Twitter
# cf : https://apps.twitter.com/
consumer_key = ""
consumer_secret = ""
access_token = ""
access_token_secret = ""

auth = OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)
api = tweepy.API(auth, wait_on_rate_limit=True, wait_on_rate_limit_notify=True)

network_fname = "network.dat"

def usage():
    """
    Display usage
    """
    sys.stderr.write( "Usage: social-network.py [-l <users-file>| --load <users-file>]\n"+
                      "                         [-u <user-id> | --user-id=<user-id>]\n")

def load(users_fname):
    if not os.path.isfile(users_fname):
        print "Erreur. Le fichier %s n'existe pas" % (users_fname)
        sys.exit(2)

    users = {}
    if os.path.isfile(network_fname):
        with open(network_fname, 'r') as f:
            users = json.load(f)
            f.close()

    with open(users_fname, 'r') as f:
        for l in f:
            l = l.strip('\n')
            [user_id, user, nb_followers] = l.split(',')
            if not users.has_key(user):
                users[user] = { "followers": [] }
                for page in tweepy.Cursor(api.followers_ids, screen_name=user).pages():
                    users[user]["followers"].extend(page)

                print "%s : %d followers chargés" % (user, len(users[user]["followers"]) )
                # Dumps users data
                with open(network_fname, 'w') as d:
                    d.write( json.dumps(users) )
                    d.close()
        f.close()

def analyse(fname):
    with open(network_fname, 'r') as f:
        users = json.load(f)
    f.close()
   
    print "source,target,value"
    with open(fname, 'r') as f:
        for l in f:
            l = l.strip('\n')
            subscr = []
            [user_id, user, nb_followers] = l.split(',')
            user_id = int(user_id)
            for u in users.keys():
                #print "%s : %d" % (u, len(users[u]["followers"]) )
                if user_id in users[u]["followers"]:
                    print "%s,%s,%s" % (user, u, nb_followers)

def main(argv):
    if len(argv) < 2:
        usage()
        sys.exit(0)

    try:
        opts, args = getopt.getopt(argv, "hl:u:", ["help", "load=","user-id=" ] )
    except getopt.GetoptError:
        print "Erreur de syntaxe"
        sys.exit(1)

    for o, a in opts:
        if o in ("-h", "--help" ):
            usage()
            sys.exit(0)

        if o in ("-l", "--load" ):
            users_fname = a
            load(users_fname)
            sys.exit(0)

        if o in ("-u", "--user-id" ):
            user_id = a
            if user_id:
                analyse( user_id )
            else:
                print "Erreur. ID user manquant"

        sys.exit(0)

if __name__ == "__main__":
    main(sys.argv[1:])
