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
Then set appropiate permissions.
```
chmod 755 ugga_bash_scripts -R
```

Replace old directory with new one.
```
sudo rm -r /usr/ugga_bash_scripts
sudo mv ugga_bash_scripts /usr/ugga_bash_scripts
```

There is a script that you can use to append the directory including all subdirectories to your path.
```
if [ -f "/usr/ugga_bash_scripts/shell_path_append_recursive.sh" ]
then
  source /usr/ugga_bash_scripts/shell_path_append_recursive.sh /usr/ugga_bash_scripts
fi
```
