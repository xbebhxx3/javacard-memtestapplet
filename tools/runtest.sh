#!/bin/bash

# ==========================================
# 颜色定义 (ANSI Color Codes)
# ==========================================
G='\033[0;32m' # Green
R='\033[0;31m' # Red
Y='\033[1;33m' # Yellow
B='\033[0;34m' # Blue
C='\033[0;36m' # Cyan
N='\033[0m'    # No Color

# ==========================================
# 参数配置
# ==========================================
GP_JAR="tools/gp.jar"
CAP_FILE="bin/MemoryProbe.cap"

ENC="bd4dc7cad88ae968fe5bc814d88d10a0"
MAC="a060b868d75e7afcacd4d9186d8509cc"
DEK="562825306ede1b80b757a1e5ece54005"

PKG_AID="F06D656D74657374"
APP_AID="F06D656D7465737401"

GP_BASE="java -jar $GP_JAR --key-enc $ENC --key-mac $MAC --key-dek $DEK"

# ==========================================
# 1. 计算 CAP 文件静态误差
# ==========================================
if [ ! -f "$CAP_FILE" ]; then
    echo -e "${R}[!] Error:${N} 找不到目标文件: $CAP_FILE"
    exit 1
fi

CAP_SIZE_BYTES=$(stat -c%s "$CAP_FILE")
CAP_SIZE_KB=$(echo "scale=2; $CAP_SIZE_BYTES / 1024" | bc)

echo -e "${C}------------------------------------------------${N}"
echo -e "${B}[*]${N} 探测 App 静态分析:"
echo -e "    CAP 文件大小: $CAP_SIZE_BYTES Bytes (约 $CAP_SIZE_KB KB)"
echo -e "${C}------------------------------------------------${N}"

# ==========================================
# 2. 安装与执行探测
# ==========================================
echo -e "${G}[+]${N} [1/3] 正在执行环境预清理与重新安装..."
$GP_BASE --delete $PKG_AID -f >/dev/null 2>&1
INSTALL_OUT=$($GP_BASE --install $CAP_FILE --app $APP_AID 2>&1)

if [[ $? -ne 0 ]]; then
    echo -e "${R}[!] Installation Failed:${N}\n$INSTALL_OUT"
    exit 1
fi

echo -e "${G}[+]${N} [2/3] 正在发送 APDU 指令探测内存核心数据..."
# 逻辑优化：抓取返回的 16 进制流
RAW_DATA=$($GP_BASE -a 00A4040009$APP_AID -a 00100000 2>/dev/null | grep -v "\[" | grep -v "A>" | grep -v "A<" | tr -d '\r\n ' | tail -c 16)

if [ ${#RAW_DATA} -lt 12 ]; then
    echo -e "${R}[!] Communication Error:${N} 接收数据格式异常 ($RAW_DATA)"
    exit 1
fi

# 解析返回数据 (Hex Offset Calculation)
DATA=${RAW_DATA:0:12}
FLASH_STD_HEX=${DATA:0:4}
RAM_HEX=${DATA:4:4}
REAL_KB_HEX=${DATA:8:4}

FLASH_STD=$((16#$FLASH_STD_HEX))
RAM=$((16#$RAM_HEX))
REAL_KB=$((16#$REAL_KB_HEX))

# ==========================================
# 3. 结果显示与误差补偿
# ==========================================
# 补偿计算
OFFSET_KB=$(echo "$CAP_SIZE_KB + 1.0" | bc)
TRUE_TOTAL=$(echo "$REAL_KB + $OFFSET_KB" | bc)

echo -e "\n${C}------------------------------------------------${N}"
echo -e "${Y}[*] 最终内存分析报告 (已完成误差补偿机制)${N}"
echo -e "${C}------------------------------------------------${N}"
printf "  %-25s : %s KB\n" "当前剩余 Flash" "$REAL_KB"
printf "  %-25s : ~%s KB\n" "探测器自身开销" "$OFFSET_KB"
printf "  %-25s : ~%s KB\n" "卡片推算总空间" "$TRUE_TOTAL"
printf "  %-25s : %s Bytes\n" "当前剩余可用 RAM" "$RAM"
echo -e "${C}------------------------------------------------${N}"

# ==========================================
# 4. 交互式卸载
# ==========================================
echo -e "${G}[+]${N} [3/3] 正在执行清理程序..."
$GP_BASE --delete $APP_AID >/dev/null 2>&1
$GP_BASE --delete $PKG_AID >/dev/null 2>&1
echo -e "${G}[+]${N} 卸载完成，存储空间已释放。"