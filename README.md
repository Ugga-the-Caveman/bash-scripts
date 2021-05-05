### installation
Download all files from this repository.
```
wget https://github.com/Ugga-the-Caveman/ugga_bash_scripts/archive/main.zip
```

unzip the files.
```
7z x main.zip -o ugga_bash_scripts
```

Delete the scripts you dont need. 
Then execute this script.
```
ugga_bash_scripts/install.sh
```

Add this to your bashrc.
```
if [ -f "/usr/ugga_bash_scripts/shell_path_append_recursive.sh" ]
then
  source /usr/ugga_bash_scripts/shell_path_append_recursive.sh /usr/ugga_bash_scripts
fi
```
