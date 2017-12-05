#!/bin/bash

#####################################################################
#                                                                   #
# Script de creation d'un nouveau projet sur le repository METIER   #
# et de definition des droits des groupes MET_DEV, MET_RSP, MET_AGL #
# sur les repertoires trunk, branches et tags                       #
# Parametres : $1 - le nom du projet a creer sur le repository      #
#                                                                   #
#-------------------------------------------------------------------#
# Historique des versions :                                         #
#                                                                   #
# Version   |   Date, auteur et commentaires                        #
# v1.0          09/04/2010 - c82ycru - Creation                     #
# v1.1          12/04/2010 - c82ycru - Modification MET_DEV en *    #
# v1.2          13/04/2010 - c82ycru - Redefinition droits BRANCHES #
#                                                                   #
#####################################################################

#####################################################################
# Constantes
#####################################################################
TIMESTAMP=$(date +%s)

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
SVN_ROOT=$PWD/

REPO="METIER"
URL_REPO=$URL_SERVER$REPO
#SVN_ACCESS_FILE=/etc/opt/CollabNet_Subversion/conf/svn_access_file
SVN_ACCESS_FILE=svn_access_file
SVN_ACCESS_FILE_TMP=${SVN_ACCESS_FILE}.tmp
TOUS="*"
GROUPE_RSP="MET_RSP"
GROUPE_AGL="MET_AGL"

#####################################################################
# Fonctions
#####################################################################
function echo_usage {
	echo "###########################################################"
	echo "# creationProjetMetier.sh                                 #"
	echo "# Utilisation : creationProjetMetier.sh nomProjet         #"
	echo "# Parametres : nomProjet = Obl. - Nom du projet a creer   #"
	echo "###########################################################"
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

# Verification que le projet n'est pas deja gere dans le repository
PROJET=$1
svnlook tree $SVN_ROOT$REPO --full-paths | eval "grep '^${PROJET}/'" > /dev/null
if [ $? -eq 0 ]
then
	echo "Le projet $PROJET existe deja dans le repository $REPO" 
	exit 1
fi 

echo_avertissement $PROJET

# Creation des repertoires de l'application
URL_PROJET=$URL_REPO/$PROJET
echo "Creation de la structure par defaut:" 
echo "$URL_PROJET/trunk, $URL_PROJET/branches et $URL_PROJET/tags "
svn mkdir -m "Creation de la structure du projet $PROJET" ${URL_PROJET}/trunk --parents ${URL_PROJET}/tags --parents ${URL_PROJET}/branches --parents
if [ ! $? -eq 0 ]
then
	echo "Echec de la creation du projet $PROJET dans le repository $REPO" 
	exit 1
fi 

# Ajout des droits dans l'access file SVN
cat $SVN_ACCESS_FILE > $SVN_ACCESS_FILE_TMP

# Ecriture du saut de ligne au besoin
tail -n 1 $SVN_ACCESS_FILE_TMP | grep '^[ 	]*$' > /dev/null
if [ ! $? -eq 0 ]
then
	echo "" >> $SVN_ACCESS_FILE_TMP
fi 

echo "[${REPO}:/${PROJET}/trunk]" >> $SVN_ACCESS_FILE_TMP
echo "${TOUS} = rw" >> $SVN_ACCESS_FILE_TMP
echo "" >> $SVN_ACCESS_FILE_TMP
echo "[${REPO}:/${PROJET}/branches]" >> $SVN_ACCESS_FILE_TMP
echo "${TOUS} = rw" >> $SVN_ACCESS_FILE_TMP
echo "" >> $SVN_ACCESS_FILE_TMP
echo "[${REPO}:/${PROJET}/tags]" >> $SVN_ACCESS_FILE_TMP
echo "@${GROUPE_AGL} = rw" >> $SVN_ACCESS_FILE_TMP
echo "@${GROUPE_RSP} = rw" >> $SVN_ACCESS_FILE_TMP
echo "" >> $SVN_ACCESS_FILE_TMP
mv -f -b -S$TIMESTAMP $SVN_ACCESS_FILE_TMP $SVN_ACCESS_FILE
 
exit 0
