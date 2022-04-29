# Background

Example scripts for setting up a development VM using Ansible.

Includes:
* Various Linux command-line utilities
* AWS CLI (v2) + tooling (cfn-flip, cfn-lint, saml2aws)
* Chromium web browser
* Docker
* Docker Compose
* .NET
* JetBrains IDEs
* NodeJS (via NVM + Yarn)
* Postman
* Python tooling (e.g. pipenv)
* Visual Studio Code

Currently tested and working on Ubuntu 22.04.

## Instructions

1. Create a new virtual machine (e.g. using VirtualBox) and install [Ubuntu 22.04 Desktop](https://releases.ubuntu.com/22.04/).
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

4. Run the system playbook (for system-wide installs and config)
```
cd devvm
sudo ansible-playbook system.yml
```

5. Run the user playbook (for user-profile level installs and config)
```
ansible-playbook user.yml
```

6. Set the font in your Ubuntu terminal to "FiraCode Nerd Font Mono" so the Starship glyphs will work

