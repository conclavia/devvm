# Background

Example scripts for setting up a development VM using Ansible.

Includes:
* AWS CLI (v2)
* Chromium web browser
* Docker
* Docker Compose
* .NET Core
* JetBrains IDEs
* NodeJS (via NVM + Yarn)
* Postman
* Python tooling (e.g. pipenv)
* Visual Studio Code

Currently tested and working on Ubuntu 20.04 LTS.

## Instructions

1. Create a new virtual machine (e.g. using VirtualBox) and install [Ubuntu 20.04 LTS Desktop](https://releases.ubuntu.com/20.04/).
   * Select the **Minimal** installation type during setup.
   * Make sure you install any virtual machine tooling (e.g. VirtualBox Guest Additions).

2. Install git and ansible.
```
sudo apt update
sudo apt -y install git ansible
```

3. Clone the devvm repository.
```
git clone git@github.com:conclavia/devvm.git
```

4. Run the ansible playbook
```
cd devvm
ansible-playbook -K devvm.yml
```