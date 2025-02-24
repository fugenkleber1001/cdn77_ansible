Vašim cílem je vytvořit virtuální infrastrukturu zajišťující některé elementární úkony, které se v našem prostředí vyskytují. Některé úkoly jsou navazující, některé lze přeskočit a věnovat se jiným. Task je koncipován tak, aby zde byla možnost prokázat znalost prakticky libovolné z námi používaných technologií a zároveň aby vybízel k přiměřenému studiu technologií nových. Je tudíž nepravděpodobné, že se Vám podaří dokončit vše. Bonusové úkoly řešte pouze, pokud danou technologii znáte a zaberou Vám minimum času.

### Úkoly

Pomocí technologie typu Proxmox/KVM/Docker/LXC/… si vytvořte libovolný počet virtuálních PC či kontejnerů založených na OS Debian. Jednotlivé VM/kontejnery použijte ke zprovoznění následujících služeb:

---

### 1. **Monitoring**
  - Použijte **Prometheus** a příslušné **exportery** ke sběru metrik z ostatních VM/kontejnerů.
  - **BONUS**: Data z libovolného exporteru zobrazte v **Grafana dashboardu**.
  - **BONUS2**: Nastavte libovolné pravidlo pro **Alertmanager** na základě dat libovolného exporteru.

---

### 2. **nginx**
  - První instanci **nginxu** nastavte jako **web server** hostující soubory z lokálního disku.
  - Druhou instanci nastavte jako **reverzní proxy server**, který využívá první nginx instanci jako svůj **upstream**.
  - **BONUS**: Při komunikaci **proxy <> upstream** použijte **keepalive connections**.
  - **BONUS2**: Při komunikaci **proxy <> client** použijte **bezpečně nastavené SSL/TLS connections**.

---

### 3. **Alespoň jeden distribuovaný systém z níže uvedeného seznamu**
  - Kafka, Clickhouse, Etcd, Ceph, Citus, Cockroach, ELK, Zookeeper
  - Zprovozněte **cluster odolávající výpadku 2 instancí služby**.

---

### 4. **Vlastní skript/program v libovolném jazyce běžící jako daemon, tj. na pozadí**
  - Pro udržování běhu použijte **daemontools**.
  - **BONUS daemontools**: Použijte integrovaný **multilog**.
  - Spusťte jej na jednom libovolném předchozím vytvořeném **VM/kontejneru**.
  - Použijte jej k **testování funkcionality jednotlivých zprovozněných služeb** periodickým zápisem následujících stavových informací do souboru:
    - **Monitoring**: Metriku vyjadřující **load** VM/kontejnerů.
    - **nginx**: **Request/Response** stub status modulu včetně hlaviček.
  - Formát zapisovaných dat nechť je **human readable** a jednoduše **strojově zpracovatelný**.

---

Vytvoření infrastruktury, setup jednotlivých služeb atd. by mělo být plně automatizováno pomocí **Ansible** a odevzdáno jako **zazipovaný git repozitář** (přiložený k mailu) obsahující jednotlivé **Ansible playbooky**.
Playbooky by měly být ve stavu **připraveném ke spuštění** pro jednoduchou replikaci celé infrastruktury a ověření funkcionality jednotlivých služeb.
Vypracovaný úkol bude testován na OS **Debian Bookworm**, běžící ve virtuálním serveru nad technologií **Proxmox**.
