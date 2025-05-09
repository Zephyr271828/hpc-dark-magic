# HPC Dark Magic

Ok, this project is not altogether "dark", but some gadgets I find pretty useful for HPC. 

## Move Data
Just as the name suggests, this script provides an efficient approach to transfer data from one HPC to another, without the pain of downloading to local first and then uploading the files.

## Set Up
Personally, I often have to log into different HPCs to check where I can get the compute resources I need. Therefore, it is often the case I sync my codebase on HPCs via git yet still need to modify the environment configurations and project directories, etc.  
What the script `setup.sh` does is: it automatically detects which host you're on and set up the required configurations (which is project-specific, and you need to customize it yourself. But once customized, you will be save a lot of time in the future).  
Another feature introduced is `sbash`. The name comes from a combination of `bash` and `sbatch`. The usage is like this:
```bash
# script.sh

#!/bin/bash
source setup.sh
check_sbash cool_job_%j 16 16 2 1 "tandon_h100_1,tandon_a100_2"

# your actual script below
python test.py
```
What it does is:
- when you `bash script.sh`, it simply sets up the env and run the actual content.
- when you `sbash script.sh`, it creates a temporary script, adds the sbatch header, and copies everything below check_sbash to that tmp script, `sbatch` the tmp script, and finally removes it.

I'm not sure whether this sounds convenient to others but I find it pretty efficient.

## Fast Login
Although many of you should be familiar with how to configure ssh-key, there are some hosts that disable ssh-key verification and require 2FA, which is annoying. `fast_login.sh` spawns the host, interacts with it and types password and option automatically, and all you need to do is to click DUO on your phone! 
```bash
# usage
expect fast_login.sh
``` 
However, you should be aware the constraints and risks of this method:
1. this only works in terminal, but not on vscode remote-ssh extension, because vscode remote-ssh invokes ssh in a non-interactive mode, where automatic interaction is impossible.
2. you should be aware that simply put your password in a script has its risks. I'm 100\% sure there are ways to encrypt the password, which is one of the future directions of this project.

## Debug
Well, you know we can first sbatch a job and then ssh to the node to do some interactive node. I don't really want to explain what `keep_alive.py` does but you may find it pretty useful.