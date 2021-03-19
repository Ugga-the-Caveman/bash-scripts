### installation
Download all files from this repository.
```
wget https://github.com/Ugga-the-Caveman/ugga-bash-scripts/archive/main.zip
```

unzip the files.
```
7z x main.zip
```

Delete the scripts you dont need. 
Then set appropiate permissions.
```
chmod 755 ugga-bash-scripts -R
```

Replace old directory with new one.
```
sudo rm -r /usr/ugga_bash_scripts
sudo mv ugga-bash-scripts /usr/ugga_bash_scripts
```

There is a script that you can use to append the directory including all subdirectories to your path.
```
if [ -f "/usr/bashScripts/shellAppendPath.sh" ]
then
  source /usr/bashScripts/shellAppendPath.sh /usr/ugga_bash_scripts
fi
```
