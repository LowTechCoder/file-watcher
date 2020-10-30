script_path="$1"
scripts_path="$2"
source "$script_path/watch.conf"
source "$scripts_path/process_vars.bash"

function doUpload {    
    putPath="$1"
    putFile="$2"
    slash="$3"
    destPathFile="$4"
    allGood="$5"
    echo "$putPath"
    if [ "$protocol" == 'ftp' ]
    then
        (cd $putPath && lftp  ftp://$username:$password@$host -p $port -e  "$ftpCommands; cd $destPathFile; put $putFile; bye" && echo "$putFile" || echo "ERROR: $putFile")
    elif [ "$protocol" == 'sftp' ]
    then
        (cd "$putPath" && lftp sftp://$username:$password@$host -p $port -e "$sftpCommands; cd $destPathFile; put $putFile; bye" && echo "$putFile" || echo "ERROR: $putFile")
    fi
}

# this loop runs through the files to upload, but it also ensures that the doUpload doesn't happen when the script is initially run.
while read put; do
    if [ $put != "" ]
    then
        #remove file name after last slash
        putPath=$(echo $put | sed 's|\(.*\)/.*|\1|')
        #remove path
        putFile=$(echo $put | sed 's|.*/||' )
        if [[ "$put" == *"/"* ]]
        then
            slash="/"
        else
            slash=""
            putPath=""
        fi
       
        destPathFile="$remotePath/$putPath"
        allGood="true"

        doUpload "$putPath" "$putFile" "$slash" "$destPathFile" "$allGood"
    fi
done < "$scripts_path/files_to_send.conf"

autoUploadFileErr="false"
if [ -z "$externalAutoUploadFileSrc" ] # if empty
then
    autoUploadFileErr="true"
fi
if [ -z ${externalAutoUploadFileDest+x} ] # if unset
then
    autoUploadFileErr="true"
fi

if [ -z "$externalAutoUploadFileDest" ] # if empty
then
    externalAutoUploadFileDest='.'
fi

if [ "$autoUploadFileErr" == "false" ]
then
    if [ ! -r "$externalAutoUploadFileSrc" ] # if file doesn't exist or not readable
    then
        echo "ERROR: externalAutoUploadFileSrc doesn't exist or not readable"
        autoUploadFileErr="true"
    fi
    if [ ! -d $externalAutoUploadFileDest ] # if directory doesn't exist
    then
        echo "ERROR: externalAutoUploadFileDest doesn't exist"
        autoUploadFileErr="true"
    fi
fi

# this ensures that the autoUpload doesn't happen when the script is initially run.
if [ -s "$scripts_path/files_to_send.conf" ] && [ "$autoUploadFileErr" == "false" ]
then
    #remove file name after last slash
    if [[ "$externalAutoUploadFileSrc" == *\/* ]]
    then
        externalAutoUploadPath=$(echo $externalAutoUploadFileSrc | sed 's|\(.*\)/.*|\1|')
    else
        externalAutoUploadPath=''
    fi
    #remove path
    if [[ "$externalAutoUploadFileSrc" == *\/* ]]
    then
        externalAutoUploadFileName=$(echo $externalAutoUploadFileSrc | sed 's|.*/||' )
    else
        externalAutoUploadFileName="$externalAutoUploadFileSrc"
    fi

    if [[ "$put" == *"/"* ]]
    then
        slash="/"
    else
        slash=""
        putPath=""
    fi
    destPathFile="$externalAutoUploadFileDest"
    allGood="true"
    doUpload "$externalAutoUploadPath" "$externalAutoUploadFileName" "$slash" "$remotePath/$externalAutoUploadFileDest" "$allGood"
else
    echo "autoUpload skipped"
fi

echo "host: $host"