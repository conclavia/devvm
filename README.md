# Background

Example scripts for setting up a development environment on Ubuntu (full or WSL) using Ansible.

Base installs for all systems:

- Various Linux command-line utilities
- AWS CLI (v2) + tooling (awslogs, cfn-flip, cfn-lint)
- Docker Compose
- .NET
- NodeJS (via NVM + Yarn)
- Python tooling (e.g. pipenv)

Optional tools for full Ubuntu installs:

- Chromium web browser
- Docker
- JetBrains IDEs
- Postman
- Visual Studio Code

Currently tested and working on Ubuntu 22.04.

## Instructions

1. Set a new virtual machine (e.g. using VirtualBox) and install [Ubuntu 22.04 Desktop](https://releases.ubuntu.com/22.04/) OR a new WSL 2 Ubuntu 22.04 environment.

For a full install:

- Select the **Minimal** installation type during setup.
- Make sure you install any virtual machine tooling (e.g. VirtualBox Guest Additions).

2. Install git and ansible.

```
sudo apt update
sudo apt -y install git ansible
```

3. Clone the devvm repository.

```
git clone https://github.com/conclavia/devvm.git
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

6. For a full VM setup, repeat steps 4-5 using the playbooks under the `full` directory.

```
sudo ansible-playbook full/system.yml
ansible-playbook full/user.yml
```

7. Reboot to complete the setup
