
script_path="$PWD"
source "$script_path/watch.conf"
#remove file name after last slash
scripts_path=$(echo $0 | sed 's|\(.*\)/.*|\1|')

source "$scripts_path/process_vars.bash"

includes=''

path_excludes=''
cat "$scripts_path/path_excludes.conf" |
    awk '{$1=$1};1' | # remove extra spaces, and add new line at EOF 
    sed 's/^#.*$//g' | # remove commented lines
    grep -v '^$' > "$scripts_path/tmp2.tmp" # remove empty lines

sed -i -e '$a\' "$scripts_path/tmp2.tmp" # add new line at eof if not there

while read p; do
    path_excludes=$path_excludes$(printf " ! -path '$p'")
done < "$scripts_path/tmp2.tmp"
path_excludes=$(echo "$path_excludes" | sed 's#^ -o ##g') # remove first -o

sed -i -e '$a\' "$scripts_path/includes.conf" # add new line at eof if not there

cat "$scripts_path/includes.conf" |
    awk '{$1=$1};1' | # remove extra spaces, and add new line at EOF 
    sed 's/^#.*$//g' | # remove commented lines
    grep -v '^$'  > "$scripts_path/tmp.tmp" # remove empty lines

while read p; do # join lines with loop
    includes=$includes$(printf " -o -iname '$p'") # append
done < "$scripts_path/tmp.tmp"

#test the connection and show files/dirs
source "$scripts_path/connection_test.bash"

includes=$(echo "$includes" | sed 's#^ -o ##g') # remove first -o
eval_this=$(echo "find '$watchDir' \( $includes \) \( $path_excludes \)")

while true; do eval "$eval_this" | entr -d bash "$scripts_path/file_watch_commands.bash" "$script_path" "$scripts_path"; done
