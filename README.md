# file-watcher

LowTech File Watcher

This script watches files that are edited, compiles the 'less' files, and then it uploads them to a remote server. It also optionaly can upload a file outside of the project directory to the server when a file is saved in the project. All of the options in the mat_watch.conf file are there, and can be uncommented if needed.  The mat_* files need to be in your project.  Place the other files where ever you put scripts.  Edit the mat_watch.bash file to point to the _main.bash file. Edit the mat_watch.conf file with your remote credentials.  Edit the includes.conf file to set witch files to watch for.  I have set a good ammount already for basic web coding needs.  Edit the path_excludes.conf file for any files or directories you would like to exclude.

Required commands:
sed
find
lessc
entr

Things to watch out for:
This script uses GNU Linux versions of 'sed', 'find' and 'lessc' so you should be able to run this from Linux, Windows WSL.  For the Mac you will need to install 'sed', 'find' and 'lessc' through Homebrew, since the Mac versions of those commands are different.  
If using WSL on Windows 10, then be aware that the 'entr' command in this script doesn't work anywhere but in the WSL Linux directory.

The entr command used in this script can only watch a certain ammount of files at a time, so you'll need to set the watchDir var in the mat_watch.conf file to somewhere close to the files you'll be editing or you'll see this error:
"entr: cannot create kqueue: Too many open files"
Also excluding directories in the path_excludes.conf file helps with that error too.  And if none of those tips work, restarting your terminals and editors may help.  I only had to do this once in a year on Windows WSL.
