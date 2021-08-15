# chromebook-ansible
### A project to bootstrap and configure the Linux/Crostini environment on Chrome OS devices with Ansible  

The Linux subsystem in Chrome OS allows you to install and run both graphic and command-line utilities in a Debian container.  
In addition to Android app support, this feature helps fill gaps between web-based apps and local, native binaries.   
While Chrome OS syncs all your native and Android configuration to your Google account, the Linux container is excluded from this sync.  (You can create a Linux backup and save it to Google Drive, but this is a manual process.)  
*chromebook-ansible* provides an easy path to automate a full, custom setup for Linux on Chrome OS.  
*Since Chrome OS uses a Debian container, this project should run on other Debian based systems including Windows Subsystem for Linux (WSL).*  

#### The project features:
- A bootstrap script to prepare a fresh Linux container for Ansible configuration
- Full Linux system configuration through Ansible  
- The option to use separate git repositories for core Ansible playbooks and user-defined custom config, enabling:
  - Use of the core public repository for code to get future updates and fixes without forking and merging in git.
  - A separate private repository for your configuration, arbitrary customizations and (encrypted) secrets
- Modular includes for common applications: VS Code, Terraform, Docker, gcloud GCP command line tools, etc.  *See: [*Included Applications*](#Included-Applications)*  

*Note: This is not an officially supported Google product*

---
###### Navigate: | [*Top*](#chromebook-ansible) | [*Quick Start*](#Quick-Start) | [*Full Setup*](#Full-Setup) | [*Included-Applications*](#Included-Applications) | [*Architecture*](#Architecture) |  
---
### Quick Start
*If you choose Quick Start now, you will still be able to run a Full Setup on top of a Quick Start without erasing your Linux partition.*
- [Set up Linux on your Chromebook](https://support.google.com/chromebook/answer/9145439?hl=en)  
  This project requires a fresh Linux environment.  If you have an existing Linux container, [back it up](https://support.google.com/chromebook/answer/9592813), then delete and replace it.  
- For installation within a VirtualBox VM, [install the Guest Additions](https://www.virtualbox.org/manual/ch04.html) first to enable pasting from the host OS.
- Open the Terminal App, paste the following command to download and run the bootstrap script.  (Terminal requires ctrl-shift-v to paste)  
  `curl -q -o ./bootstrap.sh https://raw.githubusercontent.com/seangreathouse/chromebook-ansible/master/bootstrap.sh && bash ./bootstrap.sh`  
  <!-- *Short URL*  
  `curl -q -L -o ./bootstrap.sh https://bit.ly/boot-ans && bash ./bootstrap.sh`   -->
- At the prompt select "1" for a Quick Start deployment.  
  The bootstrap script should now run uninterrupted.  
- When the script is done enter:
  `source ~/.bashrc` to read necessary environment variables  
  then `chromebook-ansible-playbook` to launch Ansible configuration.  
  Ansible should now run uninterrupted  
- When Ansible is done, force the Linux container to stop using `sudo init 0` 
- You can now re-open Terminal to use command-line apps, or open graphic-interface apps via the *Linux apps* folder in the Launcher.  
- See [*Full Setup*](#Full-Setup) for advanced use.  
  
---
###### Navigate: | [*Top*](#chromebook-ansible) | [*Quick Start*](#Quick-Start) | [*Full Setup*](#Full-Setup) | [*Included-Applications*](#Included-Applications) | [*Architecture*](#Architecture) |  
---
### Full Setup
The bootstrap script in the [*Quick Start*](#Quick-Start) deployment pulls all required playbooks and files from the public [chromebook-ansible](https://github.com/seangreathouse/chromebook-ansible) repository via HTTPS, building a usable Linux subsystem based on project defaults.  
Full setup uses the public *chromebook-ansible* repository for Ansible playbooks with a private *chromebook-config* repository to store your own configuration.   
This de-couples your personal config from the public project, allowing both to be updated separately without merges or conflicts.   
*You can run a Full Setup on top of a Quick Start without erasing your Linux partition*  

Pre-requisites for a Full Setup:  
- A Github account configured with [ssh key authentication](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh)
- A private config repository *e.g. chromebook-ansible-config* in your Github account.
- Your private config repository must contain copies of the following from the main *chromebook-ansible* repo.  
  - *ansible.cfg*
  - *hosts.yml*
  - *includes_custom*
  - *playbooks_custom*
- The files in your private config repo mask their analogs in *chromebook-ansible* public repo, allowing you to make your own modifications.  See [*Architecture*](#Architecture) and [*Explanation of Full Setup mode*](#Explanation-of-Full-Setup-mode) for details on how this works.  
  
To run a Full Setup:  
- [Set up Linux on your Chromebook](https://support.google.com/chromebook/answer/9145439?hl=en)  
  This project requires a fresh Linux environment, *unless you just ran the Quick Start*.  If you have an existing Linux container, [back it up](https://support.google.com/chromebook/answer/9592813), then delete and replace it. 
- Open the Terminal App, paste the following command to download and run the bootstrap script.  (Terminal requires ctrl-shift-v to paste)  
  `curl -q -o ./bootstrap.sh https://raw.githubusercontent.com/seangreathouse/chromebook-ansible/master/bootstrap.sh && bash ./bootstrap.sh`  
- At the prompt select "2" for a Full Setup deployment.  
- The script will now prompt you for:  
  - *hostname* - Hit \<enter\> to use the default *localhost*.  Since the playbooks always run locally, this works.  
    Advanced: If you want to manage multiple devices with separate configurations, enter a custom hostname like *work-chromebook.local* to distinguish between multiple Chrome OS devices.  
  A custom hostname used here must already exist in your *hosts.yml*, otherwise Ansible will fail.
  - *Github repository url* - Hit \<enter\> unless you have your own fork of the main *chromebook-ansible* repository.  
  - *Github config repository url* - Paste the [clone url](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository) from your *chromebook-config* repository.  The URL should be the ssh format starting with `git@github.com/...` 
  - *Ansible vault key* - [ansible-vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html) is not required, but its use is strongly encouraged if you plan to store any sensitive information in your config repo.  
     Key is stored in *~/.config/ansible/vault-pw.txt*.  Keep a backup of the key in your password manager or other secure storage.  
  - *Private ssh key* - Paste (ctrl-shift-v) your private ssh key here.  Hit \<enter\> to create a new-line, then ctrl-d to submit.  
  - *Public ssh key*  - Paste (ctrl-shift-v) your private ssh key here.  Hit \<enter\> to create a new-line, then ctrl-d to submit. 
- When the script is done enter:
  `source ~/.bashrc` to read necessary environment variables  
  then `chromebook-ansible-playbook` to launch Ansible configuration.   
  Ansible should now run uninterrupted  
- When Ansible is done, stop the container using `sudo init 0` 
- You can now re-open Terminal to use command-line apps, or open GUI apps via the *Linux apps* folder in the Launcher. 
- To update your system run *git pull* in either or both repos, then re-run `chromebook-ansible-playbook` 
---
###### Navigate: | [*Top*](#chromebook-ansible) | [*Quick Start*](#Quick-Start) | [*Full Setup*](#Full-Setup) | [*Included-Applications*](#Included-Applications) | [*Architecture*](#Architecture) |  
---
### Included Applications  
- *debian_base* - Not an application, but this playbook runs an apt-get upgrade and installs some basic utilities.
- [*docker*](https://www.docker.com/) - Local Docker CE installation
- [*gcloud*](https://cloud.google.com/sdk/gcloud) - Google Cloud command line utilities - run `gcloud init` to finish configuration.
- [*gimp*](https://www.gimp.org/) - Photo editing app
- [*master_pdf*](https://code-industry.net/masterpdfeditor/) - PDF Editor, great for searching and manipulating large PDFs.
- [*terraform*](https://www.terraform.io/) - IACFTW
- [*vscode*](https://code.visualstudio.com/) - Everyone's new best IDE.
---
###### Navigate: | [*Top*](#chromebook-ansible) | [*Quick Start*](#Quick-Start) | [*Full Setup*](#Full-Setup) | [*Included-Applications*](#Included-Applications) | [*Architecture*](#Architecture) |  
--- 
### Architecture
A reference for the moving parts of this implementation.    

__System Walkthrough__  
- __bootstrap.sh__  -  Bash script  
Starting with a fresh install of linux, *bootstrap.sh* prepares the system to run the Ansible playbooks.  
It only needs to be run once, but can be run again to switch between [*Quick Start*](#Quick-Start) and [*Full Setup*](#Full-Setup) modes as described above.    
*bootstrap.sh* sets:   
  - The bash alias *chromebook-ansible-playbook* in *~/.bashrc*  
  - An optional */etc/hosts* entry so the system can be called on a custom hostname.  See *hosts.yml* below.  
To make the shell alias available for the next step, the system prompts you to run `source $HOME/.bashrc`  
- __*chromebook-ansible-playbook*__   -  Bash command alias.  
This alias sets both bash environment and Ansible variables to properly run the main *chromebook_setup.yml* ansible playbook per the settings configured by *bootstrap.sh*.  
Breakdown of *chromebook-ansible-playbook*:  
  - *export ANSIBLE_CONFIG=/home/username/git/chromebook-config/*  -   Sets the [*ANSIBLE_CONFIG*](https://docs.ansible.com/ansible/latest/reference_appendices/config.html) environment variable to point to the directory containing *ansible.cfg*  
  - *cd /home/username/git/chromebook-ansible*  -  The *chromebook_setup.yml* playbook expects to be called from the root repo directory.  
  - *ansible-playbook ./chromebook_setup.yml --extra-vars "cb_localhost=localhost*  -  Call the playbook, and set the *cb_localhost* variable.  See *hosts.yml* below for more detail.  
  - *unset  ANSIBLE_CONFIG*  -  Remove the environment variable to allow other Ansible playbooks to run on the system if needed.  
 
- __*ansible.cfg \**__  -- Ansible configuration file  
Defines the location of the inventory file *hosts.yml* and optional [ansible-vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html) key file.  
- __*hosts.yml \**__  -  Ansible [inventory](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html) file  
Inventory of hosts with per-host preference settings.  
Ansible is designed to run against multiple remote hosts using hostnames to address each host on the network and determine what tasks or plays run against them.  
Since this implementation always runs locally, you can use the default *localhost* for one or more systems so long as the systems require the same configuration.         
To differentiate between systems that require separate configurations, add per-system sections.  
The *hosts.yml* included in the project has an example *my_chromebook.local* configuration in addition to the default *localhost*.  
To use a unique hostname, enter the hostname configured in *hosts.yml* at the hostname prompt when you run *bootstrap.sh* or add a line to */etc/hosts* - eg `127.0.0.1  my_chromebook.local`  
*hosts.yml* contains the variables you use to control which parts of the system are run against your host.   
For each of the provided task includes there are a set of variables to enable or disable the tasks.  
In the example below, the `vscode_include` variable controls whether the system installs Visual Studio Code.  
The `vscode_custom_include` allows you to set the path for additional tasks to run for VSCode.  The custom include will only be run if the primary `vscode_include` is enabled as well.  
`vscode_include: true  
vscode_custom_include: "{{ ansible_config }}includes_custom/vscode/vscode_custom.yml"`  

- __*chromebook__setup.yml*__  - The main playbook, that calls task includes based on the variables set in *hosts.yml*  
- __*includes*__ -  Directory containing the stock task lists to install applications.  
- __*includes_custom\**__ -  Directory containing the user-defined task lists to install additional packages and files.  
For example, you could install your own preferred list of plugins or key bindings for VSCode.  
*chromebook__setup.yml* calls a single custom task list for each application.  It can also call a single *user_defined_custom_include* for arbitrary user-defined tasks.  
- __*playbooks__custom \**__  - Contains a single user-defined playbook.  Similar to *user_defined_custom_include* but a full playbook vs a task list.  
---
#### Explanation of Full Setup mode  
As described above, Full Setup mode allows you to manage your own configurations for the project separately in your own Git repo.  
This allows you to pull updates to the public code without merging, while maintaining your own additions separately.  
Your config repo must contain copies of:  
*ansible.cfg*  
*hosts.yml*  
*includes_custom*  
*playbooks_custom*  
These files will remain in the main code repo, but will not be used by the system.  
When you set the *ANSIBLE_CONFIG* environment variable to point to the directory containing your config,  Ansible will use the *ansible.cfg* file from your custom config directory.  
That *ansible.cfg* in turn calls *hosts.yml* in your custom config directory.  
Ansible also uses an internal *ansible_config* variable to find your *includes_custom* and *playbooks_custom* directories.  

