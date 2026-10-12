# Ansible NGINX Configuration Lab

## Overview

This lab demonstrates configuration management with Ansible by installing, configuring, validating, and managing NGINX on a remote Ubuntu virtual machine.

The lab uses an Ansible control node (`ansiblemaster`) to manage a remote target (`ansibleslave`) over SSH.

## Architecture

- **Control node:** `ansiblemaster`
- **Managed node:** `ansibleslave`
- **Automation tool:** Ansible Core
- **Operating system:** Ubuntu
- **Web server:** NGINX
- **Configuration management:** YAML playbook

## Objectives

- Configure Ansible inventory and SSH connectivity.
- Install NGINX on a remote host.
- Manage NGINX configuration using Ansible modules.
- Resolve a port conflict with an existing Apache service.
- Validate the NGINX configuration before relying on it.
- Ensure NGINX is running and enabled at boot.
- Verify idempotency by running the playbook repeatedly.

## Implementation

The playbook is [`nginx-setup.yml`](./nginx-setup.yml).

It performs the following tasks:

1. Installs NGINX using the Ansible APT module.
2. Configures the IPv4 listener on port `8080`.
3. Configures the IPv6 listener on port `8080`.
4. Validates the configuration with `nginx -t`.
5. Ensures the NGINX service is started and enabled.
6. Reloads NGINX when listener configuration changes.

## Port Conflict Resolution

Apache was already listening on port `80` on the managed node. To allow both web servers to coexist, NGINX was configured to listen on port `8080`, while Apache remained on port `80`.

| Service | Port | Verified state |
|---|---:|---|
| Apache | 80 | Listening |
| NGINX | 8080 | Listening |

## Running the Playbook

From the Ansible control node, run:

```bash
ansible-playbook -i /etc/ansible/hosts /etc/ansible/nginx-setup.yml
```

The inventory must define the managed host `ansibleslave` and its reachable SSH address.

## Verification

### Check Ansible connectivity

```bash
ansible ansibleslave -m ping
```

### Check listening ports

```bash
ansible ansibleslave -b -m command -a "ss -ltnp"
```

### Validate NGINX configuration

```bash
ansible ansibleslave -b -m command -a "nginx -t"
```

### Verify HTTP response

```bash
ansible ansibleslave -m command -a "curl -I http://127.0.0.1:8080/"
```

The test returned:

```text
HTTP/1.1 200 OK
Server: nginx/1.28.3 (Ubuntu)
```

### Verify service state

```bash
ansible ansibleslave -m command -a "systemctl is-active nginx"
```

Expected result:

```text
active
```

## Idempotency

The playbook was executed again after the configuration was complete. The final run reported:

```text
ok=6 changed=0 unreachable=0 failed=0
```

This confirms that all six tasks completed successfully, no further changes were necessary, and no tasks failed.

## Key Learnings

- Ansible inventory and remote host management
- SSH-based automation
- YAML playbooks and Ansible modules
- Privilege escalation with `become`
- NGINX service and configuration management
- Diagnosing web-server port conflicts
- Configuration validation and idempotency

## Scope

This is a hands-on configuration-management lab on Ubuntu virtual machines. The HTTP test was performed locally on the managed node;