# Lab 5: Active Directory (NOT READY)

## Lab 5: Active Directory (NOT READY)

{% hint style="danger" %}
READ: Any knowledge and techniques presented here are for your learning purposes only. It is **ABSOLUTELY ILLEGAL** to apply the learned knowledge to others without proper consent/permission, and even then, you must check and comply with any regulatory restrictions and laws.
{% endhint %}

In this guide, we will build an Active Directory environment in a virtualized lab and see how features can be exploited to hack Windows users. Active Directory (AD) is Microsoft’s service to manage Windows domain networks. 95% of Fortune 100 companies implement AD into their networks. The way you can use the same set of credentials, to log into any Windows machine within your given institution, is done through Active Directory. AD can easily span whole corporations and campuses, acting as a “phone book” for Windows desktops, printers, and other computers that need authentication services. For our purposes, our AD will span one server and X number of workstations.

## 5.1. VM setup

{% hint style="warning" %}
If using VirtualBox is giving you errors during the setup steps, you are recommended to try [VMware Workstation](https://www.vmware.com/au/products/workstation-player.html) instead. Most of the setup issues were resolved using the VMWare workstation based on the experience.&#x20;
{% endhint %}

You will need to use 3 VMs for this lab, one for each of the following:

* [Windows Server 2019](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2019)
* [Windows 10 Enterprise](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-10-enterprise)
* [Kali Linux](https://www.kali.org/get-kali/)

You will already have Kali, so you can set up the Windows Server 2019. If you also need Windows 10 Enterprise, download the ISO from the link provided. You can type in junks in the required fields, it will still take you to the ISO downloads page.

{% hint style="info" %}
M1/M2 users: you can follow these steps:

1. Add new VM in UTM and select Emulate
2. Select Windows and insert ISO, also uncheck UEFI Boot
3. set CPU to 2, then continue to finish.
4. set CPU type to QEMU64, and force multicore.
5. Start the VM.
6. Press any key to boot from CD/DVD (remove CD once the installation finishes)

Please note, this VM is very slow since it is emulated!
{% endhint %}

### 5.1.1 Setting Up Windows Server 2019 VM

{% hint style="info" %}
M1/M2 users, skip this part and scroll down.
{% endhint %}

Start the installation. Click "Next", leaving all options as default. Continue clicking "Next" until you reach the "Easy Install Information" window. Give whatever "Full Name" you'd like. Select "Windows Server Standard Core". Leave the product key blank.

![](../.gitbook/assets/lab-5-assets/1.png)

Keep clicking "Next" until the "Finish" button becomes available, again leaving all options as default. If any, before you click "Finish", uncheck the "Power on this virtual machine after creation" option, as there are a few more settings that we need to edit before we run the VM.

Click “Edit virtual machine settings” and:

* Remove the floppy disk
* Click on the "Options" tab → "Advanced" → under "Firmware Type", select "BIOS".
* You can also allocate additional resources if necessary

{% hint style="info" %}
M1/M2 users, start from here.
{% endhint %}

Follow the one-screen instructions and boot the VM. Click “Next”, then “Install Now”, then make sure to pick the “Windows Server 2019 Standard Evaluation (Desktop Experience)” option.

![](../.gitbook/assets/lab-5-assets/2.png)

Accept the license, click “Custom: Install Windows only (advanced)”, then click “Next”. This should commence the OS installation, which may take an extended period of time.

![](../.gitbook/assets/lab-5-assets/3.png)

The VM should then reboot on its own. Afterwhich, you should see the following "Customize Settings" screen. Use any password you'd like.

You should then see a login screen. In the VMware client, click the following button to send the `ctrl+alt+del` command to the PC and log in with the password you created earlier. The Server Manager should automatically start.

{% hint style="info" %}
M1/M2 users: you will set the password once the installation completes. When rebooted, you can press control + option + delete (fn + delete on laptops).
{% endhint %}

![](../.gitbook/assets/lab-5-assets/12.png)

Now rename your computer to make it easier to use by searching for "View your PC name" in the Windows search bar. We've chosen "DC-01" for this demonstration.

![](../.gitbook/assets/lab-5-assets/6.png)

At this point, you can "Power Off" this VM and move on to setting up the Windows 10 VM.

### 5.1.2 Using an existing Windows 10 VM

You can use your existing Windows 10 VM. Do this by making a duplicate of your existing one (ensure you randomize the MAC address to get a new IP address). You can skip the next section 5.1.3 and move on to section 5.1.4.

### 5.1.3 Setting Up a new Windows 10 Enterprise VM

"Create a New Virtual Machine” and after clicking the “Use ISO image:” button, browse for the Windows 10 Enterprise ISO file. Click "Next" then select the “Windows 10 Enterprise” edition. This machine will act as a user on the network.

Similar to in [5.1.1](lab-5-active-directory.md#5.1.1-setting-up-windows-server-2019-vm) keep clicking "Next" until the "Finish" button becomes available, leaving all options as default, including leaving the product key blank. Before you click "Finish", uncheck the "Power on this virtual machine after creation" option. Once the VM is set up, edit the following settings, similar to before:

* Remove the floppy disk
* Click on the "Options" tab → "Advanced" → under "Firmware Type", select "BIOS".
* You can also allocate additional resources if necessary

Start up the VM and follow the installation instructions.&#x20;

Once you reach the "Sign in with Microsoft" screen, select “Domain join instead”.

Name your user account anything you'd like. Same with the password. You can set up any security questions you'd like; these aren't too important since the VM will be used just for the purposes of this lab. You can decline all the tracking, digital assistance, and privacy settings for the same reason.

### 5.1.4 Preparing the network discovery

Once the Windows VM is booted up, click on the `files` icon, click on “Network”, then right-click the yellow bar on top, and “Turn on network discovery and file sharing”, then click “Yes, turn on network discovery and file sharing for all public networks”.

![](../.gitbook/assets/lab-5-assets/14.png)

Rename your computer, similar to in [5.1.1](lab-5-active-directory.md#5.1.1-setting-up-windows-server-2019-vm). We've chosen "WS-01" for this demonstration.

![](../.gitbook/assets/lab-5-assets/13.png)

Restart your machine. Your user workstation is now set up. You can repeat this process to create as many workstations as you wish.

## 5.2 Setting up the Domain Controller

Open up your domain controller - Windows Server 2019 VM. The Server Manager will auto-launch at the start-up.

{% hint style="warning" %}
M1/M2 users: the VM runs extremely slow, you just have to be a bit more patient.
{% endhint %}

We are now going to install Domain Services. In the Server Manager, click on “Manage”, then “Add Roles and Features”.

![](../.gitbook/assets/lab-5-assets/9.png)

Keep clicking "Next" until you reach "Server Roles". Check the box next to "Active Directory Domain Services”, add services, click "Next" until the Results section then click “Install”.

![](../.gitbook/assets/lab-5-assets/1.gif)

Next, click the flag icon, then "Promote this server to a domain controller". Click “Add a new forest” then name your domain whatever you'd like. We've chosen "dc.local" as the root domain name for this demonstration.

![](../.gitbook/assets/lab-5-assets/10.png)

Set a domain controller password, then keep clicking "Next", then click "Install". The machine should reboot on its own after that.

![](../.gitbook/assets/lab-5-assets/11.png)

## 5.3 Configuring the Domain Controller

In the Server Manager dashboard, click “Tools” then “Active Directory Users and Computers”:

![](../.gitbook/assets/lab-5-assets/15.png)

Let's create a basic user. Click the arrow next to dc.local”, click on “Users”, then right click in the white space in the Users menu, hover over “New”, then select “User”.

![](../.gitbook/assets/lab-5-assets/16.png)

Give your new user a name. Here we're going with "test user1"

![](../.gitbook/assets/lab-5-assets/17.png)

Then enter in a password. Uncheck “User must change password at next logon” and check “Password never expires”. This is very bad policy if you were setting up a real Active Directory, however this makes things simpler for our testing purposes. Then click “Next” and “Finish”.

![](../.gitbook/assets/lab-5-assets/18.png)

Now let's create a domain admin to help us out on our network. Right click the “Administrator” user then click “Copy”. Repeat the above steps for name/password. Here we're going with "testadmin". The password we'll use here is "password1!".

![](../.gitbook/assets/lab-5-assets/19.png)

![](../.gitbook/assets/lab-5-assets/20.png)

Let's create a few more users. Copy our "test user1" user and repeat the previous steps for test users 2 and 3.

Next let's create a SQL database account just for testing purposes (we won’t actually be setting up a SQL database in this walk-through). Copy the "testadmin" account so all the permissions of an Administrator account are carried over to the SQL account. Service accounts should not be domain administrators, this has the potential for exploitation.

![](../.gitbook/assets/lab-5-assets/21.png)

Some administrators put passwords in account descriptions, thinking no one else can see them. To see how this can be a vulnerability, put the password in the description of the SQLDatabase account by right-clicking it, and selecting “Properties”:

![](../.gitbook/assets/lab-5-assets/22.png)

Then type in the password, then click “Apply”, then “OK”. Safe as can be right?

![](../.gitbook/assets/lab-5-assets/23.png)

Many Active Directory’s utilize file shares. Let's set up a file share to see how that common feature can be a vulnerability. Close out of the “Users and Computers” window, then click on “File and Storage Services”.

![](../.gitbook/assets/lab-5-assets/24.png)

Then click “Shares”, “Tasks”, then “New Share…”.

![](../.gitbook/assets/lab-5-assets/25.png)

Click "Next" until you reach "Share Name", leaving the defaults. Give a name (we'll go with "testshare" here), and click "Next" until you can click "Create".

![](../.gitbook/assets/lab-5-assets/26.png)

Next we'll set up our machine to test out Kerberoasting, a popular attack to passively grab Active Directory credentials. Open Command Prompt by pressing your Windows Key, typing “cmd”, then pressing Enter. Then enter the command based on your set up component names:

> setspn -a DC\_01/SQLDatabase.dc.local:1337 dc\SQLDatabase

This command sets up a service principle name using your Domain Controllers name (DC\_01), a random port(1337), the name of your SQLDatabase user (SQLDatabase) and your Root Domain Name (dc.local). You will need to adjust these parameters for the names that you've set up.

Confirm everything was done correctly with the command:

> setspn -T dc.local -Q \*/\*

If you see "Existing SPN found!" at the bottom, then you were successful in setting everthing up.

![](../.gitbook/assets/lab-5-assets/27.png)

Next let's disable Windows Defender so we can focus on the learning basics of attacking Active Directory, not Anti-virus evasion. Close out of command prompt and search for “Group Policy Management” in the task bar and open that up. Expand the "Domains" submenu, then right-click your root domain name, click “Create a GPO in this Domain, and Link it here…”.

![](../.gitbook/assets/lab-5-assets/28.png)

Enter something like "Disable Windows Defender" as your policy name. Find the policy you just made within your domain controller, right click the policy and click "Edit". Expand the following arrows, and under "Windows Components" scroll down until you find "Windows Defender Antivirus".

![](../.gitbook/assets/lab-5-assets/29.png)

Double click “Turn off Windows Defender Antivirus".

![](../.gitbook/assets/lab-5-assets/30.png)

Click “Enabled”, “Apply”, “OK”.

![](../.gitbook/assets/lab-5-assets/31.png)

## 5.4 Connecting Users to the Domain

We will start with the Windows 10 workstation we created in [5.1.2](lab-5-active-directory.md#5.1.2-setting-up-windows-10-enterprise-wm). Open up this VM and login. Go to the C Drive and create a new folder (we'll call it "Shares" here). This folder will be act as our share drive in our AD system, perform the following actions to set it up:

* Right click → "Properties" → "Sharing" → "Share"
* Select your user and click "Share"
* Under "Password Protection", click on "Network and Sharing Center" and make sure "Turn on network discovery" is checked.

Now we need the IP Address of your domain controller to join this workstation to the domain. Go back to your Windows Server 2019 - domain controller machine and open up the command prompt again. Type in ipconfig and record the IPv4 Address. In our case, the address of the domain controller is at 192.168.86.131.

![](../.gitbook/assets/lab-5-assets/32.png)

Back on the Windows 10 Enterprise machine, right click on the networking icon in the lower right of the taskbar and click “Open Network & Internet Settings”.

![](../.gitbook/assets/lab-5-assets/33.png)

Click “Change adapter options”. Right click on “Ethernet” and select “Properties”. Double click “Internet Protocol Version 4 (TCP/IPv4).

![](../.gitbook/assets/lab-5-assets/34.png)

Then set your “Preferred DNS server:” as the IP of the domain controller, then check off “Validate settings upon exit” so we know it works, then click “OK” on the last 2 windows.

![](../.gitbook/assets/lab-5-assets/35.png)

A window for "Windows Network Diagnostics" will open and try to detect any problems. If none are found, then we're good to go.

In the task bar search for “Access work or school”. Click "Connect", then click “Join this device to local Active Directory domain”.

![](../.gitbook/assets/lab-5-assets/36.png)

Type in your Root domain name and click “Next”. Type in your Administrator credentials, then click “OK”.

![](../.gitbook/assets/lab-5-assets/37.png)

Skip the "Add an account" step, then restart the machine.

Now we'll try to log into one of the users we configured on our domain controller, like "testuser1" for example.

![](../.gitbook/assets/lab-5-assets/38.png)

Repeat these steps in [Connecting Users to Domain](lab-5-active-directory.md#5.4-connecting-users-to-the-domain) with any other Windows 10 Enterprise workstations you want to hook up to your Active Directory.

## 5.5 Attacking the AD via Kali Linux

We’re almost ready to attack our Active Directory. You will need to also set up a Kali Linux VM on VMware if you haven't done so already.

### 5.5.1 Exploiting a Windows Machine with Responder

We’re going to exploit our Active Directory by capturing NTLMv2 Hashes with Responder from Impacket. NTLMv2 hashes are basically the scrambled version of Windows passwords. We’ll get to unscrambling them soon enough.

On your Kali machine. Open a terminal by right clicking the desktop and selecting “Open Terminal Here”. Run:

> sudo apt update
>
> sudo apt install python-pip -y

We’ll use pip to install the network exploitation toolkit `Impacket`. Download it to your Kali system:

> git clone https://github.com/SecureAuthCorp/impacket
>
> cd impacket/
>
> sudo pip install . --no-cache-dir
>
> sudo python3 setup.py install
>
> sudo pip3 install .

Begin running responder on your Kali machine with the following command:

> sudo responder -I eth0 -dwv

`-I` to listen on your eth0 network interface, `-d` to enable answers for netbois domain, `-w` to start WPAD rouge proxy server, `-v` for verbose output. These are the most common settings.

![](../.gitbook/assets/lab-5-assets/39.png)

Now Responder is listening on the network, poisoning services like LLMNR and NBT-NS as you can see in the output. Listen long enough and testadmin will innocuously try to access one of the shared files on the network. You can also prompt this by logging into "testadmin" and in "File Explorer", try to access "\\\sharedfolder".

![](../.gitbook/assets/lab-5-assets/40.png)

### 5.5.2 Cracking the Hash

To turn this hash into a password, we can attempt hash cracking. The most popular tool to crack hashes of any kind is `hashcat`. You’ll find this preinstalled on your Kali machine.

First, save the hash output to a text file.

![](../.gitbook/assets/lab-5-assets/42.png)

Now to crack this hash, we’re going to use a word list to compare the hashes too. If we get a match then we’ve found the password. A popular word list is already pre installed on every Kali machine. Unzip it with the command:

> sudo gunzip /usr/share/wordlist/rock.txt.gz

Then run `hashcat` with both your saved hash and the word list

> hashcat -m 5600 hashes.txt /usr/share/wordlists/rockyou.txt --force

`-m 5600` is the number that designates NTMLv2 hashes and `--force` ignores any errors we get from running hashcat in a VM. Since we chose a very weak password for this user, password cracking took all but 1 second.

![](../.gitbook/assets/lab-5-assets/43.png)

### 5.5.3 psexec

`psexec` is a Microsoft developed lightweight remote access program. Every Kali Linux is preinstalled with it. We can use it to remotely access testadmin’s computer with our new found credentials. You need to enter the Root domain name (dc.local), the username (testadmin), the password ('password1!'), then the IP address of testadmin machine (192.168.86.132). The password needs to be in quotes otherwise the exclamation marks will be interpreted by Bash as regular expressions.

Note: if the `psexec` returns an error, make sure the Windows Defender Antivirus is disabled on the target machine.

![](../.gitbook/assets/lab-5-assets/44.png)

That’s how you own testadmin's computer. Since testadmin is an admin user we can see we also have an admin shell with the whoami command. Thus, we have managed to access a remote shell via exploiting the AD.

### 5.5.4 Target enumeration with Nmap, Nbtscan, CME

First enumerate what hosts are on the network, their IP addresses, how many are there and what services they are running.

**Nmap**

Quickly find hosts on the subnet with a ping scan. The subnet of this network in this example is at 192.168.86.134/24:

> nmap -sn 192.168.86.0/24

![](../.gitbook/assets/lab-5-assets/45.png)

Enumerate common AD and Windows ports via:

> sudo nmap -T4 -n -Pn -sV -p22,53,80,88,445,5985 192.168.86.0/24

![](../.gitbook/assets/lab-5-assets/47.png)

Filtered ports we can assume are closed. Hosts with port 88 running Kerberos and port 53 running DNS open, we can strongly assume is the Domain Controller (DC) or a Windows Server. Now we know the Domain Controller is on 192.168.86.134. For the Domain name of the machine, enumerate the DC using LDAP and we’ll find the root domain name is dc.local, via:

> sudo nmap -T4 -Pn -p 389 --script ldap\* 192.168.86.134

![](../.gitbook/assets/lab-5-assets/48.png)

**nbtscan**

Enumerate NetBOIS names of hosts:

> nbtscan 192.168.86.0/24

![](../.gitbook/assets/lab-5-assets/49.png)

**CrackMapExec**

CrackMapExec more neatly finds host IP’s, NetBIOS names, domain names, Windows versions, SMB Sigining all in one small command:

> crackmapexec smb 192.168.86.0/24

![](../.gitbook/assets/lab-5-assets/50.png)

### 5.5.5 Username enumeration with Nmap and Kerbrute

Now we know what computers are on the network, we need to find out what user accounts can authenticate to them. Once we have usernames, we can find passwords, then get our precious foothold into the system.

[Kerberos](https://docs.microsoft.com/en-us/windows-server/security/kerberos/kerberos-authentication-overview) makes it easy to enumerate valid usernames for the domain. We can send Kerberos requests to the DC checking different usernames. Tools like Nmap and [Kerbrute](https://github.com/ropnop/kerbrute/releases) makes this process easy. All you need is a username list. You can use one from [SecLists](https://github.com/danielmiessler/SecLists/blob/master/Usernames/Names/names.txt) or craft one based off [naming conventions and what you know about the target](https://activedirectorypro.com/active-directory-user-naming-convention/).

**Kerbrute**

Download [Kerbrute](https://github.com/ropnop/kerbrute/releases) from the Git repository. Download the [SecLists](https://github.com/danielmiessler/SecLists/blob/master/Usernames/Names/names.txt) usernames list. You can combine this with other lists to build a larger store of usernames.

![](../.gitbook/assets/lab-5-assets/51.png)

### 5.6 Conclusion

CONCLUSION HERE
