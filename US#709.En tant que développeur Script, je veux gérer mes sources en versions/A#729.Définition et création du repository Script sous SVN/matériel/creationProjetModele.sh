#!/bin/bash

#####################################################################
#                                                                   #
# Script de creation d'un nouveau projet sur un repository          #
# Parametres : $1 - le nom du repository                            #
#              $2 - le nom du projet a creer sur le repository      #
#                                                                   #
#-------------------------------------------------------------------#
# Historique des versions :                                         #
#                                                                   #
# Version   |   Date, auteur et commentaires                        #
# v1.0          17/04/2010 - c82ycru - Creation                     #
#                                                                   #
#####################################################################

#-------------------------------
# GLIESE
#-------------------------------
#URL_SERVER="http://gliese.agora.msanet/svn/" 
#SVN_ROOT=/DATASOFT/SVN/
            
#-------------------------------
# TETRIS
#-------------------------------
URL_SERVER="http://tetris.agora.msanet:16060/svn/" 
#SVN_ROOT=/DATASOFT/CSVN/
SVN_ROOT="$PWD/"

#####################################################################
# Fonctions
#####################################################################
function echo_usage {
	echo "#################################################################"
	echo "# creationProjetModele.sh                                       #"
	echo "# Utilisation : creationProjetModele.sh nomRepository nomProjet #"
	echo "# Parametres : nomRepository = Obl. - Nom du repository         #"
	echo "#              nomProjet = Obl. - Nom du projet a creer         #"
	echo "#################################################################"
}

function echo_avertissement {
	echo "ATTENTION :"
	echo "Le projet $1 et son arborescence vont etre ajoute au repository ${REPO}."
	echo "Les droits en lecture-ecriture sur branches, tags et trunk vont etre definis."
	echo "Souhaitez-vous continuer [o | n] ?"
	read reponse
	if [[ ! ($reponse == o || $reponse == O) ]]
	then
		echo "Abandon de la creation de l'arbre projet SVN."
		exit 0
	fi
}

#####################################################################
# Section principale
#####################################################################
if [ ! $1 ]
then 
	echo_usage
	exit 1
fi

if [ ! $2 ]
then 
	echo_usage
	exit 1
fi

REPO=$1
PROJET=$2

# Verification que le repository existe
if [ ! -d "$SVN_ROOT$REPO" ]
then
	echo "Le repository $REPO n'existe pas." 
	exit 1
fi

# Verification que le projet n'est pas deja gere dans le repository
svnlook tree "$SVN_ROOT$REPO" --full-paths | eval "grep '^${PROJET}/'" > /dev/null
if [ $? -eq 0 ]
then
	echo "Le projet $PROJET existe deja dans le repository $REPO." 
	exit 1
fi 

echo_avertissement $PROJET

# Creation des repertoires de l'application
URL_PROJET=$URL_SERVER$REPO/$PROJET
echo "Creation de la structure par defaut:" 
echo "$URL_PROJET/trunk, $URL_PROJET/branches et $URL_PROJET/tags "
svn mkdir -m "Creation de la structure du projet $PROJET" ${URL_PROJET}/trunk --parents ${URL_PROJET}/tags --parents ${URL_PROJET}/branches --parents
if [ ! $? -eq 0 ]
then
	echo "Echec de la creation du projet $PROJET dans le repository $REPO" 
	exit 1
fi 

exit 0
