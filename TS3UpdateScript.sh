#!/usr/bin/env bash
# Save stdin to file descriptor 5
exec 5<&0
# Enable debugging by commenting out the following line
#set -x
#
# About: This little Shell-Script checks, if a newer version of your TeamSpeak 3 server is available and if yes, it will update the server, if you want to.
# Author: Sebastian Kraetzig <info@ts3-tools.info>
#
# License: GNU GPLv3
#
# Donations: https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=QMAAHHWHW3VQA
#

SCRIPT_VERSION="3.5"
LAST_EDIT_DATE="2014-08-12"

# Clear the terminal screen
clear 2> /dev/null

# Get screen width
export TERM=xterm
let "COL = $(tput cols) - 10"



#########################
#	C O L O U R S	#
#########################

SCurs='\e[s';		# Save Cursor
MCurs="\e[${COL}C";	# Move Cursor
MCursB="\e[55C";	# Move Cursor a bit
RCurs='\e[u';		# Reset Cursor
RCol='\e[0m';		# Text Reset

# Regular           Bold                Underline           High Intensity      BoldHigh Intens     Background          High Intensity Backgrounds
Bla='\e[0;30m';     BBla='\e[1;30m';    UBla='\e[4;30m';    IBla='\e[0;90m';    BIBla='\e[1;90m';   On_Bla='\e[40m';    On_IBla='\e[0;100m';
Red='\e[0;31m';     BRed='\e[1;31m';    URed='\e[4;31m';    IRed='\e[0;91m';    BIRed='\e[1;91m';   On_Red='\e[41m';    On_IRed='\e[0;101m';
Gre='\e[0;32m';     BGre='\e[1;32m';    UGre='\e[4;32m';    IGre='\e[0;92m';    BIGre='\e[1;92m';   On_Gre='\e[42m';    On_IGre='\e[0;102m';
Yel='\e[0;33m';     BYel='\e[1;33m';    UYel='\e[4;33m';    IYel='\e[0;93m';    BIYel='\e[1;93m';   On_Yel='\e[43m';    On_IYel='\e[0;103m';
Blu='\e[0;34m';     BBlu='\e[1;34m';    UBlu='\e[4;34m';    IBlu='\e[0;94m';    BIBlu='\e[1;94m';   On_Blu='\e[44m';    On_IBlu='\e[0;104m';
Pur='\e[0;35m';     BPur='\e[1;35m';    UPur='\e[4;35m';    IPur='\e[0;95m';    BIPur='\e[1;95m';   On_Pur='\e[45m';    On_IPur='\e[0;105m';
Cya='\e[0;36m';     BCya='\e[1;36m';    UCya='\e[4;36m';    ICya='\e[0;96m';    BICya='\e[1;96m';   On_Cya='\e[46m';    On_ICya='\e[0;106m';
Whi='\e[0;37m';     BWhi='\e[1;37m';    UWhi='\e[4;37m';    IWhi='\e[0;97m';    BIWhi='\e[1;97m';   On_Whi='\e[47m';    On_IWhi='\e[0;107m';


echo -e "\nAbout: This little Shell-Script checks, if a newer version of your TeamSpeak 3 server is available and if yes, it will update the server, if you want to.";
echo "Author: Sebastian Kraetzig <info@ts3-tools.info>";
echo -e "License: GNU GPLv3\n";
echo -e "Version: $SCRIPT_VERSION ($LAST_EDIT_DATE)\n";
echo -e "------------------------------------------------------------------\n";

SCRIPT_NAME="$(basename $0)"
SCRIPT_PATH="$(dirname $0)"

# Make sure, that the user has root permissions
if [[ "$(whoami)" != "root" ]]; then
	# Get absolute path of script
	cd "$(dirname $0)"
	SCRIPT="$(pwd)/$(basename $0)"
	cd - > /dev/null

	# Start script with root permissions - after correct password input
	echo -en "${SCurs}This script needs root permissions. Please enter your root password...";
	echo -e "${RCurs}${MCurs}[ ${Red}HINT ${RCol}]";

	su -c "$SCRIPT $1 $2 $3 $4 $5 $6"

	exit 0
fi

# If no option is set, show the usage message
if [ "$1" = "" ]; then
	echo "$SCRIPT_NAME: missing option";
	echo -e "\nUsage: ./$SCRIPT_NAME OPTION(S)";
	echo
	echo "Try './$SCRIPT_NAME --help' for more options.";

	exit 0;
fi

# Check given parameters
while [ -n "$1" ]; do
	case "$1" in

	-h | --help)
		echo -e "Usage: ./$SCRIPT_NAME OPTION(S)";
		echo
		echo -en "${SCurs}Option";
		echo -e "${RCurs}${MCursB}Description";
		echo    "------------------------------------------------------------------";
		echo -en "${SCurs}-h";
		echo -e "${RCurs}${MCursB}Shows this usage message\n";

		echo -en "${SCurs}--help";
		echo -e "${RCurs}${MCursB}Shows this usage message\n";

		echo -en "${SCurs}--check";
		echo -e "${RCurs}${MCursB}Checks for newer version; If a newer version is available, the user will be asked, if he want to update his TeamSpeak 3 server\n";

		echo -en "${SCurs}--delete-old-logs";
		echo -e "${RCurs}${MCursB}Deletes old TeamSpeak 3 server logs while update process\n";

		echo -en "${SCurs}--inform-online-clients";
		echo -e "${RCurs}${MCursB}Sends the configured poke message to each online client on each virtual server, that the server will be updated (if you enter 'Yes, update!')";
		echo -e "${RCurs}\n${MCursB}The 'password-file' in the root directory of your TeamSpeak 3 server must content your 'serveradmin' password. It's needed to poke the clients.\n";

		echo -en "${SCurs}--path /path/to/ts3server/";
		echo -e "${RCurs}${MCursB}Just check the server in this directory and do not search for directories on the whole server\n";

		echo -en "${SCurs}--latest-version /path/to/latestStableVersion.txt";
		echo -e "${RCurs}${MCursB}Do not use the official latest version. Use instead the latest version from the given file\n";

		echo -en "${SCurs}--keep-backups";
		echo -e "${RCurs}${MCursB}Set this parameter, if you want to keep the created backups by the script\n";

		echo -en "${SCurs}--autoupdate yes";
		echo -e "${RCurs}${MCursB}Installs weekly cronjob to /etc/cron.d/TS3UpdateScript for monday at 3 AM (= 03:00 O'clock) with your given parameters";
		echo -en "${RCurs}\n${MCursB}Checks for newer version and installs the latest TeamSpeak 3 server automatically without asking";
		echo -en "${RCurs}\n\n${MCursB}If more than one TeamSpeak 3 server instances are installed, the cronjobs are planned with a 10 minutes time interval\n";

		echo -en "\nThe following parameters need to be used as single parameter:\n";
		echo -en "${SCurs}--autoupdate no";
		echo -e "${RCurs}${MCursB}Deinstalls weekly cronjob /etc/cron.d/TS3UpdateScript\n";

		echo -en "${SCurs}--check-for-update";
		echo -e "${RCurs}${MCursB}Checks for newer TS3 UpdateScript version\n";

		exit 0;
	;;

	--check)
		CHECK="true"
		shift
	;;

	--delete-old-logs)
		DELETE_OLD_LOGS="true"
		shift
	;;

	--inform-online-clients)
		INFORM_ONLINE_CLIENTS="true"
		shift
	;;

	--path)
		if [ -z "$2" ]; then
			echo "Error: Parameter $1 needs a value.";
			exit 1;
		fi
		PARAMETER_PATH="$2"
		OLDPWD="$(pwd)"
		cd "$PARAMETER_PATH" 2> /dev/null
		if [ $? -ne 0 ]; then
			echo "Error: Invalid path: $PARAMETER_PATH.";
			exit 1;
		fi
		PARAMETER_PATH="$(pwd)"
		cd "$OLDPWD"
		shift
		shift
	;;

	--latest-version)
		if [ -z "$2" ]; then
			echo "Error: Parameter $1 needs a value.";
			exit 1;
		fi
		LATEST_VERSION="$(cat $2)"
		shift
		shift
	;;

	--keep-backups)
		KEEP_BACKUPS="true"
		shift
	;;

	--check-for-update)
		CHECK_FOR_UPDATE="true";
		shift
	;;

	--autoupdate)
		if [ -z "$2" ]; then echo "Error: Parameter $1 needs a value. Possible values are 'yes' and 'no'."; exit 1; fi
		if [ "$2" == "yes" ] || [ "$2" == "no" ]; then
			AUTO_UPDATE_PARAMETER="$2"
		else
			exit 1;
		fi
		shift
		shift
	;;

	--cronjob-auto-update)
		CRONJOB_AUTO_UPDATE="true"
		shift
	;;

	*)
		echo "Unregonized option: $1"
		echo -e "\nUsage: ./$SCRIPT_NAME OPTION(S)";
		echo
		echo "Try './$SCRIPT_NAME --help' for more options.";

		exit 0
		shift
	;;

	esac
done

echo -e "Please wait... Script is working...";

# Write warning message, that the checked software package is not installed
warn()
{
	printf >&2 "$SCRIPT_NAME: $*\n"
}

# Check, if the software package is installed/installed/usable
iscmd()
{
	command -v >&- "$@"
}

# Checks list of given software packages
checkdeps()
{
	local -i not_found
	for cmd; do
		iscmd "$cmd" || {
			warn $"$cmd is not found"
			let not_found++
		}
	done

	(( not_found == 0 )) || {
		warn $"Install dependencies listed above to use $SCRIPT_NAME"
		exit 1
	}
}

# Execute software checks
if [ "$INFORM_ONLINE_CLIENTS" == "true" ]; then
	checkdeps bash mktemp rsync wget grep sed unzip telnet
elif [ -n "$AUTO_UPDATE_PARAMETER" ] && [ "$INFORM_ONLINE_CLIENTS" == "true" ]; then
	checkdeps bash mktemp rsync wget grep sed unzip mail telnet
elif [ -n "$AUTO_UPDATE_PARAMETER" ]; then
	checkdeps bash mktemp rsync wget grep sed unzip mail
else
	checkdeps bash mktemp rsync wget grep sed unzip
fi

# Check, if a new TS3UpdateScript version is available
wget https://github.com/TS3Tools/TS3UpdateScript/blob/master/TS3UpdateScript.sh -q -O - > TEMP_latest_version.txt
LATEST_TS3_UPDATESCRIPT_VERSION="$(grep -E 'SCRIPT_VERSION' TEMP_latest_version.txt | head -1 | cut -d ';' -f 2 | egrep -o '[0-9\.]+')"
rm TEMP_latest_version.txt

if [ "$SCRIPT_VERSION" != "$LATEST_TS3_UPDATESCRIPT_VERSION" ]; then
	if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
		echo -en "\n'TS3 UpdateScript' version '$LATEST_TS3_UPDATESCRIPT_VERSION' released. Execute './$SCRIPT_NAME --check-for-update' to update the script";
		echo -e "\t[ INFO ]\n";
	else
		echo -en "\n${SCurs}'TS3 UpdateScript' version '$LATEST_TS3_UPDATESCRIPT_VERSION' released. Execute './$SCRIPT_NAME --check-for-update' to update the script";
		echo -e "${RCurs}${MCurs}[ ${Cya}INFO ${RCol}]\n";
	fi

	if [ "$CHECK_FOR_UPDATE" == "true" ]; then
		UPDATE_ANSWER=""

		while [ "$UPDATE_ANSWER" == "" ]; do
			read -p "Do you want to update the script? ([y]es/[n]o) " UPDATE_ANSWER

			if [[ -n "$UPDATE_ANSWER" ]] && [[ "$UPDATE_ANSWER" != "y" ]] && [[ "$UPDATE_ANSWER" != "yes" ]] && [[ "$UPDATE_ANSWER" != "n" ]] && [[ "$UPDATE_ANSWER" != "no" ]]; then
				echo -en "${SCurs}Illegal characters, please retry.";
				echo -e "${RCurs}${MCurs}[ ${Red}ERROR ${RCol}]";
				UPDATE_ANSWER=""
			fi
		done

		if [[ "$UPDATE_ANSWER" == "y" ]] && [[ "$UPDATE_ANSWER" == "yes" ]]; then
			echo -en "\n${SCurs}Updating TS3 UpdateScript script";
			echo -e "${RCurs}${MCurs}[ ${Whi}.. ${RCol}]\n";

			# Format "latest version" into usable string for downloads
			echo "$LATEST_TS3_UPDATESCRIPT_VERSION" > TEMP_LATEST_VERSION.txt
			STRING_LATEST_VERSION=$(sed -r 's/ /\_/g' TEMP_LATEST_VERSION.txt)
			rm TEMP_LATEST_VERSION.txt

			# Get main version number of latest version for downloads
			echo "$STRING_LATEST_VERSION" > TEMP_STRING_LATEST_VERSION.txt;
			NUMBER_OF_VERSION=$(grep -Po "^([0-9]+)" TEMP_STRING_LATEST_VERSION.txt)
			rm TEMP_STRING_LATEST_VERSION.txt

			# Download latest version
			wget -q http://files.ts3-tools.info/TS3_UpdateScript/$NUMBER_OF_VERSION/TS3UpdateScript_v$STRING_LATEST_VERSION.zip
			# Unzip latest version
			if [ $(unzip TS3UpdateScript_v$STRING_LATEST_VERSION.zip -x configs/) ]; then
				echo -e "${RCurs}${MCurs}[ ${Gre}OK ${RCol}]\n";
				exit 1;
			else
				echo -e "${RCurs}${MCurs}[ ${Red}FAILED ${RCol}]\n";
				exit 0;
			fi
		else
			echo -en "\n${SCurs}Your TS3 UpdateScript was NOT updated";
			echo -e "${RCurs}${MCurs}[ ${Cya}INFO ${RCol}]\n";
			exit 1;
		fi
	fi
else
	if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
		echo -en "You are using the latest TS3 UpdateScript";
		echo -e "\t[ INFO ]\n";
	else
		echo -en "${SCurs}You are using the latest TS3 UpdateScript";
		echo -e "${RCurs}${MCurs}[ ${Cya}INFO ${RCol}]\n";
	fi
fi

if [ -z "$AUTO_UPDATE_PARAMETER" ]; then
	# Search latest TeamSpeak 3 server version
	if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
		echo -en "Searching for latest TeamSpeak 3 server version";
	else
		echo -en "${SCurs}Searching for latest TeamSpeak 3 server version";
		echo -e "${RCurs}${MCurs}[ ${Whi}.. ${RCol}]";
	fi

	if [[ -z "$LATEST_VERSION" ]]; then
		TEMPFILE_1=$(mktemp /tmp/ts3_download_page-XXXXX)
		TEMPFILE_2=$(mktemp /tmp/ts3_download_page-XXXXX)
		TEMPFILE_3=$(mktemp /tmp/ts3_download_page-XXXXX)

		# Download 'TeamSpeak 3 Download page'
		wget http://www.teamspeak.de/download/teamspeak/ -q -O - > $TEMPFILE_1

		# Get the latest Linux server version of the downloaded 'TeamSpeak Download page'
		grep -A 15 'Teamspeak für Linux' $TEMPFILE_1 > $TEMPFILE_2
		grep -A 1 'Server' $TEMPFILE_2 > $TEMPFILE_3
		LATEST_VERSION="$(cat $TEMPFILE_3 | egrep -o  '((\.)?[0-9]{1,3}){1,3}\.[0-9]{1,3}' | tail -1)"
	fi

	if [[ "$LATEST_VERSION" == "" ]]; then
		LATEST_VERSION="Unknown"
	fi

	if [[ "$LATEST_VERSION" == "Unknown" ]]; then
		if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
			echo -e "\t[ FAILED ]";
		else
			echo -e "${RCurs}${MCurs}[ ${Red}FAILED ${RCol}]";
		fi
		exit 1;
	else
		if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
			echo -e "\t[ OK ]";
		else
			echo -e "${RCurs}${MCurs}[ ${Gre}OK ${RCol}]";
		fi
	fi

	# Check if the update text and displayed username is within the maximum of size limit
	if [ "$INFORM_ONLINE_CLIENTS" == "true" ]; then
		# Auto update text
		# Replace $VERSION with the latest version
		TEMP_AUTO_UPDATE_TEXT=$(sed -r 's/\$VERSION/'$LATEST_VERSION'/g' $SCRIPT_PATH/configs/auto_update_text.txt)
		echo "$TEMP_AUTO_UPDATE_TEXT" > $SCRIPT_PATH/auto_update_text.txt
		AUTO_UPDATE_TEXT=$(sed -r 's/ /\\s/g' $SCRIPT_PATH/configs/auto_update_text.txt)
		AUTO_UPDATE_TEXT_LENGTH=$(echo -n $AUTO_UPDATE_TEXT | wc -c)
		AUTO_UPDATE_LENGTH_OVERHANG=`expr $AUTO_UPDATE_TEXT_LENGTH - 100`
		# Save old Text back to file
		TEMP_AUTO_UPDATE_TEXT=$(sed -r 's/'$LATEST_VERSION'/$VERSION/g' $SCRIPT_PATH/configs/auto_update_text.txt)
		echo "$TEMP_AUTO_UPDATE_TEXT" > $SCRIPT_PATH/configs/auto_update_text.txt

		# Update text
		# Replace $VERSION with the latest version
		TEMP_UPDATE_TEXT=$(sed -r 's/\$VERSION/'$LATEST_VERSION'/g' $SCRIPT_PATH/configs/update_text.txt)
		echo "$TEMP_UPDATE_TEXT" > $SCRIPT_PATH/configs/update_text.txt
		UPDATE_TEXT=$(sed -r 's/ /\\s/g' $SCRIPT_PATH/configs/update_text.txt)
		UPDATE_TEXT_LENGTH=$(echo -n $UPDATE_TEXT | wc -c)
		UPDATE_LENGTH_OVERHANG=`expr $UPDATE_TEXT_LENGTH - 100`
		# Save old Text back to file
		TEMP_UPDATE_TEXT=$(sed -r 's/'$LATEST_VERSION'/$VERSION/g' $SCRIPT_PATH/configs/update_text.txt)
		echo "$TEMP_UPDATE_TEXT" > $SCRIPT_PATH/configs/update_text.txt

		# Displayed username
		DISPLAYED_USER_NAME_TEXT=$(sed -r 's/ /\\s/g' $SCRIPT_PATH/configs/displayed_user_name.txt)
		DISPLAYED_USER_NAME_TEXT_LENGTH=$(echo -n $DISPLAYED_USER_NAME_TEXT | wc -c)
		DISPLAYED_USER_NAME_TEXT_OVERHANG=`expr $DISPLAYED_USER_NAME_TEXT_LENGTH - 30`

		if [ "$AUTO_UPDATE_TEXT_LENGTH" -gt "100" ]; then
			echo -en "${SCurs}Your 'update text' is to long! The maximum length is 100 chars! Minimize your text in the 'configs/auto_update_text.txt'. You are using $AUTO_UPDATE_LENGTH_OVERHANG chars to much.";
			echo -e "${RCurs}${MCurs}[ ${Red}ERROR ${RCol}]";
			exit 1;
		elif [ "$UPDATE_TEXT_LENGTH" -gt "100" ]; then
			echo -en "${SCurs}Your 'update text' is to long! Minimize your text in the 'configs/update_text.txt'. The maximum length is 100 chars! You are using $UPDATE_LENGTH_OVERHANG chars to much.";
			echo -e "${RCurs}${MCurs}[ ${Red}ERROR ${RCol}]";
			exit 1;
		elif [ "$DISPLAYED_USER_NAME_TEXT_LENGTH" -gt "30" ]; then
			echo -en "${SCurs}Your 'displayed username' is to long! Minimize your text in the 'configs/displayed_user_name.txt'. The maximum length is 30 chars! You are using $DISPLAYED_USER_NAME_TEXT_OVERHANG chars to much.";
			echo -e "${RCurs}${MCurs}[ ${Red}ERROR ${RCol}]";
			exit 1;
		fi
	fi
fi

if [ "$AUTO_UPDATE_PARAMETER" != "no" ]; then
	# If '--path' is given us it, else search for TeamSpeak 3 server directories
	if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
		echo -en "Searching for TeamSpeak 3 installation directories";
	else
		echo -en "${SCurs}Searching for TeamSpeak 3 installation directories";
		echo -e "${RCurs}${MCurs}[ ${Whi}.. ${RCol}]\n";
	fi

	if [ -n "$PARAMETER_PATH" ]; then
		if [ -d $PARAMETER_PATH ]; then
			echo "$PARAMETER_PATH/ts3server_startscript.sh" > TeamSpeak_Directories.txt

			if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
				echo -e "\t[ OK ]\n";
			else
				echo -e "${RCurs}${MCurs}[ ${Gre}OK ${RCol}]\n";
			fi

			echo "#############################################################";
			if [[ ! -s TeamSpeak_Directories.txt ]]; then
				echo "  It seems like, if you have not installed any TeamSpeak server.";
			else
				DIRECTORY_COUNTER=1
				while read paths; do
					TEAMSPEAK_DIRECTORY=$(dirname $paths)
					echo "  $DIRECTORY_COUNTER. Directory: $TEAMSPEAK_DIRECTORY";
					DIRECTORY_COUNTER=`expr $DIRECTORY_COUNTER + 1`
				done < TeamSpeak_Directories.txt
			fi
			echo -e "#############################################################\n";
		else
			if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
				echo -e "\t[ FAILED ]";
			else
				echo -e "${RCurs}${MCurs}[ ${Red}FAILED ${RCol}]";
			fi
			exit 1;
		fi
	else
		if [ ! $(find / -name 'ts3server_startscript.sh' 2> /dev/null | grep -v '/tmp/ts3server_backup' | sort > TeamSpeak_Directories.txt) ]; then
			if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
				echo -e "\t[ OK ]\n";
			else
				echo -e "${RCurs}${MCurs}[ ${Gre}OK ${RCol}]\n";
			fi

			echo "#############################################################";
			if [[ ! -s TeamSpeak_Directories.txt ]]; then
				echo "  It seems like, if you have not installed any TeamSpeak server.";
			else
				DIRECTORY_COUNTER=1
				while read paths; do
					TEAMSPEAK_DIRECTORY=$(dirname $paths)
					echo "  $DIRECTORY_COUNTER. Directory: $TEAMSPEAK_DIRECTORY";
					DIRECTORY_COUNTER=`expr $DIRECTORY_COUNTER + 1`
				done < TeamSpeak_Directories.txt
			fi
			echo -e "#############################################################\n";
		else
			if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
				echo -e "\t[ FAILED ]";
			else
				echo -e "${RCurs}${MCurs}[ ${Red}FAILED ${RCol}]";
			fi
			exit 1;
		fi
	fi
fi

# Get eMail for cronjob reports
EMAIL="$(cat $SCRIPT_PATH/configs/administrator_eMail.txt)"

# If option '--autoupdate yes' is set, install the cronjob for monday at 3 AM
if [ "$AUTO_UPDATE_PARAMETER" == "yes" ]; then
	echo -en "${SCurs}Installing new cronjob";
	echo -e "${RCurs}${MCurs}[ ${Whi}.. ${RCol}]";

	CRONJOB_MINUTE="0";

	echo -en "PATH=/usr/local/bin:/usr/bin:/bin\n" > /etc/cron.d/TS3UpdateScript;
	echo -en "MAILTO=\"$EMAIL\"\n\n" >> /etc/cron.d/TS3UpdateScript;
	echo -en "# TS3UpdateScript: Cronjob(s) for auto updates\n\n" >> /etc/cron.d/TS3UpdateScript;

	while read paths; do
		PARAMETER_PATH="$(dirname $paths)"

		if [ -n "$PARAMETER_PATH" ]; then
			echo -n "  $CRONJOB_MINUTE 3 * * 1  root $(pwd)/$(basename $0) " >> /etc/cron.d/TS3UpdateScript;
			echo -n "--path $PARAMETER_PATH " >> /etc/cron.d/TS3UpdateScript;
			echo -n "--cronjob-auto-update " >> /etc/cron.d/TS3UpdateScript;
			if [ "$CHECK" == "true" ]; then
				echo -n "--check " >> /etc/cron.d/TS3UpdateScript;
			fi
			if [ "$DELETE_OLD_LOGS" == "true" ]; then
				echo -n "--delete-old-logs " >> /etc/cron.d/TS3UpdateScript;
			fi
			if [ "$INFORM_ONLINE_CLIENTS" == "true" ]; then
				echo -n "--inform-online-clients " >> /etc/cron.d/TS3UpdateScript;
			fi
			echo -e "\n" >> /etc/cron.d/TS3UpdateScript;

			CRONJOB_MINUTE=`expr $CRONJOB_MINUTE + 10`
		fi
	done < TeamSpeak_Directories.txt

	echo -en "# ^ ^ ^ ^ ^\n" >> /etc/cron.d/TS3UpdateScript;
	echo -en "# | | | | |\n" >> /etc/cron.d/TS3UpdateScript;
	echo -en "# | | | | |___ Weekday (0-7, Sunday is mostly 0)\n" >> /etc/cron.d/TS3UpdateScript;
	echo -en "# | | | |_____ Month (1-12)\n" >> /etc/cron.d/TS3UpdateScript;
	echo -en "# | | |_______ Day (1-31)\n" >> /etc/cron.d/TS3UpdateScript;
	echo -en "# | |_________ Hour (0-23)\n" >> /etc/cron.d/TS3UpdateScript;
	echo -en "# |___________ Minute (0-59)" >> /etc/cron.d/TS3UpdateScript;

	# Set correct permissions for file
	chmod 644 /etc/cron.d/TS3UpdateScript

	if [[ $? -eq 0 ]]; then
		echo -e "${RCurs}${MCurs}[ ${Gre}OK ${RCol}]";
	else
		echo -e "${RCurs}${MCurs}[ ${Red}FAILED ${RCol}]";
	fi

	if [ -f TeamSpeak_Directories.txt ]; then
		rm TeamSpeak_Directories.txt
	fi

	exit 0;
fi

# If option '--autoupdate no' is set, deinstall the cronjob of monday at 3 AM
if [ "$AUTO_UPDATE_PARAMETER" == "no" ]; then
	echo -en "${SCurs}Deinstalling cronjob";
	echo -e "${RCurs}${MCurs}[ ${Whi}.. ${RCol}]";

	if [ -f /etc/cron.d/TS3UpdateScript ]; then
		rm /etc/cron.d/TS3UpdateScript
	fi

	if [[ $? -eq 0 ]]; then
		echo -e "${RCurs}${MCurs}[ ${Gre}OK ${RCol}]";
	else
		echo -e "${RCurs}${MCurs}[ ${Red}FAILED ${RCol}]";
	fi

	exit 0;
fi



#################################################################
#								#
#	G E T/F E T C H  N E E D E D  I N F O R M A T I O N S	#
#								#
#################################################################



while read paths; do
	# Get current root directory of installed TeamSpeak 3 server
	TEAMSPEAK_DIRECTORY=$(dirname $paths)

	# Copy password-file to root directory of TeamSpeak 3 server
	if [ ! -f $TEAMSPEAK_DIRECTORY/password-file ]; then
		cp -f password-file $TEAMSPEAK_DIRECTORY
	fi

	# Fetch latest version from www.teamspeak.com
	if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
		echo -en "Searching for installed version, architecture and owner";
	else
		echo -en "${SCurs}Searching for installed version, architecture and owner";
		echo -e "${RCurs}${MCurs}[ ${Whi}.. ${RCol}]\n";
	fi

	# Get owner and group of TeamSpeak 3 server files
	USER="$(stat --format='%U' $(find $TEAMSPEAK_DIRECTORY -name 'ts3server_startscript.sh' 2> /dev/null | sort | tail -1))"
	USER_ID=$(grep "$USER" /etc/passwd | cut -d ":" -f 3)
	GROUP="$(stat --format='%G' $(find $TEAMSPEAK_DIRECTORY -name 'ts3server_startscript.sh' 2> /dev/null | sort | tail -1))"
	GROUP_ID=$(grep "$USER" /etc/passwd | cut -d ":" -f 4)

	# Get installed TeamSpeak 3 server version
	INSTALLED_VERSION="$(cat $(find $TEAMSPEAK_DIRECTORY -name 'ts3server*_0.log' 2> /dev/null | sort | tail -1) | egrep -o 'TeamSpeak 3 Server ((\.)?[0-9]{1,3}){1,3}\.[0-9]{1,3}' | egrep -o '((\.)?[0-9]{1,3}){1,3}\.[0-9]{1,3}')"

	if [[ "$INSTALLED_VERSION" == "" ]]; then
		INSTALLED_VERSION="Unknown"
	fi

	# Get installed TeamSpeak architecture
	ARCHITECTURE="$(ls $(find $TEAMSPEAK_DIRECTORY -name 'ts3server_*_*' 2> /dev/null | grep -v 'ts3server_minimal_runscript.sh' | sort | tail -1) | egrep -o  '(amd64|x86)' | tail -1)"

	if [[ "$ARCHITECTURE" == "" ]]; then
		ARCHITECTURE="Unknown"
	fi

	# Check, if "Linux" or "FreeBSD" is installed
	if [ -e "$TEAMSPEAK_DIRECTORY/ts3server_linux_$ARCHITECTURE" ]; then
		LINUX_OR_FREEBSD="linux"
		LINUX_OR_FREEBSD_UPPER_CASE="Linux"
	elif [ -e "$TEAMSPEAK_DIRECTORY/ts3server_freebsd_$ARCHITECTURE" ]; then
		LINUX_OR_FREEBSD="freebsd"
		LINUX_OR_FREEBSD_UPPER_CASE="FreeBSD"
	fi

	# Check, if MySQL-Database exists
	TEAMSPEAK_DATABASE_TYPE=$(find $TEAMSPEAK_DIRECTORY -name 'ts3db_mysql.ini' 2> /dev/null | sort | tail -1)

	if [[ "$TEAMSPEAK_DATABASE_TYPE" == "" ]]; then
		TEAMSPEAK_DATABASE_TYPE="SQLite"
	else
		TEAMSPEAK_DATABASE_TYPE="MySQL"
	fi

	# Does the INI-File 'ts3server.ini' exist?
	if [[ "$TEAMSPEAK_DATABASE_TYPE" == "MySQL" ]]; then
		INI_FILE_NAME=$(basename $(find $TEAMSPEAK_DIRECTORY -name 'ts3server.ini' 2> /dev/null | sort | tail -1))
	else
		INI_FILE_NAME="Unknown"
	fi

	# Get ServerQuery Port and IP
	if [ -f $TEAMSPEAK_DIRECTORY/ts3server.ini ]; then
		TEAMSPEAK_SERVER_QUERY_PORT=$(cat $TEAMSPEAK_DIRECTORY/ts3server.ini | grep query_port | cut -d "=" -f 2)

		if [[ "$TEAMSPEAK_SERVER_QUERY_PORT" == "" ]]; then
			TEAMSPEAK_SERVER_QUERY_PORT="Unknown"
		fi

		TEAMSPEAK_SERVER_QUERY_IP=$(cat $TEAMSPEAK_DIRECTORY/ts3server.ini | grep query_ip | cut -d "=" -f 2 | grep -Ev "query_ip_[a-z]+list.txt")

		if [[ "$TEAMSPEAK_SERVER_QUERY_IP" == "" ]] && [[ "$TEAMSPEAK_SERVER_QUERY_IP" == "0.0.0.0" ]]; then
			TEAMSPEAK_SERVER_QUERY_IP="Unknown"
		fi
	else
		TEAMSPEAK_SERVER_QUERY_PORT="10011"
		TEAMSPEAK_SERVER_QUERY_IP="127.0.0.1"
	fi

	# Get TSDNS PID, if it is running/in use
	if [ $(ps opid= -C "tsdnsserver_"$LINUX_OR_FREEBSD"_"$ARCHITECTURE) ]; then
		TSDNS_PID=$(ps opid= -C "tsdnsserver_"$LINUX_OR_FREEBSD"_"$ARCHITECTURE)

		TSDNS_STATUS="Running"
	else
		TSDNS_STATUS="Not running"
	fi

	if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
		echo -e "\t[ INFO ]";
	else
		echo -e "${RCurs}${MCurs}[ ${Cya}INFO ${RCol}]";
	fi


	#########################################
	#					#
	#	M A I N  P R O G R A M		#
	#					#
	#########################################



	# Check, if given serveradmin password is correct
	if [ "$INFORM_ONLINE_CLIENTS" == "true" ]; then
		if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
			echo -en "Checking serveradmin password for perhaps server update notifications";
		else
			echo -en "${SCurs}Checking serveradmin password for perhaps server update notifications";
			echo -e "${RCurs}${MCurs}[ ${Whi}.. ${RCol}]\n";
		fi

		SERVERADMIN_PASSWORD=$(cat $TEAMSPEAK_DIRECTORY/password-file)

		(
			echo open $TEAMSPEAK_SERVER_QUERY_IP $TEAMSPEAK_SERVER_QUERY_PORT
			sleep 2s
			echo "login serveradmin $SERVERADMIN_PASSWORD"
			sleep 1s
			echo "logout"
			echo "quit"
		) | telnet > TEMP_LOGIN.txt 2> /dev/null

		if [[ "$(grep -Eo 'invalid[a-z\]+password' TEMP_LOGIN.txt)" != "invalid\sloginname\sor\spassword" ]]; then
			if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
				echo -e "\t[ OK ]\n";
			else
				echo -e "${RCurs}${MCurs}[ ${Gre}OK ${RCol}]\n";
			fi

			LOGIN_STATUS="Successfull";
		else
			if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
				echo -e "\t[ FAILED ]\n";

				echo -en "Please provide the correct 'serveradmin' password in the following file: $TEAMSPEAK_DIRECTORY/password-file";
				echo -e "\t[ INFO ]\n";
			else
				echo -e "${RCurs}${MCurs}[ ${Red}FAILED ${RCol}]\n";

				echo -en "${SCurs}Please provide the correct 'serveradmin' password in the following file: $TEAMSPEAK_DIRECTORY/password-file";
				echo -e "${RCurs}${MCurs}[ ${Cya}INFO ${RCol}]\n";
			fi

			LOGIN_STATUS="Unsuccessfull";
		fi
	fi

	echo "#############################################################";
	echo "	Latest Version        	: $LATEST_VERSION";
	echo "	Installed Version     	: $INSTALLED_VERSION";
	echo "	Installed Architecture	: $ARCHITECTURE";
	echo "	Installed Binary	: $LINUX_OR_FREEBSD_UPPER_CASE";
	echo
	echo "	Installation Directory	: $TEAMSPEAK_DIRECTORY";
	echo "	Files Owner		: $USER (UID $USER_ID)";
	echo "	Files Group		: $GROUP (GID $GROUP_ID)";
	echo
	echo "	Database-Type		: $TEAMSPEAK_DATABASE_TYPE";

	if [[ "$TEAMSPEAK_DATABASE_TYPE" == "MySQL" ]]; then
		echo -e "	INI-File		: $INI_FILE_NAME";
	fi

	echo "	ServerQuery IP:		: $TEAMSPEAK_SERVER_QUERY_IP";
	echo "	ServerQuery Port	: $TEAMSPEAK_SERVER_QUERY_PORT";

	if [[ "$TSDNS_STATUS" == "Running" ]]; then
		echo "	TSDNS			: $TSDNS_STATUS (PID $TSDNS_PID)";
	else
		echo "	TSDNS			: $TSDNS_STATUS";
	fi

	if [ "$INFORM_ONLINE_CLIENTS" == "true" ]; then
		echo
		echo "	Displayed Username	: $(cat $SCRIPT_PATH/configs/displayed_user_name.txt)";
		echo "	Update Text (Manually)	: $(sed -r 's/\$VERSION/'$LATEST_VERSION'/g' $SCRIPT_PATH/configs/update_text.txt)";
		echo "	Update Text (Cronjob)	: $(sed -r 's/\$VERSION/'$LATEST_VERSION'/g' $SCRIPT_PATH/configs/auto_update_text.txt)";
		echo "	Cronjob eMail Report	: $EMAIL";
	fi

	echo -e "#############################################################\n";

	if [[ "$INSTALLED_VERSION" == "Unknown" ]]; then
		if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
			echo -en "Could not identify your installed TeamSpeak 3 server version. Please check this manually!";
			echo -e "\t[ HINT ]";
		else
			echo -en "${SCurs}Could not identify your installed TeamSpeak 3 server version. Please check this manually!";
			echo -e "${RCurs}${MCurs}[ ${Gre}HINT ${RCol}]";
		fi
	fi

	if [[ "$ARCHITECTURE" == "Unknown" ]]; then
		if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
			echo -en "Could not identify your installed TeamSpeak 3 server architecture. Please check for updates of this script!";
			echo -e "\t[ FAILED ]";
		else
			echo -en "${SCurs}Could not identify your installed TeamSpeak 3 server architecture. Please check for updates of this script!";
			echo -e "${RCurs}${MCurs}[ ${Red}FAILED ${RCol}]";
		fi
		exit 1;
	fi

	if [[ "$TEAMSPEAK_DATABASE_TYPE" == "MySQL" ]]; then
		if [[ "$INI_FILE_NAME" == "Unknown" ]]; then
			if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
				echo -en "Could not find INI-File 'ts3server.ini'. It is needed for starting the TeamSpeak 3 server with MySQL database. Please provide this file!";
				echo -e "\t[ FAILED ]";
			else
				echo -en "${SCurs}Could not find INI-File 'ts3server.ini'. It is needed for starting the TeamSpeak 3 server with MySQL database. Please provide this file!";
				echo -e "${RCurs}${MCurs}[ ${Red}FAILED ${RCol}]";
			fi
			exit 1;
		fi
	fi

	# Check installed version against latest version
	# If latest version is not equal installed version ask the user for the update
	if [ "$INSTALLED_VERSION" == "$LATEST_VERSION" ] || [ "$INSTALLED_VERSION" == "Unknown" ]; then
		if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
			echo -en "Latest version is already installed. Nothing to do!";
			echo -e "\t[ INFO ]";
		else
			echo -en "${SCurs}Latest version is already installed. Nothing to do!";
			echo -e "${RCurs}${MCurs}[ ${Cya}INFO ${RCol}]";
		fi
	else
		# Cronjob function for auto update, if new version is available
		if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
			ANSWER="yes"
		else
			ANSWER=""
			while [[ "$ANSWER" == "" ]]; do
				read -p "Do you want to update your TeamSpeak 3 server? Please answer: ([y]es/[n]o) " ANSWER <&5

				if [[ -n "$ANSWER" ]] && [[ "$ANSWER" != "y" ]] && [[ "$ANSWER" != "yes" ]] && [[ "$ANSWER" != "n" ]] && [[ "$ANSWER" != "no" ]]; then
					echo -en "${SCurs}Illegal characters, please retry.";
					echo -e "${RCurs}${MCurs}[ ${Red}ERROR ${RCol}]";
					ANSWER=""
				fi
			done
		fi
	fi

	# Run the update process, if the user want to
	if [[ "$ANSWER" == "y" ]] || [[ "$ANSWER" == "yes" ]]; then
		# Inform online clients, that the server will be updated
		if [[ "$LOGIN_STATUS" == "Successfull" ]]; then
			echo -e "\nInforming online clients... This may take a while.\n";

			DISPLAYED_USER_NAME=$(sed -r 's/ /\\s/g' $SCRIPT_PATH/configs/displayed_user_name.txt)

			# Get serverlist
			(
				echo open $TEAMSPEAK_SERVER_QUERY_IP $TEAMSPEAK_SERVER_QUERY_PORT
				sleep 2s
				echo "login serveradmin $SERVERADMIN_PASSWORD"
				sleep 1s
				echo "serverlist"
				sleep 1s
				echo "logout"
				echo "quit"
			) | telnet > TEMP_SERVERLIST.txt 2> /dev/null || true

			# Get each clientlist of each virtual server
			cat TEMP_SERVERLIST.txt | grep -Eo "virtualserver_id=[0-9]+" | grep -Eo "[0-9]+" | while read virtualserver_id; do
				(
					echo open $TEAMSPEAK_SERVER_QUERY_IP $TEAMSPEAK_SERVER_QUERY_PORT
					sleep 2s
					echo "login serveradmin $SERVERADMIN_PASSWORD"
					sleep 1s
					echo "use sid=$virtualserver_id"
					echo "clientlist"
					sleep 1s
					echo "logout"
					echo "quit"
				) | telnet > TEMP_CLIENTLIST_$virtualserver_id.txt 2> /dev/null || true
			done

			(
				echo open $TEAMSPEAK_SERVER_QUERY_IP $TEAMSPEAK_SERVER_QUERY_PORT
				sleep 2s
				echo "login serveradmin $SERVERADMIN_PASSWORD"
				sleep 1s

				if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
					UPDATE_TEXT="$AUTO_UPDATE_TEXT"
				else
					UPDATE_TEXT="$UPDATE_TEXT"
				fi

				cat TEMP_SERVERLIST.txt | grep -Eo "virtualserver_id=[0-9]+" | grep -Eo "[0-9]+" | while read virtualserver_id; do
					echo "use sid=$virtualserver_id"

					echo "clientupdate client_nickname=$DISPLAYED_USER_NAME"

					# Just poke "normal" clients and no "ServerQuery" client
					cat TEMP_CLIENTLIST_$virtualserver_id.txt | tr "|" "\n" | grep "client_type=0" | grep -v "client_database_id=$(while read cldbid; do echo $cldbid; done < configs/ignore_clients.txt)" | awk '{print $1}' | cut -d "=" -f2 | while read client_id; do
						echo "clientpoke msg=$UPDATE_TEXT clid=$client_id"
					done
				done
				sleep 1s
				echo "logout"
				echo "quit"
			) | telnet > /dev/null 2> /dev/null || true
		fi

		# Wait 5 minutes, if it is a cronjob
		if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
			sleep 5m
		fi

		# Build download link for the TeamSpeak 3 server download
		TS3_SERVER_DOWNLOAD_LINK="http://dl.4players.de/ts/releases/$LATEST_VERSION/teamspeak3-server_$LINUX_OR_FREEBSD-$ARCHITECTURE-$LATEST_VERSION.tar.gz"

		# Stop running TSDNS server, if it is running
		if [[ "$TSDNS_STATUS" == "Running" ]]; then
			if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
				echo -en "Stopping running TSDNS server";
				echo -e "\t[ INFO ]";
			else
				echo -en "${SCurs}Stopping running TSDNS server";
				echo -e "${RCurs}${MCurs}[ ${Cya}INFO ${RCol}]";
			fi

			kill -9 $TSDNS_PID
		fi

		# Stop running TeamSpeak 3 server
		echo
		$TEAMSPEAK_DIRECTORY/ts3server_startscript.sh stop || true
		echo

		# Create Backup of currently installed TeamSpeak 3 server in '/tmp/ts3server_backup/root/of/installed/ts_server'
		if [ ! -d /tmp/ts3server_backup$TEAMSPEAK_DIRECTORY ]; then
			mkdir -p /tmp/ts3server_backup$TEAMSPEAK_DIRECTORY
		fi

		if [ "$DELETE_OLD_LOGS" == "true" ]; then
			if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
				echo -en "Deleting old TeamSpeak 3 server logs";
			else
				echo -en "${SCurs}Deleting old TeamSpeak 3 server logs";
				echo -e "${RCurs}${MCurs}[ ${Whi}.. ${RCol}]\n";
			fi

			if [ ! $(rm $TEAMSPEAK_DIRECTORY/logs/ts3server*.log) ]; then
				if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
					echo -e "\t[ OK ]";
				else
					echo -e "${RCurs}${MCurs}[ ${Gre}OK ${RCol}]";
				fi
			else
				if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
					echo -e "\t[ FAILED ]";
				else
					echo -e "${RCurs}${MCurs}[ ${Red}FAILED ${RCol}]";
				fi
			fi
		fi

		if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
			echo -en "\tCreating Backup of existing TeamSpeak 3 server";
		else
			echo -en "${SCurs}Creating Backup of existing TeamSpeak 3 server";
			echo -e "${RCurs}${MCurs}[ ${Whi}.. ${RCol}]\n";
		fi

		if [ ! $(rsync -a --no-inc-recursive --exclude 'files' $TEAMSPEAK_DIRECTORY/ /tmp/ts3server_backup$TEAMSPEAK_DIRECTORY 2> /dev/null) ]; then
			if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
				echo -e "\t[ OK ]";
			else
				echo -e "${RCurs}${MCurs}[ ${Gre}OK ${RCol}]";
			fi
		else
			if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
				echo -e "\t[ FAILED ]";
			else
				echo -e "${RCurs}${MCurs}[ ${Red}FAILED ${RCol}]";
			fi
		fi

		cd $TEAMSPEAK_DIRECTORY

		# Download latest TS3 Server files
		wget $TS3_SERVER_DOWNLOAD_LINK -q -O teamspeak3-server_$LINUX_OR_FREEBSD-$ARCHITECTURE-$LATEST_VERSION.tar.gz

		if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
			echo -en "Your server will be updated right now";
			echo -e "\t[ INFO ]";
		else
			echo -en "${SCurs}Your server will be updated right now";
			echo -e "${RCurs}${MCurs}[ ${Cya}INFO ${RCol}]";
		fi

		tar xf teamspeak3-server_$LINUX_OR_FREEBSD-$ARCHITECTURE-$LATEST_VERSION.tar.gz && cp -R teamspeak3-server_$LINUX_OR_FREEBSD-$ARCHITECTURE/* . && rm -rf teamspeak3-server_$LINUX_OR_FREEBSD-$ARCHITECTURE/

		if [ -f /tmp/ts3server_backup$TEAMSPEAK_DIRECTORY/licensekey.dat ]; then
			if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
				echo -en "Importing licensekey";
			else
				echo -en "${SCurs}Importing licensekey";
				echo -e "${RCurs}${MCurs}[ ${Whi}.. ${RCol}]\n";
			fi

			if [ ! $(mv /tmp/ts3server_backup$TEAMSPEAK_DIRECTORY/licensekey.dat $TEAMSPEAK_DIRECTORY) ]; then
				if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
					echo -e "\t[ OK ]";
				else
					echo -e "${RCurs}${MCurs}[ ${Gre}OK ${RCol}]";
				fi
			else
				if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
					echo -e "\t[ FAILED ]";
				else
					echo -e "${RCurs}${MCurs}[ ${Red}FAILED ${RCol}]";
				fi
			fi
		fi

		if [[ "$TEAMSPEAK_DATABASE_TYPE" == "SQLite" ]]; then
			if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
				echo -en "Importing SQLite database";
			else
				echo -en "${SCurs}Importing SQLite database";
				echo -e "${RCurs}${MCurs}[ ${Whi}.. ${RCol}]\n";
			fi

			if [ ! $(cp -f /tmp/ts3server_backup$TEAMSPEAK_DIRECTORY/ts3server.sqlitedb $TEAMSPEAK_DIRECTORY) ]; then
				if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
					echo -e "\t[ OK ]";
				else
					echo -e "${RCurs}${MCurs}[ ${Gre}OK ${RCol}]";
				fi
			else
				if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
					echo -e "\t[ FAILED ]";
				else
					echo -e "${RCurs}${MCurs}[ ${Red}FAILED ${RCol}]";
				fi
			fi
		fi

		if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
			echo -en "Importing Query IP white- and blacklist";
		else
			echo -en "${SCurs}Importing Query IP white- and blacklist";
			echo -e "${RCurs}${MCurs}[ ${Whi}.. ${RCol}]\n";
		fi

		if [ ! $(cp -f /tmp/ts3server_backup$TEAMSPEAK_DIRECTORY/query_ip_*.txt $TEAMSPEAK_DIRECTORY) ]; then
			if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
				echo -e "\t[ OK ]";
			else
				echo -e "${RCurs}${MCurs}[ ${Gre}OK ${RCol}]";
			fi
		else
			if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
				echo -e "\t[ FAILED ]";
			else
				echo -e "${RCurs}${MCurs}[ ${Red}FAILED ${RCol}]";
			fi
		fi

		# If Database-Type is "MySQL", import MySQL-Database and associated files
		if [[ "$TEAMSPEAK_DATABASE_TYPE" == "MySQL" ]]; then
			if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
				echo -en "Importing MySQL database and associated files as well as serverkey and INI-file";
			else
				echo -en "${SCurs}Importing MySQL database and associated files as well as serverkey and INI-file";
				echo -e "${RCurs}${MCurs}[ ${Whi}.. ${RCol}]\n";
			fi

			if [ ! $(cp -f /tmp/ts3server_backup$TEAMSPEAK_DIRECTORY/libts3db_mysql.so $TEAMSPEAK_DIRECTORY) ] && [ ! $(cp -f /tmp/ts3server_backup$TEAMSPEAK_DIRECTORY/serverkey.dat $TEAMSPEAK_DIRECTORY) ] && [ ! $(cp -f /tmp/ts3server_backup$TEAMSPEAK_DIRECTORY/ts3db_mysql.ini $TEAMSPEAK_DIRECTORY) ]&& [ ! $(cp -f /tmp/ts3server_backup$TEAMSPEAK_DIRECTORY/ts3server.ini $TEAMSPEAK_DIRECTORY) ]; then
				if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
					echo -e "\t[ OK ]";
				else
					echo -e "${RCurs}${MCurs}[ ${Gre}OK ${RCol}]";
				fi
			else
				if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
					echo -e "\t[ FAILED ]";
				else
					echo -e "${RCurs}${MCurs}[ ${Red}FAILED ${RCol}]";
				fi
			fi
		fi

		# If TSDNS server was running, import 'tsdns_settings.ini' file
		if [[ "$TSDNS_STATUS" == "Running" ]]; then
			if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
				echo -en "Importing TSDNS settings INI-file";
			else
				echo -en "${SCurs}Importing TSDNS settings INI-file";
				echo -e "${RCurs}${MCurs}[ ${Whi}.. ${RCol}]\n";
			fi

			if [ ! $(cp -f /tmp/ts3server_backup$TEAMSPEAK_DIRECTORY/tsdns/tsdns_settings.ini $TEAMSPEAK_DIRECTORY/tsdns/) ]; then
				if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
					echo -e "\t[ OK ]";
				else
					echo -e "${RCurs}${MCurs}[ ${Gre}OK ${RCol}]";
				fi
			else
				if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
					echo -e "\t[ FAILED ]";
				else
					echo -e "${RCurs}${MCurs}[ ${Red}FAILED ${RCol}]";
				fi
			fi
		fi

		if  [ -f ts3server.pid ]; then
			if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
				echo -en "Deleting existing ts3server.pid file";
			else
				echo -en "${SCurs}Deleting existing ts3server.pid file";
				echo -e "${RCurs}${MCurs}[ ${Whi}.. ${RCol}]\n";
			fi

			if [ ! $(rm ts3server.pid) ]; then
				if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
					echo -e "\t[ OK ]";
				else
					echo -e "${RCurs}${MCurs}[ ${Gre}OK ${RCol}]";
				fi
			else
				if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
					echo -e "\t[ FAILED ]";
				else
					echo -e "${RCurs}${MCurs}[ ${Red}FAILED ${RCol}]";
				fi
			fi
		fi

		# Delete downloaded TeamSpeak 3 server archive
		rm teamspeak3-server_$LINUX_OR_FREEBSD-$ARCHITECTURE-$LATEST_VERSION.tar.gz 2> /dev/null

		if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
			echo -en "Adjusting ownership and group of files";
			echo -e "\t[ INFO ]";
		else
			echo -en "${SCurs}Adjusting ownership and group of files";
			echo -e "${RCurs}${MCurs}[ ${Cya}INFO ${RCol}]";
		fi

		# Change owner and group of files
		if [[ "$GROUP" == "UNKNOWN" ]]; then
			chown $USER -R .
		elif [[ "$USER" == "UNKNOWN" ]]; then
			chgrp $GROUP -R .
		else
			chown $USER:$GROUP -R .
		fi

		# Start TSDNS, if it was started
		if [[ "$TSDNS_STATUS" == "Running" ]]; then
			# Change into TSDNS directory
			cd tsdns/

			if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
				echo -en "Starting TSDNS server ";
			else
				echo -en "${SCurs}Starting TSDNS server ";
				echo -e "${RCurs}${MCurs}[ ${Whi}.. ${RCol}]\n";
			fi

			su -c "./tsdnsserver_"$LINUX_OR_FREEBSD"_"$ARCHITECTURE" &" $USER

			# Change to root directory of TeamSpeak 3 server
			cd - > /dev/null

			# Sleep for a few seconds
			sleep 5s

			# Check, if the TSDNS server is still running
			if [ $(ps opid= -C "tsdnsserver_"$LINUX_OR_FREEBSD"_"$ARCHITECTURE) ]; then
				TSDNS_PID=$(ps opid= -C "tsdnsserver_"$LINUX_OR_FREEBSD"_"$ARCHITECTURE)

				if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
					echo -e "\t[ OK ]";
				else
					echo -e "${RCurs}${MCurs}[ ${Gre}OK ${RCol}]";
				fi
			else
				if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
					echo -e "\t[ FAILED ]";
				else
					echo -e "${RCurs}${MCurs}[ ${Red}FAILED ${RCol}]";
				fi
			fi
		fi

		# Add commandline parameter 'inifile=ts3server.ini' to ts3server_startscript.sh
		if [[ "$TEAMSPEAK_DATABASE_TYPE" == "MySQL" ]] || [ -f $TEAMSPEAK_DIRECTORY/ts3server.ini ]; then
			while read line; do
				if [[ "$line" == 'COMMANDLINE_PARAMETERS="${2}" #add any command line parameters you want to pass here' ]]; then
					echo 'COMMANDLINE_PARAMETERS="inifile=ts3server.ini" #add any command line parameters you want to pass here' >> TEMP_ts3server_startscript.sh;
				else
					echo $line >> TEMP_ts3server_startscript.sh;
				fi
			done < $TEAMSPEAK_DIRECTORY/ts3server_startscript.sh

			if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
				echo -en "Adding COMMANDLINE_PARAMETERS 'inifile=ts3server.ini' to ts3server_startscript.sh";
			else
				echo -en "${SCurs}Adding COMMANDLINE_PARAMETERS 'inifile=ts3server.ini' to ts3server_startscript.sh";
				echo -e "${RCurs}${MCurs}[ ${Whi}.. ${RCol}]\n";
			fi

			if [ ! $(cp -f TEMP_ts3server_startscript.sh $TEAMSPEAK_DIRECTORY/ts3server_startscript.sh) ]; then
				if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
					echo -e "\t[ OK ]";
				else
					echo -e "${RCurs}${MCurs}[ ${Gre}OK ${RCol}]";
				fi
			else
				if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
					echo -e "\t[ Failed ]";
				else
					echo -e "${RCurs}${MCurs}[ ${Red}Failed ${RCol}]";
				fi
			fi
		fi

		su -c "$TEAMSPEAK_DIRECTORY/ts3server_startscript.sh start" $USER

		# Check, if the './ts3server_startscript.sh start' command was successfull
		if [[ $? -eq 0 ]]; then
			if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
				echo -en "Script is checking TeamSpeak 3 server status";
				echo -e "\t[ INFO ]";
			else
				echo -en "${SCurs}Script is checking TeamSpeak 3 server status";
				echo -e "${RCurs}${MCurs}[ ${Cya}INFO ${RCol}]";
			fi

			# Sleep for a few seconds...
			sleep 15s

			# Check, if TS3 server is still runing
			TS_SERVER_STATUS=$(su -c "$TEAMSPEAK_DIRECTORY/ts3server_startscript.sh status" $USER)

			if [[ "$TS_SERVER_STATUS" == "Server is running" ]]; then
				if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
					echo -en "Your server was updated successfull";
					echo -e "\t[ INFO ]";
				else
					echo -en "${SCurs}Your server was updated successfull";
					echo -e "${RCurs}${MCurs}[ ${Cya}INFO ${RCol}]";
				fi

				if [[ -z "$KEEP_BACKUPS" ]]; then
					# Delete backup after successfull job
					BASE_DIRECTORY=$(echo "$TEAMSPEAK_DIRECTORY" | cut -d "/" -f2)
					rm -rf /tmp/ts3server_backup/$BASE_DIRECTORY 2> /dev/null
				fi
			fi
		else
			if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
				echo -en "Rollback to the version '$INSTALLED_VERSION', because the server could not start";
			else
				echo -en "${SCurs}Rollback to the version '$INSTALLED_VERSION', because the server could not start";
				echo -e "${RCurs}${MCurs}[ ${Whi}.. ${RCol}]\n";
			fi

			# Rollback to old installed version from backup
			if [ ! $(rsync -a /tmp/ts3server_backup$TEAMSPEAK_DIRECTORY/ $TEAMSPEAK_DIRECTORY 2> /dev/null && rm -rf /tmp/ts3server_backup$TEAMSPEAK_DIRECTORY 2> /dev/null) ]; then
				if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
					echo -e "\t[ OK ]";
				else
					echo -e "${RCurs}${MCurs}[ ${Gre}OK ${RCol}]";
				fi
			else
				if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
					echo -e "\t[ FAILED ]";
				else
					echo -e "${RCurs}${MCurs}[ ${Red}FAILED ${RCol}]";
				fi
			fi

			# Start TeamSpeak 3 server
			if [[ "$TEAMSPEAK_DATABASE_TYPE" == "MySQL" ]]; then
				su -c "rm teamspeak3-server_$LINUX_OR_FREEBSD-$ARCHITECTURE-$LATEST_VERSION.tar.gz && $TEAMSPEAK_DIRECTORY/ts3server_startscript.sh start inifile=ts3server.ini" $USER
			else
				su -c "rm teamspeak3-server_$LINUX_OR_FREEBSD-$ARCHITECTURE-$LATEST_VERSION.tar.gz && $TEAMSPEAK_DIRECTORY/ts3server_startscript.sh start" $USER
			fi

			if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
				echo -en "Your new server version could not start. Deployed backup of version '$INSTALLED_VERSION'";
				echo -e "\t[ INFO ]";
			else
				echo -en "${SCurs}Your new server version could not start. Deployed backup of version '$INSTALLED_VERSION'";
				echo -e "${RCurs}${MCurs}[ ${Cya}INFO ${RCol}]";
			fi
		fi

		cd - > /dev/null
	fi



	#########################
	#			#
	#	Clean up	#
	#			#
	#########################



	if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
		echo -en "Cleaning up system";
		echo -e "\t[ INFO ]";
	else
		echo -en "${SCurs}Cleaning up system";
		echo -e "${RCurs}${MCurs}[ ${Cya}INFO ${RCol}]";
	fi

	# Delete temp-files
	if [ -f $TEMPFILE_1 ]; then
		rm $TEMPFILE_1
	fi

	if [ -f $TEMPFILE_2 ]; then
		rm $TEMPFILE_2
	fi

	if [ -f $TEMPFILE_3 ]; then
		rm $TEMPFILE_3
	fi

	if [ -f TEMP_SERVERLIST.txt ]; then
		rm TEMP_SERVERLIST.txt
	fi

	rm TEMP_CLIENTLIST_*.txt 2> /dev/null || true
done < TeamSpeak_Directories.txt

if [ -f TeamSpeak_Directories.txt ]; then
	rm TeamSpeak_Directories.txt
fi

if [ -f TEMP_LOGIN.txt ]; then
	rm TEMP_LOGIN.txt
fi

if [ -f TEMP_ts3server_startscript.sh ]; then
	rm TEMP_ts3server_startscript.sh
fi

if [ "$CRONJOB_AUTO_UPDATE" == "true" ]; then
	echo -en "Finish!";
	echo -e "\t[ INFO ]";
else
	echo -en "${SCurs}Finish!";
	echo -e "${RCurs}${MCurs}[ ${Cya}INFO ${RCol}]";
fi

echo -e "\nDonations: https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=QMAAHHWHW3VQA";

# Restore stdin and close file descriptor 5
exec 0<&5 5>&-

unset TERM

exit 0;