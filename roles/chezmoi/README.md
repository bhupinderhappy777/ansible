Role Name
=========

Ansible role to manage user dotfiles with chezmoi.

Requirements
------------

- `chezmoi` package installed (can be installed by this role)
- Dotfiles repository compatible with chezmoi source-state format

Role Variables
--------------

- `chezmoi_home`: The target destination directory (defaults to `ansible_facts['user_dir']`)
- `chezmoi_repo`: Dotfiles repository URL (defaults to `clone_dotfiles_repo`)
- `chezmoi_branch`: Repository branch (defaults to `clone_dotfiles_branch` or `main`)
- `chezmoi_source_path`: The directory where dotfiles source will be cloned (defaults to `chezmoi_home/.local/share/chezmoi`)
- `chezmoi_install_package`: Install `chezmoi` package via system package manager (defaults to `true`)
- `chezmoi_force_apply`: Run `chezmoi apply --force` (defaults to `false`)

Dependencies
------------

None.

Example Playbook
----------------

    - hosts: all
      roles:
        - role: chezmoi

License
-------

MIT
