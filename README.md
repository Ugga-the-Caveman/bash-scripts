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
Remove all old scripts.
Then move directory with scripts.
```
sudo rm -r /usr/ugga-bash-scripts
sudo mv -vi ugga-bash-scripts/* /usr/ugga-bash-scripts
```
