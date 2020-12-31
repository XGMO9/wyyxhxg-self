# 如何安裝archlinux
写这篇文章的主要目的是教新人如何~~入教~~安裝archlinux到自己的电脑上,因为archwiki的教程個人感觉实在是难懂😶😶  
关于如何刻盘之类的直接跳过,如果这都需要教程的话实在不建议使用arch(逃  
### 联网
arch的安装需要联网,因为很多包livecd并没有带
如果你是直接用网线连接到电脑的话直接输入`ping -c 3 www.bing.com`来确认你是否能正常访问网络  
```
root@archiso ~ # ping -c 3 www.bing.com
PING dual-a-0001.a-msedge.net (204.79.197.200) 56(84) bytes of data.
64 bytes from a-0001.a-msedge.net (204.79.197.200): icmp_seq=1 ttl=64 time=0.879 ms
64 bytes from a-0001.a-msedge.net (204.79.197.200): icmp_seq=2 ttl=64 time=0.709 ms
64 bytes from a-0001.a-msedge.net (204.79.197.200): icmp_seq=3 ttl=64 time=0.757 ms

--- dual-a-0001.a-msedge.net ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 0.709/0.781/0.879/0.078 ms
```
如果你是用的无线网卡的话😶抱歉,我没有无线网卡所以我也不知道怎么做😶  
### 同步时间
很多操作都需要保证时间的精确性,为了防止出现问题,这里同步下时间  
```
root@archiso ~ # timedatectl set-ntp true
```
### 分区
第一步当然是分区啦
首先输入`fdisk -l`來查看你电脑的磁盘分区
如果你只有一块硬盘那么输入`fdisk /dev/sda`就好了,如果有多块磁盘请自行确认你要安装到哪块磁盘  
此处抛弃落后的bios引导而使用EFI引导  
个人推荐的分区是分配500m给/boot,剩下的全部分配给/也就是根分区,我的物理内存有16g,所以就不用swap了😶😶  
下面开始操作,**假设你使用全新的磁盘进行安装!!!**  
```
root@archiso ~ #fdisk /dev/sda 

```
> 输入`g`来创建一个全新的gpt分区表,**注意,此操作会让你丢失磁盘上的全部数据!!如果不是全盘安装,不要使用这个**  
输入`n`来创建一个新分区  
`Partition number`和`First sector`保持默认回车即可  
`Last sector`输入我们所需的大小,比如`+500M`,直接回车表示使用剩下的全部  
输入`w`来写入你的变更  

分配完成后我们需要格式化分区  
注意,不要格错盘了,数据重要😶😶我之前安装gentoo就因为格错盘把windows整个给扬了😶😶  
EFI分区格式化成vfat,根分区一般格式化成ext4就好了,如果是ssd可以尝试下f2fs,据说对ssd有特殊加成?😶😶
```
root@archiso ~ #mkfs.vfat /dev/sda1
root@archiso ~ #mkfs.ext4 /dev/sda2
```
### 挂载分区  
```
root@archiso ~ #mount /dev/sda2 /mnt 
root@archiso ~ #mkdir /mnt/boot
root@archiso ~ #mount /dev/sda1 /mnt/boot
```
### 调整源的顺序
```
root@archiso ~ #nano /etc/pacman.d/mirrorlist
```
通过ctrl + k来删除行以便于让China源排在首位,个人推荐tuna源  
然后同步下数据库
```
root@archiso ~ #pacman -Syy
```
### 开始安装  
```
root@archiso ~ #pacstrap /mnt base base-devel linux linux-firmware nano
```
> 此处的linux也可以换成linux-lts或者linux-zen  
linux就是常规的linux内核  
linux-lts是长期支持版本  
linux-zen是内置了一定量的优化的版本  

个人推荐新手的话还是安装常规的linux内核,因为一些驱动是有针对不同的内核打包的,有各自对应的版本,而网上的教程一般只针对linux,这是为了避免不必要的麻烦😶😶当然在后期你熟悉之后你也可以尝试更换内核,这不是什么麻烦事  
### 生成fstab
```
root@archiso ~ #genfstab -U /mnt >> /mnt/etc/fstab
```
这个fstab能在开机的时候帮我们自动挂载各种文件系统,是很重要的一个东西😶😶  
### chroot进入arch进行详细配置
```
root@archiso ~ #arch-chroot /mnt
```
设置时区
```
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```
设置硬件时间
```
hwclock --systohc --utc
```
安装更友好的文本编辑工具
```
pacman -S nano
```
设置语言,删掉`en_US.UTF-8`和`zh_CN.UTF-8`的注释
```
nano /etc/locale.gen
```
生成locale信息
```
locale-gen
```
写入locale.conf
```
echo LANG=en_US.UTF-8 >> /etc/locale.conf
```
设置一个主力名(此处以mo9为例
```
echo mo9 > /etc/hostname
```
设置root密码,注意,你是看不到密码的,输入就对了😶
```
passwd
```
### 安装bootloader
bootloader是用来引导你的操作系统启动的东西😶
首先安装基本的包
```
pacman -S efibootmgr dosfstools grub os-prober
```
安装引导
```
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub --recheck
```
如果没有问题的话你能看到这样的提示  
```
Installing for x86_64-efi platform.
Installation finished. No error reported.
```
然后生成配置文件
```
grub-mkconfig -o /boot/grub/grub.cfg
```
### 安装桌面环境
这时候你的arch已经是能够开机的了,但是你只能得到一个黑乎乎的窗口😶😶因为你还没有安装桌面环境  
此处以kde为例  
首先安装xorg,中途询问安装什么包的话直接回车就好了,也就是全选  
```
pacman -S xorg
```
然后安装kde,这里的kde-applications是kde全家桶,建议装上以获得更好的体验(
```
pacman -S plasma sddm kde-applications
```
启用一些必要的服务
```
systemctl enable sddm
systemctl enable NetworkManager
```
如果你是n卡用户可能还需要安装显卡驱动,不然可能不开机或者花屏(发出fxxk nvidia的声音  
```
pacman -S nvidia
```
安装中文字体  
```
pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji
```
### 配置超级用户
linux下root用户能够为所欲为,当然很多操作比如安装软件包等也需要root权限
```
EDITOR=nano visudo
```
然后找到`# %wheel ALL=(ALL) ALL`去掉此处的#  
然后新建一个用户,比如新建一个用户名为wyyxhxg的用户,就是输入`useradd -m -G wheel wyyxhxg`,然后设置用户密码`passwd wyyxhxg`  

----
到这里配置就基本结束啦
退出chroot环境
```
exit
```
卸载分区
```
umount -R /mnt
```
重启
```
reboot now
```
开始享受你的archlinux吧
