## 4. Integration in Molecule (Test-Setup)

In Molecule werden die Variablen für den Test-Container lokal im `platforms`-Block simuliert. Da in den Containern kein Sudo-Passwort benötigt wird, läuft Molecule weiterhin vollautomatisch ohne Passwort-Eingabe durch.

**Wichtig für `gather_facts`:** Damit das Sammeln von Systemfakten im minimalen Docker-Container nicht fehlschlägt, nutzen wir das `pre_build_image: false` (oder installieren Python/Pakete vorab), um sicherzustellen, dass Ansible die nötigen Systemwerkzeuge im Container vorfindet.

```yaml
---
dependency:
  name: galaxy
driver:
  name: docker
platforms:
  - name: ubuntu2604-test-host
    image: ubuntu:26.04
    # Sichert ab, dass Ansible im Container ordnungsgemäß Facts sammeln kann:
    pkg_extras:
      - python3
      - iproute2
    # ... Deine bestehende Konfiguration für SSH, User und Keys ...
    
    # HIER: Zuweisung der Feature-Flags für die Test-Instanz
    vars:
      monitoring_node_exporter: true
      monitoring_process_exporter: true
      monitoring_windows_exporter: false

provisioner:
  name: ansible
verifier:
  name: ansible
```

Damit bist du auf beiden Seiten perfekt abgesichert: Deine Produktion läuft sicher verschlüsselt über **Ansible Vault**, und deine **Molecule-Container** stürzen beim Faktensammeln nicht mehr ab!

Möchtest du als Nächstes sehen, wie du das **Sudo-Passwort elegant im Ansible Vault hinterlegst**, damit du es beim Ausführen nicht jedes Mal manuell eintippen musst?


## 7. Infrastruktur-Check & System-Report (Sanity Check)

Dieses Playbook prüft nicht nur die Erreichbarkeit und Sudo-/Admin-Rechte, sondern sammelt auch die wichtigsten Systemdaten (Betriebssystem, IP, Architektur) und gibt sie als übersichtlichen Report im Terminal aus. Es funktioniert universell für Linux und Windows.

Erstelle diese Datei auf der obersten Ebene deines Inventory-Repos:

### Datei: `check-infrastructure.yml`
```yaml
---
- name: "Sanity Check: Überprüfe Server und erstelle System-Report"
  hosts: all
  gather_facts: true   # Aktiviert das automatische Sammeln von Systeminfos
  become: "{{ ansible_connection | default('') != 'winrm' and ansible_connection | default('') != 'psrp' }}"
  # Aktiviert 'become' (sudo) nur für Linux, da Windows standardmäßig als Admin läuft

  tasks:
    - name: "1. System-Report generieren (Linux)"
      ansible.builtin.debug:
        msg:
          - "========================================="
          - "HOST:       {{ inventory_hostname }}"
          - "SSH-USER:   {{ ansible_user | default('Standard-User') }}"
          - "IP (Ansible): {{ ansible_host }}"
          - "IP (System):  {{ ansible_default_ipv4.address | default('Keine IPv4') }}"
          - "OS:         {{ ansible_distribution }} {{ ansible_distribution_version }}"
          - "ARCH:       {{ ansible_architecture }}"
          - "TYP:        {{ ansible_virtualization_type | default('Physikalisch') }}"
          - "========================================="
      when: ansible_os_family != 'Windows'

    - name: "2. System-Report generieren (Windows)"
      ansible.builtin.debug:
        msg:
          - "========================================="
          - "HOST:       {{ inventory_hostname }}"
          - "WIN-USER:   {{ ansible_user | default('Standard-User') }}"
          - "IP (Ansible): {{ ansible_host }}"
          - "IP (System):  {{ ansible_ip_addresses | select('match', '^192\\.|^10\\.|^172\\.') | first | default('Keine IP') }}"
          - "OS:         {{ ansible_distribution }} (Version: {{ ansible_distribution_version }})"
          - "ARCH:       {{ ansible_architecture }}"
          - "========================================="
      when: ansible_os_family == 'Windows'
```

### Wie du den Report ausführst:

```bash
# Wechsle in dein neues Inventory-Repo
cd /pfad/zu/deinem/neuen/inventory-repo/

# Führe den Check aus. Falls du Linux-Server mit Sudo-Passwort hast, füge '-K' hinzu
ansible-playbook -i production.yml check-infrastructure.yml -K
```

### Wie die Ausgabe im Terminal aussieht:
Ansible gibt dir für jeden Server einen wunderschönen, eingerückten Block aus:

```text
TASK [2. System-Report generieren (Linux)] *************************************
ok: [app-server-01] => {
    "msg": [
        "=========================================",
        "HOST:       app-server-01",
        "SSH-USER:   srv_admin_alpha",
        "IP (Ansible): 192.168.1.50",
        "IP (System):  192.168.1.50",
        "OS:         Ubuntu 26.04",
        "ARCH:       x86_64",
        "TYP:        kvm",
        "========================================="
    ]
}
```

### Erklärung der wichtigsten Variablen für deine lokale KI:
* **`inventory_hostname`**: Der Name, den du links in der `production.yml` eingetragen hast (dein konfigurierter Wunsch-Hostname).
* **`ansible_host`**: Die IP, die du in den `host_vars/` hinterlegt hast, um den Server zu erreichen.
* **`ansible_default_ipv4.address`**: Die tatsächliche primäre IP-Adresse, die das Betriebssystem auf seiner Netzwerkkarte konfiguriert hat. (Perfekt, um zu prüfen, ob deine `host_vars` mit der Realität übereinstimmen!).
* **`ansible_distribution`**: Erkennt automatisch, ob es ein `Ubuntu`, `Debian`, `CentOS` oder `Windows Server 2022` ist.
