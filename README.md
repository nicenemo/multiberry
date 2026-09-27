# CachyOS Gaming & AI Node Automation

An automated Infrastructure-as-Code repository built with Ansible to configure a dedicated gaming and AI machine (`multiberry`) running CachyOS. 

This repository streamlines system optimizations, kernel tuning, legacy GPU driver installation, system-wide environment variables, and pre-allocated directory structures specifically tailored for **Microsoft Flight Simulator 2024** and local **Large Language Models (Ollama)**.

---

## Targeted System Hardware Specs

* **Host Name:** `multiberry` (`192.168.105.101`)
* **CPU:** AMD Ryzen 7 3700X (8 Cores / 16 Threads)
* **RAM:** 32 GB DDR4 @ 3200 MHz
* **GPU:** NVIDIA GeForce GTX 1080 (8 GB GDDR5X, Gainward Phoenix)
* **Bootloader:** Limine
* **OS:** CachyOS (Arch Linux-based)

---

## Purpose & Optimization Strategy

### 1. Microsoft Flight Simulator 2024 (Proton / VKD3D)
* **Legacy 580xx Driver Stack:** Locks the system to NVIDIA's legacy 580xx proprietary drivers required for Pascal architecture (GTX 1080) under CachyOS, bypassing issues with newer driver branches dropping support or defaulting to non-functional open-source modules.
* **VKD3D Memory & DXR Overrides:** Sets `VKD3D_CONFIG=dxr0,no_upload_hacks` globally via `/etc/environment.d/` to strip DirectX Raytracing overhead and resolve memory allocation crashes in DirectX 12.
* **Pre-allocated Cache Directories:** Automatically creates the directory tree required for MSFS 2024 cloud streaming rolling cache to prevent Linux permission stalls.

### 2. Local AI & LLM Workloads (Ollama - *Planned*)
* **Pascal Acceleration:** Prepares the system for CUDA inference offloading using `llama.cpp` / `Ollama`. Optimizes standard CUDA core matrix math for 8B models (e.g., Llama 3.1 8B, DeepSeek-R1 8B) within the 8 GB VRAM buffer, while allowing hybrid CPU/DDR4 system memory offloading for larger models.
*(Dedicated Ollama installation and model management playbooks will be integrated in a future release.)*

### 3. Kernel & System Optimizations
* **Security Mitigations Disabled (`mitigations=off`):** Applied via `/etc/kernel/cmdline` for Limine to maximize CPU execution throughput on the Ryzen 3700X.
* **Latency & Frame-Time Tuning:** Applies `pci=rebar`, `split_lock_detect=off`, and `processor.max_cstate=1` to prevent VKD3D micro-stutters and split-lock frame drops.
* **Developer Environment:** Enforces Neovim (`nvim`) as the system-wide default text editor across shell profiles (`EDITOR`/`VISUAL`).

---

## Repository Structure

```text
.
├── README.md
├── ansible.cfg                 # Global Ansible execution parameters & SSH options
├── inventory.yml               # Target node definition (multiberry) and package lists
├── setup.yml                   # Master provisioning entry point
├── teardown.yml                # Master reversion entry point
├── ansible-user-teardown.yml   # Management user cleanup script
├── files/
│   └── 99-game-tuning.conf     # Global Proton, VKD3D, and default editor environment vars
└── playbooks/
    ├── base-setup.yml          # Core execution tasks (keyrings, kernel, drivers, packages)
    └── base-teardown.yml       # Cleanup and reversion tasks
