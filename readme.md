# javacard-memtestapplet

`javacard-memtestapplet` 是一个用于探测 JavaCard 智能卡内存（RAM/Flash）可用空间的工具。该项目通过计算探测器自身占用与实际反馈数据的偏差，提供高精度的卡片剩余空间报告。

本项目的核心逻辑由 **80% AI** 与 **20% 人类** 成分构成，（第一次接触jcop，写的像shit）。

提供编译好的cap，可以跳过编译,仅需要gp和runtest.sh

---

## 环境依赖
1. [ant-javacard](https://github.com/martinpaljak/ant-javacard)
build自动下载
2. [jc305u4_kit](https://github.com/martinpaljak/oracle_javacard_sdks/tree/master/jc305u4_kit)
放置到`sdks`
3. [GlobalPlatformPro](https://github.com/martinpaljak/GlobalPlatformPro/releases/download/v25.10.20/gp.jar)
放置到`tools`

### 1. linux编译
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