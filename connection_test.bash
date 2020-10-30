echo ""
echo "Local ls:"

lpath="."

pwd

ls -p --format=single-column > "$scripts_path/tmp.tmp"

rpath="$remotePath"
if [ "$remotePath" == '' ]
    rpath="."
then
    rpath="$remotePath"
fi

echo ""
echo "Remote ls:"
colorCommand="set color:dir-colors 'di=0;34'"
if [ "$protocol" == 'ftp' ]
then
    (cd $lpath && lftp ftp://$username:$password@$host -p $port -e "$ftpCommands; cd $rpath; cls -1; exit" || "$allGood" = 'false')  > "$scripts_path/tmp2.tmp"
elif [ "$protocol" == 'sftp' ]
then
    (cd $lpath && lftp sftp://$username:$password@$host -p $port -e "$sftpCommands; cd $rpath; cls -1; exit" || "$allGood" = 'false')  > "$scripts_path/tmp2.tmp"
fi

echo ""
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
printf "${BLUE}Local ls:${NC}\n"
cat "$scripts_path/tmp.tmp"
echo ""
printf "${BLUE}Remote ls:${NC}\n"
cat "$scripts_path/tmp2.tmp"
echo ""
printf "${BLUE}Local and Remote Matches:${NC}\n"
local_remote_matches=$(grep -Fxf "$scripts_path/tmp.tmp" "$scripts_path/tmp2.tmp") # show matching lines between 2 files
if [ "$local_remote_matches" == "" ]
then
    printf "${YELLOW}Warning: No matches${NC}\n"
else
    echo "$local_remote_matches"
fi
echo ""
