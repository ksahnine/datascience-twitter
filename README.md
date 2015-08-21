# [Blog] Analyse de données twitter

J'ai présenté dans [un article de mon blog](http://ksahnine.github.io/datascience/unix/bigdata/2015/08/14/analyse-hashtag-telavivsurseine.html) les résultats de l'analyse du mot croisillon `#TelAvivSurSeine`, l'évènement au centre d'une [polémique](http://www.lemonde.fr/societe/article/2015/08/09/tel-aviv-sur-seine-la-mairie-de-paris-ne-renonce-pas-malgre-la-polemique_4718346_3224.html) qui n'aurait jamais dû sortir des réseaux sociaux ni des cercles militants.

Ces résutats sont le fruit d'une analyse rationnelle et distanciée des tweets associés à ce hashtag, analyse à la portée d'un informaticien suffisamment à l'aise sous **UNIX** et familier du langage de programmation **Python**.

Ce repository contient le code des outils que j'ai développé pour mener cette analyse.

Ils permettent par exemple de :

- visualiser l'évolution du nombre de tweets et retweets par heure
[![Timeseries du hashtag #TelAvivSurSeine](http://ksahnine.github.io/assets/article_images/TelAv_timeseries.png)](/assets/article_images/TelAv_timeseries.png)

- identifier les comptes les plus retweetés ou mentionnés
- identifier les comptes ayant le plus tweeté ou retweeté
- identifier les photos les plus diffusées
- visualiser le réseau social constitué des comptes ayant le plus tweeté :
![Réseau social de différents protagonistes](http://ksahnine.github.io/assets/article_images/social_network.png)

