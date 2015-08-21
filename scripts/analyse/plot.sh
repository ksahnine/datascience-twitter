#!/bin/sh

####
## Courbe des tweets
####
function plot_tweets() {
    gnuplot <<EOF
set timefmt '%Y-%m-%d_%H:%M:%S'
set style fill solid border -1
set boxwidth 0.9
set xtic rotate by -45 scale 0

set xdata time
set format x '%Y-%m-%d'
set datafile separator ","
set ylabel "Nb tweets"

set grid ytics 
set grid xtics 
set grid

plot 'data.csv' u 1:2 with lines title 'Timeseries #TelAvivSurSeine'

EOF
}

####
## Courbe de création de comptes
####
function plot_new_accounts() {
    gnuplot <<EOF
set timefmt '%b %d'
set xdata time
set style data line
set format x '%d/%b'
set xtic rotate by -45 scale 0
set datafile separator ","
set ylabel "Nombre de comptes créés"
set xlabel "Date de création"

set grid ytics mytics  # draw lines for each ytics and mytics
set mytics 2           # set the spacing for the mytics

set grid xtics 

set grid               # enable the grid

plot 'new_accounts.csv' u 2:1 with lines title 'Création de comptes Twitter en Août 2015'
EOF
}

####
## Courbe des tweets par device
####
function plot_sources() {
    gnuplot <<EOF
set timefmt '%Y-%m-%d_%H:%M:%S'
set style fill solid border -1
set boxwidth 0.9
set xtic rotate by -45 scale 0

set xdata time
set format x '%Y-%m-%d'
set datafile separator ","
set ylabel "Nb tweets"

set grid ytics 
set grid xtics 
set grid

set style line 1 lt 1 lw 2 pt 2 linecolor rgb "red"
set style line 2 lt 1 lw 2 pt 2 linecolor rgb "blue"
set style line 3 lt 1 lw 2 pt 2 linecolor rgb "black"

plot 'graph.csv' u 1:2 with lines title 'Canal iPhone' ls 1, 'graph.csv' u 1:3 with lines title 'Canal Android' ls 2, 'graph.csv' u 1:4 with lines title 'Canal Web' ls 3

EOF
}

####
## Répartition des tweets par device
####
function plot_devices() {
    gnuplot <<EOF
set datafile separator ","
set style data histogram

set title "Distribution des tweets par device"
set xlabel "Devices"
set ylabel "Nb tweets"

set xtic rotate by -45 scale 0
set grid ytics
set style fill solid

plot 'devices.csv' u 1:xtic(2) notitle 
EOF
}

#plot_new_accounts
#plot_tweets
#plot_sources
plot_devices

