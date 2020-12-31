## 编译自定义rom的简单教程
### 硬件需求      
一台安装了Linux的电脑 (~~废话~~  
大于8G的Ram(虽然a10开始就推荐16g ram了但是实际上多加点zram还是能跑过的  
可用大于300G的硬盘  
处理器性能越强劲越好  
良好的网络环境（~~不用说，各位都懂~~  
~~一个能正常运作的大脑~~  

至于你要在哪个发行版上编译...这个自己选择,我目前用的archlinux，ubuntu,debian,linux mint我也试过，其他发行版能不能用我就不知道了，不缺软件包一般就没啥大问题
> ### 配置环境

通过这个项目来快速配置你的编译环境  
```
git clone https://github.com/akhilnarang/scripts.git
cd scripts/setup
. ./arch-manjaro.sh
```
如果你是debian系请将`. ./arch-manjaro.sh`替换为`. ./ android_build_env.sh`  
然后按照终端输出的内容完成配置即可
> ### 拉取源代码

在Github检索你所想要构建的rom
此处以ArrowOS为例
```
mkdir arrowos
cd los
repo init -u https://github.com/ArrowOS/android_manifest.git -b arrow-11.0
repo sync
```  
完成后你将得到接近100G的源代码
如果你想要节省磁盘空间可以在`repo init`时带上`--depth=1`表示不同步历史提交
> ### 获取设备的专有代码

你需要获取的有device tree, kernel, vendor, 有些设备可能还需要device tree common和firmware，详细的情况请询问你的设备维护者，每个设备都是不一样的
> ### 设备树的修改

如果你的设备树适用于构建的rom和你将要构建的rom不一致的话，参考这个commit来编辑它 [Link](https://github.com/TronFlyn/device_xiaomi_sagit/commit/23d6b37a0e43b48d297a995ab32dd539e7f60749)
> ### Ram容量为8G的机器需要做的  

实际上16g  ram的设备也需要((  
取消swap  
`sudo nano /etc/fstab`  
然后将所有的swap分区使用#来注释掉  
archlinux需要这么配置
```
pacman -S systemd-swap
sudo systemctl enable --now systemd-swap
```
然后编辑文件`/etc/systemd/swap.conf`来启用zram  
debian系的这么配置zram  
`sudo apt install zram-config`   
之所以不推荐使用swap而是使用zram是因为zram性能远比swap好
> ### 配置ccache

ccache可以大幅度提升你后续构建rom的速度  
`sudo apt install ccache`  
之后在你的~/.bashrc中添加
```bash
export USE_CCACHE=1
export CCACHE_EXEC=$(command -v ccache)
```  
让你的设置生效  
`source ~/.bashrc`  
设定ccache所能使用的空间  
`ccache -M 50G`  
> ### 开始构建  

首先进入rom的源码目录，初始化你的构建环境  
`. build/envsetup.sh`  
鉴于有些rom可能会修改构建的指令，请以rom的描述文件提供的方法为准
#### 方法1 
 使用`brunch sirius`这样的指令进行构建  
请自行将sirius替换成你要构建的设备代号
#### 方法2
键入`breakfast` 
然后选择你想要构建的rom的类型  
之后通过`mka bacon`即可开始构建
> ### Error的修复
#### 错误
```
"bison" is not allowed to be used. See https://android.googlesource.com/platform/build/+/master/Changes.md#PATH_Tools 
for more information.
```
#### 修复  

`export TEMPORARY_DISABLE_PATH_RESTRICTIONS=true`  
安卓10开始将限制主机的构建工具的使用  
这条可以加到`~/.bashrc`里  

---
#### 错误  
```
构建metalava时出现error  
```
#### 修复  
  `mka api-stubs-docs && mka hiddenapi-lists-docs && mka system-api-stubs-docs && mka test-api-stubs-docs`  
你的ram不够吃了，单独构建它们就好了，然后继续构建rom    

---
> ### 其他  

更新源码只需要在原来的源代码目录下重新`repo sync`即可
