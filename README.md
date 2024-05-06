# Background

Example scripts for setting up a development environment on Ubuntu (full or WSL) using Ansible.

Base installs for all systems:

- Various Linux command-line utilities
- AWS CLI (v2) + tooling (awslogs, cfn-flip, cfn-lint)
- .NET
- NodeJS (via NVM + Yarn)
- Python tooling (e.g. pipenv)

Additional tools for full Ubuntu installs:

- Chromium web browser
- Docker
- JetBrains IDEs
- Postman
- Visual Studio Code

Currently tested and working on Ubuntu 24.04.

## Instructions

1. Set a new virtual machine (e.g. using VirtualBox) and install [Ubuntu 24.04 Desktop](https://releases.ubuntu.com/24.04/) OR a new WSL 2 Ubuntu 24.04 environment.

For a full install:

- Select the **Minimal** installation type during setup.
- Make sure you install any virtual machine tooling (e.g. VirtualBox Guest Additions).

2. Install make and git.

```
sudo apt update
sudo apt -y install make git
```

3. Clone the devvm repository.

```
git clone https://github.com/conclavia/devvm.git
```

4. Run the `dev` target to install all development tools

```
cd devvm
make dev
```

7. Reboot to complete the setup
