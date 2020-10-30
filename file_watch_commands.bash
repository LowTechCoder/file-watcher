script_path="$1"
scripts_path="$2"
source "$script_path/watch.conf"
source "$scripts_path/process_vars.bash"

path_excludes=''
cat ~/.gitignore | 
    awk '{$1=$1};1' | # remove extra spaces, and add new line at EOF 
    sed 's/^#.*$//g' | # remove commented lines
    grep -v '^$'  > "$scripts_path/tmp2.tmp" # remove empty lines
sed -i -e '$a\' "$scripts_path/tmp2.tmp" # add new line at eof if not there

while read p; do
    path_excludes=$path_excludes$(printf " -o ! -path '$p'")
done < "$scripts_path/tmp2.tmp"
path_excludes=$(echo "$path_excludes" | sed 's#^ -o ##g') # remove first -o

includes=''
sed -i -e '$a\' "$scripts_path/includes.conf" # add new line at eof if not there

cat "$scripts_path/includes.conf" | 
    awk '{$1=$1};1' | # remove extra spaces, and add new line at EOF 
    sed 's/^#.*$//g' | # remove commented lines
    grep -v '^$'  > "$scripts_path/tmp.tmp" # remove empty lines

while read p; do # join lines with loop
    includes=$includes$(printf " -o -iname '$p'") # append
done < "$scripts_path/tmp.tmp"

includes=$(echo "$includes" | sed 's#^ -o ##g') # remove first -o

#use linux version of find command for this
eval_this=$(echo "find . -mmin 0.03 \( $includes \) \( $path_excludes \)")

date

#use linux version of find command for this
if [[ "$lessInput" != '' && "$lessOutput" != '' && `find "$stylesDir" -mmin 0.03` ]]
then
    find $lessInput > "$scripts_path/tmp.tmp" ###
    cat "$scripts_path/tmp.tmp" |
        sed 's#.less$##g' > "$scripts_path/tmp2.tmp" # remove the .less file ext
    while read p; do
        lessc "${p}.less" "${p}.css"
    done < "$scripts_path/tmp2.tmp"
else
    echo "Warning: not compiling less."
fi

(eval "$eval_this") > "$scripts_path/tmp.tmp"
cat "$scripts_path/tmp.tmp" | sed 's#^./##g' | # remove ./ from beginning of lines
    grep '\.css$' > "$scripts_path/files_to_send.conf" # get lines that end with .css

cat "$scripts_path/tmp.tmp" | sed 's#^./##g' | # remove ./ from beginning of lines
    grep -v '\.css$' >> "$scripts_path/files_to_send.conf" # get all other lines that don't end with .css (example: .less)

bash "$scripts_path/send_files_to_remote.bash" "$script_path" "$scripts_path"