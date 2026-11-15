# Smart System Monitor and Resource Manager

OS Lab (CSC-251L) semester project, Fall 2026, Sukkur IBA University
Shifa Batool (023-24-0095), Alia (023-24-0097), Syeda Dua Shah (023-24-0081), Section D

This is a system monitor for Linux. The part that reads the system is written in C (it reads /proc and uses fork, pipe, dup2, signals and pthreads), and the window you see is written in Python with Tkinter. You can watch CPU, RAM, swap and disk live, search and kill processes, play with a few OS algorithms (scheduling, Banker's, page replacement, threads, pipes) and save a report.

It only runs on Linux. We built and tested it on Ubuntu inside Oracle VirtualBox, so these steps are written for that setup. It will not run on plain Windows.

## What you need

- VirtualBox with an Ubuntu virtual machine (we used 2 GB RAM, one core is enough)
- The project zip (SmartSystemMonitor_v2.zip)
- Internet inside the VM, at least for the first time, to install a few packages

## Step 1: Get the project into Ubuntu

There are a few ways to do this. We used the shared folder, so that is explained first. If it gives you trouble, the other two are easier.

### Way 1: Shared folder

First unzip the project on Windows so you have a normal folder called SmartSystemMonitor. Open it and check that you can see backend, frontend, docs, tests, run.sh and so on directly inside. If you see another SmartSystemMonitor folder inside it, use that inner one instead.

Start Ubuntu. In the VM menu click Devices, then Insert Guest Additions CD image, and let it install. If nothing happens, open a terminal in Ubuntu and run this instead:

```bash
sudo apt update
sudo apt install build-essential dkms linux-headers-$(uname -r) -y
sudo apt install virtualbox-guest-utils virtualbox-guest-dkms -y
```

Now go to Devices > Shared Folders > Shared Folders Settings and click the little folder icon with a plus. Choose the SmartSystemMonitor folder from Windows as the path. Put SmartSystemMonitor as the folder name. Tick Auto-mount and Make Permanent, leave Read-only unticked, press OK.

Your Ubuntu user needs permission to open shared folders, so run this and restart the VM:

```bash
sudo usermod -aG vboxsf $USER
sudo reboot
```

After it restarts, check that the folder is there:

```bash
ls /media
ls -la /media/sf_SmartSystemMonitor
```

You should see sf_SmartSystemMonitor, and inside it backend, build.sh, docs, frontend, README.md, requirements.txt, run.sh and tests.

Do not run the project from the shared folder. Copy it to your home folder first:

```bash
mv ~/SmartSystemMonitor ~/SmartSystemMonitor_old 2>/dev/null
mkdir -p ~/SmartSystemMonitor
cp -r /media/sf_SmartSystemMonitor/. ~/SmartSystemMonitor/
cd ~/SmartSystemMonitor
ls -la
```

(The first line just moves an old copy out of the way if you already had one. It is fine if it prints nothing.)

### Way 2: Drag and drop

In the VM menu choose Devices > Drag and Drop > Bidirectional (this also needs Guest Additions from above). Drag the zip from Windows into the Ubuntu Home folder, then:

```bash
cd ~
sudo apt install unzip -y
unzip SmartSystemMonitor_v2.zip
cd ~/SmartSystemMonitor
```

### Way 3: Download inside Ubuntu

If the zip is on Google Drive or GitHub, open Firefox in Ubuntu, download it, and then:

```bash
cd ~
sudo apt install unzip -y
unzip ~/Downloads/SmartSystemMonitor_v2.zip -d ~
cd ~/SmartSystemMonitor
```

For a USB stick, use Devices > USB in the VM menu to connect it, then copy the zip from the file manager.

Whichever way you pick, you should end up inside a folder that has run.sh in it. If `ls` doesn't show run.sh, you are one folder too high or too low.

## Step 2: Install what it needs

Run this once:

```bash
sudo apt update
sudo apt install build-essential python3 python3-tk python3-venv unzip -y
```

build-essential gives us gcc for the C part, python3-tk is the Tkinter window library, and python3-venv is used by run.sh to install ReportLab (only needed for PDF reports).

## Step 3: Run it

```bash
cd ~/SmartSystemMonitor
bash run.sh
```

run.sh does everything: it compiles the C backend if it isn't compiled yet, checks that Tkinter is installed, tries to install ReportLab, and then opens the window. The first time can take a little while, especially the ReportLab part, because it needs internet. If there is no internet it just skips it, and only the PDF button stops working. Text and CSV reports are fine.

When the window opens, leave it running. The CPU number shows 0 for the first second or so, that is normal because CPU usage needs two readings to compare.

To close it press Ctrl+Q or just close the window. If you only want to compile the backend without opening the app, use `bash build.sh`.

## Step 4: Check that it works

```bash
bash tests/test_backend.sh
```

At the end it should say `Passed: 16   Failed: 0`. The tests check the system readings, the Banker's algorithm, FCFS and SJF waiting times, the page replacement results (FIFO 15, LRU 12, Optimal 9 faults), the pipe demo, the mutex demo, and that killing PID 1 is refused.

To check the numbers in the app are real, compare them with these:

```bash
top -bn1 | head -5
free -h
df -h /
```

To watch the CPU go up, start something heavy in another terminal and stop it afterwards:

```bash
yes > /dev/null &
kill %1
```

There is also a manual checklist in docs/TEST_PLAN.md.

## Using the app

There are five pages on the left.

Dashboard shows the CPU, RAM, swap and disk gauges, a live graph of CPU and RAM, one bar per CPU core, uptime, load average, number of processes and threads, network and disk speed, context switches, temperature, the five busiest processes and any alerts.

Process Manager is a live table of all processes. You can search by name, PID or user, click a column to sort, and use the buttons (or right-click) to Terminate, Force Kill, Pause, Resume or Renice the selected process.

OS Lab has our simulations. The Scheduling tab runs FCFS, SJF, SRTF, Priority, Preemptive Priority and Round Robin and draws a Gantt chart, and there is a "compare all" button. The Banker's tab checks if a state is safe and whether a request can be granted. The Page Replacement tab does FIFO, LRU and Optimal. The Threads and IPC tab runs the race condition versus mutex demo, producer/consumer, and the fork + pipe + dup2 examples.

Reports makes a PDF, a text report and CSV files of the usage history and the process list. Everything is saved in the reports folder.

Settings lets you change how often the app samples and the alert limits.

Shortcuts: Ctrl+1 to Ctrl+5 change page, F5 refreshes, Ctrl+Q quits.

If you want to try the project quickly, this is roughly what we show in the demo: open the Dashboard, run `yes > /dev/null &` in a terminal, find `yes` in the Process Manager and terminate it, then go to OS Lab and run the scheduling sample with "compare all", the Banker's textbook example, page replacement with 3 frames, the threads and IPC buttons, and finally make a PDF in Reports.

## Using the backend from the terminal

The C program can be used on its own too:

```bash
./backend/os_backend sysinfo
./backend/os_backend snapshot
./backend/os_backend processes
./backend/os_backend kill PID TERM
./backend/os_backend renice PID 5
./backend/os_backend threads-demo
./backend/os_backend prodcons-demo
./backend/os_backend ipc-demo
./backend/os_backend banker-demo
printf '3\n0 5 2\n1 3 1\n2 8 4\n' | ./backend/os_backend sched rr 2
printf '3 9\n7 0 1 2 0 3 0 4 2\n' | ./backend/os_backend pagerepl lru
```

For kill, the signal can be TERM, KILL, STOP, CONT, INT or HUP.

## What is in the folder

```
SmartSystemMonitor/
  backend/backend.c        the C backend
  frontend/                the Python GUI
    main.py                main window and navigation
    core.py                talks to the backend, background sampler thread
    widgets.py             gauges, graphs, Gantt chart
    pages_monitor.py       Dashboard and Process Manager
    pages_lab.py           OS Lab
    pages_misc.py          Reports and Settings
    report.py              PDF, text and CSV reports
  tests/test_backend.sh    the 16 automatic checks
  docs/                    report outline and test plan
  reports/                 generated reports go here
  build.sh                 compiles the backend
  run.sh                   builds if needed, then starts the app
  requirements.txt         ReportLab (optional)
```

The idea is simple. The C program reads /proc and answers one command at a time. A Python thread runs in the background, calls it every second and stores the numbers. The pages only draw what is stored. That is why switching tabs does not reset the graph.

## If something goes wrong

Permission denied on /media/sf_SmartSystemMonitor: you probably skipped the usermod command or didn't restart. Run `sudo usermod -aG vboxsf $USER` and reboot.

The folder /media/sf_SmartSystemMonitor does not exist: check Devices > Shared Folders again (the name must be SmartSystemMonitor and Auto-mount must be ticked), make sure Guest Additions are installed, and reboot. You can also mount it by hand with `sudo mkdir -p /mnt/share && sudo mount -t vboxsf SmartSystemMonitor /mnt/share`.

"Tkinter is missing": `sudo apt install python3-tk -y`

"gcc not found": `sudo apt install build-essential -y`

"C backend is not compiled": go to the project folder and run `bash build.sh`.

Errors like `bad interpreter: /bin/bash^M` or `$'\r': command not found`: the files got Windows line endings. Fix it with `sed -i 's/\r$//' run.sh build.sh tests/test_backend.sh` and run again.

"Permission denied" when you type ./run.sh: use `bash run.sh`, or run `chmod +x run.sh build.sh tests/test_backend.sh` once.

PDF button is greyed out: ReportLab did not install. Connect the VM to the internet and run `bash run.sh` again, or try `sudo apt install python3-reportlab -y`.

No window opens, or you get a "no display" error: run it from the terminal on the Ubuntu desktop, not over SSH. In VirtualBox settings you can also raise Display > Video Memory to 64 MB or more.

Numbers stay at 0: wait a few seconds. If they still don't move, run `./backend/os_backend snapshot` and see if it prints values.

Temperature says n/a: that is normal in a virtual machine, there is no sensor to read.

Cannot kill a process: Linux only lets you signal your own processes. PID 1 and the monitor itself are blocked on purpose.

## A few notes

CPU % is worked out from two readings of /proc/stat. For a single process, 100% means one full core. Memory is resident memory. Disk usage is for the main file system, and disk speed is counted for whole disks, not per process. The scheduling, Banker's and page replacement parts are simulations for learning, they are not the kernel's real algorithms. Temperature usually isn't available in a VM.
