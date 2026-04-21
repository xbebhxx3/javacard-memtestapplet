package com.tester;

import javacard.framework.*;

public class memtest extends Applet {
    // 探测步长：1KB (1024字节)
    private static final short STEP_SIZE = 1024;
    // 自定义探测指令 INS
    private static final byte INS_PROBE = (byte) 0x10;

    public static void install(byte[] bArray, short bOffset, byte bLen) {
        new memtest().register();
    }

    public void process(APDU apdu) {
        // 如果是选择指令，直接秒回 9000，确保连接稳定
        if (selectingApplet()) {
            return;
        }

        byte[] buffer = apdu.getBuffer();
        byte ins = buffer[ISO7816.OFFSET_INS];

        // 只有当你发送 00 10 ... 时才执行探测
        if (ins == INS_PROBE) {
            // 1. 获取标准 API 内存 (受 0x7FFF 限制)
            short flashShort = JCSystem.getAvailableMemory(JCSystem.MEMORY_TYPE_PERSISTENT);
            short ramReset = JCSystem.getAvailableMemory(JCSystem.MEMORY_TYPE_TRANSIENT_RESET);

            // 2. 探测真实 Flash 剩余 (以 KB 为单位)
            // 这步依然很慢，执行时请确保读卡器超时设置足够长 (如 > 5s)
            short realFlashKB = probePersistentMemoryKB();

            // 组装返回数据 (6 字节)
            Util.setShort(buffer, (short) 0, flashShort);  // [0-1] 标准 Flash
            Util.setShort(buffer, (short) 2, ramReset);    // [2-3] RAM
            Util.setShort(buffer, (short) 4, realFlashKB); // [4-5] 真实 Flash (KB)

            apdu.setOutgoingAndSend((short) 0, (short) 6);
        } else {
            // 不支持的指令抛出异常
            ISOException.throwIt(ISO7816.SW_INS_NOT_SUPPORTED);
        }
    }

    private short probePersistentMemoryKB() {
        short count = 0;
        // 注意：在某些卡片上，频繁 new 对象可能导致内存碎片
        // 探测完成后建议删除 Applet 以完全回收
        Object[] hold = new Object[256]; 
        try {
            while (count < (short) 256) {
                hold[count] = new byte[STEP_SIZE];
                count++;
            }
        } catch (SystemException e) {
            // SystemException.NO_RESOURCE 内存分配到极限
        }
        
        // 必须显式释放，否则内存将无法被回收
        for (short i = 0; i < count; i++) {
            hold[i] = null;
        }
        
        // 提示卡片执行垃圾回收
        JCSystem.requestObjectDeletion();
        
        return count;
    }
}