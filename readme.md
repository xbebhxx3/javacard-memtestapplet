# javacard-memtestapplet

`javacard-memtestapplet` 是一个用于探测 JavaCard 智能卡内存（RAM/Flash）可用空间的工具。该项目通过计算探测器自身占用与实际反馈数据的偏差，提供高精度的卡片剩余空间报告。

本项目的核心逻辑由 **80% AI** 与 **20% 人类** 成分构成，（第一次接触jcop，写的像shit）。

提供编译好的cap，可以跳过编译,仅需要gp和runtest.sh

---

## 已知问题
在使用vpcd测试时，默认的timeout 500ms可能会断连，可以修改为30s使用

acr1252u没这问题

## 环境依赖
1. [ant-javacard](https://github.com/martinpaljak/ant-javacard)
build自动下载
2. [jc305u4_kit](https://github.com/martinpaljak/oracle_javacard_sdks/tree/master/jc305u4_kit)
放置到`sdks`
3. [GlobalPlatformPro](https://github.com/martinpaljak/GlobalPlatformPro/releases/download/v25.10.20/gp.jar)
放置到`tools`

### 修改密钥
`tools/runtest.sh`文件内为默认密钥，修改为你的
  
    ENC="bd4dc7cad88ae968fe5bc814d88d10a0"
    MAC="a060b868d75e7afcacd4d9186d8509cc"
    DEK="562825306ede1b80b757a1e5ece54005"

### 编译运行
```bash
# 安装必要工具
sudo apt-get install openjdk-11-jdk ant -y

# 设置 Java 环境变量
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# 克隆项目
git clone https://github.com/xbebhxx3/javacard-memtestapplet.git
cd javacard-memtestapplet

# 下载gp.jar
wget -O tools/gp.jar https://github.com/martinpaljak/GlobalPlatformPro/releases/download/v25.10.20/gp.jar

# 下载sdks（虽然只需要jc305u4_kit)
git clone https://github.com/martinpaljak/oracle_javacard_sdks.git sdks

# 编译
ant

# 运行
tools/runtest.sh
```

### 下载直接运行
```bash
sudo apt-get install openjdk-11-jdk

git clone https://github.com/xbebhxx3/javacard-memtestapplet.git
cd javacard-memtestapplet

wget -O tools/gp.jar https://github.com/martinpaljak/GlobalPlatformPro/releases/download/v25.10.20/gp.jar

# 下载releases
# 验证 PGP: 2B4D C954 E2CA 4D00 54DC 1189 6C85 5A8B 595C 1CC4
gpg --recv-keys 6C855A8B595C1CC4
gpg --verify memtest.cap.asc memtest.cap

cp ***/memtest.cap ./bin 

./tools/runtest.sh
```
