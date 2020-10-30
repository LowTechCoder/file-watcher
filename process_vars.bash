remotePath=$(echo $remotePath | sed 's#/$##g')

if [ "$remotePath" == "" ]
then
    remotePath='.'
fi

watchDir=$(echo $watchDir | sed 's#/$##g')
