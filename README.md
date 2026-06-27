# 计组实验&课设 —— 基于 FPGA 的 CPU 逐级设计

> 计算机组成原理课程实验
> 
> 平台：Quartus II 13.1 + Cyclone V (5CSEMA5F31C6) / DE1-SoC 开发板
> 
> 语言：VHDL + 原理图 (BDF)
> 
---

## 项目简介

本仓库包含计算机组成原理课程的五个实验，按照 **从简单逻辑门到完整 CPU** 的路线逐级递进，最终在实验五完成一个支持 18 条指令的 16 位单周期 CPU 设计。

| 实验 | 主题 | 核心内容 | 顶层方式 |
|------|------|----------|----------|
| LAB0001 | 基础逻辑门 | 2 输入或门，熟悉 Quartus 开发流程 | VHDL + BDF |
| LAB0002 | 8 位 ALU | 16 种运算的算术逻辑单元 | BDF 原理图 |
| LAB0003 | ALU + 存储器 | ROM/RAM 与 ALU 的数据通路 | BDF 原理图 |
| LAB0004 | 8 位完整 CPU | 累加器架构，8 条指令 | BDF 原理图 |
| LAB0005 | 16 位单周期 CPU | 寄存器堆架构，18 条指令（课程设计） | VHDL 代码 |

---

## 实验一：基础逻辑门（LAB0001）
<img width="629" height="128" alt="a428609f38eb7c4c7798ae021b03853c" src="https://github.com/user-attachments/assets/3ac38ee0-81cc-49fe-8ad1-fd7f1bde8aca" />

### 目的

熟悉 Quartus II 开发环境，掌握 VHDL 基本语法和原理图设计方法。

### 设计内容

实现一个 2 输入或门，用两种方式描述：

- **VHDL 代码**（`or2in.vhd`）：`led0 <= sw1 OR sw0`
- **原理图**（`or2in.bdf`）：图形化连接

### 模块说明

| 文件 | 功能 |
|------|------|
| `or2in.vhd` | 或门 VHDL 描述，输入 sw0/sw1，输出 led0 |
| `or2in.bdf` | 或门原理图，与 VHDL 功能等价 |

### 引脚

| 信号 | 方向 | 对应引脚 |
|------|------|----------|
| sw0 | input | 开关 SW0 |
| sw1 | input | 开关 SW1 |
| led0 | output | LEDR0 |

---

## 实验二：8 位 ALU（LAB0002）
<img width="835" height="319" alt="bdb609a8d5a3c9708873b1fd68f65737" src="https://github.com/user-attachments/assets/0ecc231e-bdc0-460f-9a22-b6ec13acefb0" />

### 目的

掌握运算器（ALU）的设计方法，理解算术运算与逻辑运算的控制方式。

### 设计内容

实现一个 8 位 ALU，支持 16 种运算，通过 4 位操作码 S[3:0] 选择运算类型，M 信号区分算术运算（M=0）和逻辑运算（M=1）。配套设计了累加器寄存器和七段数码管译码器，通过原理图连接成完整的数据通路。

### 模块说明

| 文件 | 功能 |
|------|------|
| `ALU_8b.vhd` | 8 位 ALU，16 种运算，M 信号区分算术/逻辑，CN 进位输入，CO 进位输出 |
| `AC_A.vhd` | 8 位累加器 A，时钟上升沿锁存 ALU 运算结果 |
| `AC_B.vhd` | 8 位累加器 B，锁存第二操作数 |
| `AC_S.vhd` | 4 位 ALU 操作码寄存器，锁存 S[3:0] |
| `seg7_16b.vhd` | 七段数码管译码器，8 位输入拆为高低半字节分别显示 |
| `ALU.bdf` | 顶层原理图，连接 ALU、累加器、数码管 |

### ALU 运算表

| S[3:0] | M=0（算术） | M=1（逻辑） |
|--------|-------------|-------------|
| 0000 | A + CN | NOT A |
| 0001 | (A OR B) + CN | NOT(A OR B) |
| 0010 | (A OR NOT B) + CN | (NOT A) AND B |
| 0011 | 0 - CN | 0 |
| 0100 | A + (A AND NOT B) + CN | NOT(A AND B) |
| 0101 | (A OR B) + (A AND NOT B) + CN | NOT B |
| 0110 | A - B - CN | A XOR B |
| 0111 | (A OR NOT B) - CN | A AND NOT B |
| 1000 | A + (A AND B) + CN | (NOT A) AND B |
| 1001 | A + B + CN | NOT(A XOR B) |
| 1010 | (A OR NOT B) + (A AND B) + CN | B |
| 1011 | (A AND B) - CN | A AND B |
| 1100 | A + A + CN | 1 |
| 1101 | (A OR B) + A + CN | A OR NOT B |
| 1110 | (A OR NOT B) + A + CN | A OR B |
| 1111 | A - CN | A |

---

## 实验三：ALU + 存储器（LAB0003）
<img width="813" height="334" alt="7a773c7e336557c87cb8aff333307d92" src="https://github.com/user-attachments/assets/2bd1ae91-c8f4-4086-b2ee-6072f6544b65" />

### 目的

掌握存储器（ROM/RAM）的设计方法，理解 ALU 与存储器之间的数据通路。

### 设计内容

在实验二 ALU 的基础上，加入 ROM（指令/数据存储器）和 RAM（数据存储器），通过计数器产生地址，实现从存储器读取数据、送入 ALU 运算、结果写回存储器的完整数据通路。

### 模块说明

| 文件 | 功能 |
|------|------|
| `ALU_8b.vhd` | 8 位 ALU（复用实验二） |
| `ROM.vhd` | 256×32 位 ROM，基于 altsyncram，MIF 文件初始化 |
| `RAM1.vhd` | 256×8 位单端口 RAM，基于 altsyncram |
| `lpm_counter0.vhd` | LPM 计数器，产生存储器地址 |
| `lpm_latch_0.vhd` | LPM 锁存器 |
| `lpm_latch_1.vhd` | LPM 锁存器 |
| `seg7_16b.vhd` | 七段数码管译码器（复用实验二） |
| `ROM-RAM.mif` | ROM 初始化文件 |
| `ALU_RAM.bdf` | 顶层原理图，连接 ALU、ROM、RAM、计数器、数码管 |

---

## 实验四：8 位完整 CPU（LAB0004）
<img width="1042" height="426" alt="image" src="https://github.com/user-attachments/assets/9b95a644-bf96-4934-bb78-6d5ccb354801" />

### 目的

将前三个实验的 ALU、寄存器、存储器、译码器整合为一个完整的 CPU，实现程序存储和自动执行。

### 设计内容

采用 **累加器架构**（Accumulator-based），设计一个支持 8 条指令的 8 位 CPU。指令格式为 32 位（高 4 位操作码 + 低 8 位地址），通过指令译码器生成控制信号，驱动 ALU、累加器、PC、存储器协同工作，实现取指-译码-执行-写回的完整指令周期。

### 指令集

| 操作码 | 指令 | 功能 |
|--------|------|------|
| 0000 | NOP | 空操作，PC+1 |
| 0001 | JMP addr | 无条件跳转到 addr |
| 0010 | SUB addr | AC ← AC - RAM[addr] |
| 0011 | LAD addr | AC ← RAM[addr] |
| 0100 | AND addr | AC ← AC AND RAM[addr] |
| 0101 | OR addr | AC ← AC OR RAM[addr] |
| 0110 | ADD addr | AC ← AC + RAM[addr] |
| 0111 | STD addr | RAM[addr] ← AC |

### 模块说明

| 文件 | 功能 |
|------|------|
| `PC.vhd` | 8 位程序计数器，支持自增（INCR_PC）和跳转（LOAD_PC） |
| `ALU_8b.vhd` | 8 位 ALU（复用实验二） |
| `AC.vhd` | 8 位累加器，锁存 ALU 运算结果 |
| `IR.vhd` | 指令寄存器，暂存指令并拆分操作码和地址 |
| `decoder.vhd` | 指令译码器，操作码 → 9 个控制信号 |
| `controller.vhd` | 控制器 VHDL 代码（与 BDF 功能等价） |
| `controller.bdf` | 顶层原理图，连接所有模块 |
| `ROM.vhd` | 256×32 位 ROM（指令存储器） |
| `RAM1.vhd` | 256×8 位 RAM（数据存储器） |
| `seg7_16b.vhd` | 七段数码管译码器，显示 PC/AC/ALU 结果 |
| `lpm_mux0.vhd` | 2 选 1 多路选择器，选择 RAM 数据或立即数送 ALU |
| `lpm_counter0.vhd` | LPM 计数器 |
| `ROM-RAM.mif` | ROM 初始化文件（测试程序） |
| `RAM.mif` | RAM 初始化文件（测试数据） |

### 数据通路

```
PC → ROM(指令) → IR → decoder → 控制信号
                              ↓
PC → ROM(地址) → RAM → mux → ALU B端
                                ↓
AC → ALU A端           ALU → AC (写回)
                                ↓
                          seg7 (显示)
```

---

## 实验五：16 位单周期 CPU（LAB0005 · 课程设计）
<img width="796" height="535" alt="d3fee7d06030d9077c091de4582eac99" src="https://github.com/user-attachments/assets/2469f697-6407-4301-94f4-f07fb8354ee5" />


### 目的

设计并实现一个 16 位单周期 CPU，支持不少于 15 条指令（优秀线），最终实现 18 条指令。

### 设计内容

采用 **寄存器堆架构**（Register File-based），设计 16 位数据宽度的单周期 CPU。指令格式为 16 位统一编码，包含 R 型、I 型、J 型和特殊指令四大类。控制器采用硬布线方式，用组合逻辑直接将 opcode 和 func 映射到 15 个控制信号。每个时钟周期完成一条指令的取指、译码、执行、访存、写回全部操作。

### 指令格式

```
R型: [15:12]opcode=0000 | [11:10]rs | [9:8]rt | [7:6]rd | [5:3]func | [2:0]保留
I型: [15:12]opcode      | [11:10]rs | [9:8]rt | [7:0]imm(8位立即数)
J型: [15:12]opcode=1011 | [11:0]target(12位目标地址)
特殊:[15:12]opcode       | 其余位保留
```

### 指令集（18 条）

| 类型 | 操作码 | func | 指令 | 功能 |
|------|--------|------|------|------|
| R | 0000 | 000 | or | rd ← rs \| rt |
| R | 0000 | 001 | and | rd ← rs & rt |
| R | 0000 | 010 | add | rd ← rs + rt |
| R | 0000 | 011 | sub | rd ← rs - rt |
| R | 0000 | 100 | sllv | rd ← rs << rt |
| R | 0000 | 101 | srlv | rd ← rs >> rt（逻辑） |
| R | 0000 | 110 | srav | rd ← rs >>> rt（算术） |
| R | 0000 | 111 | slt | rd ← (rs < rt) ? 1 : 0 |
| I | 0001 | - | DISP | 显示 PC/busA/ALU 结果 |
| I | 0010 | - | lui | rt ← imm8 << 8 |
| I | 0011 | - | ori | rt ← rs \| zero_ext(imm8) |
| I | 0101 | - | addi | rt ← rs + sign_ext(imm8) |
| I | 0110 | - | lw | rt ← RAM[rs + sign_ext(imm8)] |
| I | 0111 | - | sw | RAM[rs + sign_ext(imm8)] ← rt |
| I | 1000 | - | beq | if (rs == rt) PC ← PC+1+offset |
| I | 1001 | - | bne | if (rs != rt) PC ← PC+1+offset |
| J | 1011 | - | jump | PC ← {PC+1[15:12], target12} |
| 特殊 | 1100 | - | halt | PC 停止更新 |

### 模块说明

| 文件 | 功能 |
|------|------|
| `src/pc_reg.vhd` | 16 位 PC 寄存器，支持同步复位和 halt 停止 |
| `src/regfile.vhd` | 4×16 位寄存器堆，$0 恒零，2 位读写地址 |
| `src/alu_16b.vhd` | 16 位 ALU，S[3:0] 控制 9 种运算，输出 F/ZF/SF |
| `src/extender.vhd` | 8→16 位扩展器，Exop=0 零扩展 / Exop=1 符号扩展 |
| `src/controller.vhd` | 硬布线控制器，opcode+func → 15 个控制信号 |
| `src/rom_256x16.vhd` | 256×16 位指令 ROM，MIF 初始化 |
| `src/ram_256x16.vhd` | 256×16 位数据 RAM |
| `src/cpu_top.vhd` | 顶层模块，实例化所有模块 + 3 组数码管 |
| `src/seg7_16b.vhd` | 七段数码管译码器 |
| `src/mux2_16.vhd` | 16 位 2 选 1 MUX（辅助模块） |
| `src/mux2_2.vhd` | 2 位 2 选 1 MUX（辅助模块） |
| `src/wb_mux.vhd` | 写回数据 4 选 1 MUX |
| `src/pc_next.vhd` | PC 下址逻辑（顺序/分支/跳转） |
| `mif/rom_init.mif` | 测试程序（22 条指令） |
| `mif/ram_init.mif` | RAM 初始化数据 |

### 控制信号

| 信号 | 含义 |
|------|------|
| RegWr | 寄存器写使能 |
| RegDst | 写目标选择：0=rt，1=rd |
| ALUSrc | ALU B 端选择：0=busB，1=ext_imm |
| Exop | 立即数扩展方式：0=零扩展，1=符号扩展 |
| MemWr | RAM 写使能（sw） |
| Mem2Reg | 写回数据选择：0=ALU 结果，1=RAM 读出 |
| Branch | 分支使能 |
| BrNeg | 分支条件取反（beq=0, bne=1） |
| Jump | 跳转使能 |
| Halt | 停机信号 |
| Slt | slt 指令标志，写回 SF 而非 ALU 结果 |
| Lui | lui 指令标志，立即数放高 8 位 |
| S[3:0] | ALU 操作码 |

### 数码管显示

| 数码管 | 显示内容 |
|--------|----------|
| HEX0-HEX1 | PC 值低 8 位 |
| HEX2-HEX3 | busA（rs 寄存器值）低 8 位 |
| HEX4-HEX5 | ALU 运算结果低 8 位 |

---
### 特别说明！！！（可能会遇到的细节问题）

>全实验实际操作说明：
>
>实验1-3实际操作中没有遇到太多问题，如有报错建议查看是否成功初始化，或者qsf文件冲突，rom/ram配置，如无法解决请自行查看手册重新配置。
>
>实验4打开工程文件可能会显示lab6，使用了新的文件没有修改实际命名文件，不影响编译&仿真。
>
>实验5的bdf图只是示意，实际连接是错误的，在运行时务必remove bdf保留顶层vhd即可。另外，在上板时，实验5的引脚分配可能会出现问题，建议在pin planner按需复用前面实验的配置。
>
>其他说明：
>
>usb驱动：下载操作繁琐，请先关闭所有防火墙和可能的拦截程序，必要时需重启，注意是使用整个文件（包含I/II）进行驱动更新，本仓库不提供下载链接请自行从官网获取，如有问题pushAI。
>
>正常情况下软件层面没有问题
>
>在仿真阶段 实验5需要注意 如果一直nodata且窗口无任何信号 建议先关掉整个 ModelSim 然后这样重新来：打开文件管理器，进入 D:\altera\PCO\LAB0005（文件存储的实际位置，路径无中文）
>
>enter->cmd->vsim->在 ModelSim 底部的 Transcript 窗口里，依次输入以下每条命令（按顺序逐个回车）:
>
>vcom src/pc_reg.vhd
>
>vcom src/regfile.vhd
>
>vcom src/alu_16b.vhd
>
>vcom src/extender.vhd
>
>vcom src/controller.vhd
>
>vcom src/rom_256x16.vhd
>
>vcom src/ram_256x16.vhd
>
>vcom src/seg7_16b.vhd
>
>vcom src/cpu_top.vhd
>
>0 error 后再输入：vsim cpu_top
>
>此时Library里就会出现work和cpu_top了。点击 然后加入以下信号看波形：
<img width="545" height="541" alt="image" src="https://github.com/user-attachments/assets/8f77b316-c1ec-49a8-981c-416f4a12910a" />

>按需拖动光标到相应位置截图：
<img width="522" height="463" alt="image" src="https://github.com/user-attachments/assets/083d3498-d12f-4619-ae83-c9317c50265f" />

>硬件层面90%会出现各种问题，建议先确定.sof下载正确且成功，然后检查接线和供电，其次引脚分配，最后是按键和显示逻辑/操作问题。有时候一切顺利的话可能只是你按错了，换个人来。
>
>关于引脚分配：设计好的8位运算器的输出需要接到七段数码管来显示运算结果。8位运算器的输出需要两个数码管来显示，每一个显示4位二进制数。请根据文档“DE1-SoC_User_manual_rev.FG.pdf”为每一个数码管的7个段分配物理引脚，分配时注意高低位顺序。我在实际上板时也遇到很多硬件问题没有解决，只能说复用前面实验，实在不行换块板子。
>
>关于其他文档：MustKnow&答辩参考.doc是我基于自己理解写的粗略说明，照着念得到的tr评价是：原理理解的很透彻，但还是要多多上手。我的答辩问题是：你是如何设计并实现指令存储器的？ok没看代码细节的代价就是rom.mif忘记加入工程了 Quartus给的图形化指令界面没有代码细节 我空口也不晓得rom初始化怎么开始讲（虽然对着机器码其实也能讲的 但彼时作者不晓得一串操作码怎么翻译）......还是要多多review每个文件&代码实现细节哇。

---
## 目录结构

```
PCO/
├── LAB0001/                  # 实验一：基础逻辑门
│   ├── or2in.vhd             # 或门 VHDL
│   ├── or2in.bdf             # 或门原理图
│   ├── or2in.qsf             # 引脚/工程配置
│   └── LAB0001.qpf           # 工程文件
│
├── LAB0002/                  # 实验二：8 位 ALU
│   ├── ALU_8b.vhd            # ALU 模块
│   ├── AC_A.vhd              # 累加器 A
│   ├── AC_B.vhd              # 累加器 B
│   ├── AC_S.vhd              # 操作码寄存器
│   ├── seg7_16b.vhd          # 数码管译码
│   ├── ALU.bdf               # 顶层原理图
│   └── ALU.qpf
│
├── LAB0003/                  # 实验三：ALU + 存储器
│   ├── ALU_8b.vhd            # ALU（复用）
│   ├── ROM.vhd               # 256×32 ROM
│   ├── RAM1.vhd              # 256×8 RAM
│   ├── lpm_counter0.vhd      # 计数器
│   ├── seg7_16b.vhd          # 数码管译码（复用）
│   ├── ROM-RAM.mif           # ROM 初始化文件
│   ├── ALU_RAM.bdf           # 顶层原理图
│   └── ALU_RAM.qpf
│
├── LAB0004/                  # 实验四：8 位完整 CPU
│   ├── PC.vhd                # 程序计数器
│   ├── ALU_8b.vhd            # ALU（复用）
│   ├── AC.vhd                # 累加器
│   ├── IR.vhd                # 指令寄存器
│   ├── decoder.vhd           # 指令译码器
│   ├── controller.vhd        # 控制器
│   ├── controller.bdf        # 顶层原理图
│   ├── ROM.vhd               # 指令 ROM
│   ├── RAM1.vhd              # 数据 RAM
│   ├── seg7_16b.vhd          # 数码管译码
│   ├── lpm_mux0.vhd          # 多路选择器
│   ├── lpm_counter0.vhd      # 计数器
│   ├── ROM-RAM.mif           # ROM 初始化（测试程序）
│   ├── RAM.mif               # RAM 初始化（测试数据）
│   └── lab6.qpf
│
├── LAB0005/                  # 实验五：16 位单周期 CPU（课设）
│   ├── src/                  # 所有 VHDL 源文件
│   │   ├── pc_reg.vhd
│   │   ├── regfile.vhd
│   │   ├── alu_16b.vhd
│   │   ├── extender.vhd
│   │   ├── controller.vhd
│   │   ├── rom_256x16.vhd
│   │   ├── ram_256x16.vhd
│   │   ├── cpu_top.vhd       # 顶层模块
│   │   ├── seg7_16b.vhd
│   │   ├── mux2_16.vhd
│   │   ├── mux2_2.vhd
│   │   ├── wb_mux.vhd
│   │   └── pc_next.vhd
│   ├── mif/
│   │   ├── rom_init.mif      # 测试程序
│   │   └── ram_init.mif      # RAM 初始化
│   ├── LAB0005.qsf           # 工程配置
│   └── LAB0005.qpf           # 工程文件
│
└── README.md                 # 本文件
```

---

## 开发环境

| 项目 | 版本/型号 |
|------|-----------|
| EDA 工具 | Quartus II 64-Bit v13.1.0 Build 162 |
| 目标器件 | Cyclone V 5CSEMA5F31C6 |
| 开发板 | DE1-SoC |
| HDL 语言 | VHDL |
| 仿真工具 | ModelSim（实验五）/ Quartus 内置仿真器 |

---

## 编译与使用

### 编译步骤

1. 打开 Quartus II 13.1
2. File → Open Project，选择对应实验目录下的 `.qpf` 文件
3. Processing → Start Compilation（或 Ctrl+L）
4. 编译通过后生成 `.sof` 烧录文件

### 仿真步骤（以实验五为例）

1. 编译通过后，在工程根目录下启动 ModelSim
2. 创建工作库：`vlib work` → `vmap work work`
3. 编译源文件：依次 `vcom src/xxx.vhd` 编译所有 VHDL 文件
4. 启动仿真：`vsim cpu_top`
5. 添加波形信号：`add wave clk rst pc_cur instr busA alu_F busW RegWr`
6. 驱动时钟和复位：
   ```
   force clk 0 0, 1 10ns -repeat 20ns
   force rst 1
   run 50ns
   force rst 0
   run 2500ns
   ```
7. 观察波形，验证指令执行结果

### 烧录步骤

1. USB-Blaster 连接 DE1-SoC 开发板
2. Tools → Programmer
3. 选择 `.sof` 文件，点击 Start
4. 数码管显示 CPU 运行状态

---

## 实验演进关系

```
实验一（逻辑门）
    │  掌握 Quartus 基本操作
    ▼
实验二（ALU）
    │  掌握运算器设计
    ▼
实验三（ALU + 存储器）
    │  掌握存储器和数据通路
    ▼
实验四（8 位 CPU）
    │  整合为完整 CPU（累加器架构，8 条指令）
    ▼
实验五（16 位 CPU）
       课程设计（寄存器堆架构，18 条指令，硬布线控制器）
```

每个实验在前一个的基础上递增，最终从最简单的或门发展到支持 18 条指令的单周期 CPU。

---

## .gitignore 建议

以下文件为 Quartus 编译产生的中间文件，不应提交到仓库：

```gitignore
# Quartus 编译中间文件
db/
incremental_db/
hc_output/
*.cdb
*.hdb
*.rdb
*.qws
*.jdi
*.sof
*.pof
*.pin
*.sld
*.summary
*.rpt
*.smsg
*.jam
*.jbc
*.eqn
*.titn
*.qarlog
c5_pin_model_dump.txt
*.smart_action.txt
*.lpc.txt
greybox_tmp/
```

需要保留的文件：`.vhd`、`.bdf`、`.bsf`、`.mif`、`.qpf`、`.qsf`、`.txt`（说明文档）、`.md`。

---

## License

本项目为课程实验作业，仅供学习交流使用。
