# 4×4 Signed Matrix Multiplier using Modified Radix-4 Booth MAC Units

A synthesizable Verilog HDL implementation of a **4×4 signed matrix multiplier**. Each output element is computed by a dedicated MAC unit built on a **Modified Radix-4 Booth multiplier** and a **Carry-Save Adder (CSA)** accumulator. Sixteen MAC units run in parallel, one per output element.

| | |
|---|---|
| **Inputs** | Two 4×4 matrices, signed 8-bit elements (−128 to 127) |
| **Outputs** | One 4×4 matrix, signed 20-bit elements |
| **Parallelism** | 16 MAC units, one per element of $C$ |
| **Multiplier** | Modified Radix-4 Booth (4 iterations per 8-bit product) |
| **Accumulation** | 3:2 CSA, with a single carry-propagate add at the end |
| **Control** | FSM-based (6-state MAC controller, 5-state Booth controller) |
| **Tools** | Verilog HDL, Xilinx Vivado (behavioral simulation) |

Developed as a six-week internship project at the Department of Electronics and Telecommunication Engineering, COEP Technological University, Pune.

---

## Background

Matrix multiplication is built from dot products:

$$C_{ij} = \sum_{k=0}^{3} A_{ik}\, B_{kj}$$

Each dot product is a chain of multiply-accumulate operations, $Z \leftarrow Z + (A \times B)$, so the MAC unit is the central building block. Two costs dominate a MAC:

1. **Partial-product generation.** Modified Radix-4 Booth recoding halves the partial products (8-bit operand → 4 instead of 8).
2. **Repeated carry propagation.** A CSA keeps the running sum in redundant form (sum + carry), so no carry ripples on each accumulate step.

---

## Architecture

```
matrix_mult_4x4
└── 16 × mac_unit4                 (one per C[i][j])
    ├── CSA accumulator            (sum_acc, carry_acc → 1 final CPA)
    ├── FSM (6 states)
    └── radix4_top                 (Booth multiplier, reused 4× sequentially)
        ├── radix4_controller      (FSM: IDLE/INIT/EXEC/SHIFT/FINISH)
        └── radix4_datapath
            ├── PIPO               (multiplicand register)
            ├── A_register         (accumulator, arithmetic shift by 2)
            ├── Q_register         (multiplier, shift by 2)
            ├── history_reg        (Q₋₁ bit)
            ├── booth_encoder
            ├── operand_generator  (0, ±M, ±2M)
            ├── ALU                (add/subtract)
            └── counter            (iteration count)
```

### Modified Radix-4 Booth multiplier

Each iteration examines three overlapping multiplier bits $(Q_1, Q_0, Q_{-1})$ and adds one of $\{0, +M, +2M, -M, -2M\}$ to the accumulator, then arithmetic-shifts the accumulator/multiplier pair right by two bits.

| $Q_1Q_0Q_{-1}$ | Operation |
|:---:|:---:|
| 000 | 0 |
| 001 | +M |
| 010 | +M |
| 011 | +2M |
| 100 | −2M |
| 101 | −M |
| 110 | −M |
| 111 | 0 |

Two multiplier bits are consumed per iteration, so an 8-bit multiplication needs 4 iterations. Mathematically, with multiplier $Q = \sum q_i 2^i$ in two's complement:

$$Q = \sum_{j=0}^{3} \left(-2q_{2j+1} + q_{2j} + q_{2j-1}\right) 4^{j}$$

where each digit $d_j = -2q_{2j+1} + q_{2j} + q_{2j-1} \in \{-2,-1,0,1,2\}$ selects the multiple of $M$ to add.

### MAC unit (`mac_unit4`)

Computes a four-term dot product:

$$\text{result} = a_0 b_0 + a_1 b_1 + a_2 b_2 + a_3 b_3$$

A single `radix4_top` instance is reused for all four products. After each product, it is sign-extended from 16 to 20 bits and folded into the running `{sum_acc, carry_acc}` pair with a bitwise 3:2 compressor:

$$\text{csa\_sum} = S \oplus C \oplus P \qquad \text{csa\_carry} = \big((S\,C) \mid (S\,P) \mid (C\,P)\big) \ll 1$$

Only in `S_FINAL` is one ordinary carry-propagate addition performed: `result = sum_acc + carry_acc`.

**MAC FSM**

| State | Function |
|---|---|
| `S_IDLE` | Wait for `start`; clear index and CSA accumulators |
| `S_MUL_START` | One-cycle start pulse to the Booth multiplier |
| `S_MUL_WAIT` | Wait for `mul_done` |
| `S_ACCUM` | Fold product into CSA; advance to next term |
| `S_FINAL` | Resolve sum and carry with one CPA |
| `S_DONE` | Assert `done` for one cycle |

### Matrix top (`matrix_mult_4x4`)

Instantiates 16 `mac_unit4` cells. Each receives one full row of $A$ and one full column of $B$. All receive the same `start` pulse and run concurrently; the global `done` is the AND of all 16 MAC `done` signals. The Booth multiplier's latency does not depend on operand values, so all MACs finish together.

### Bit-width

An 8-bit × 8-bit signed product fits in 16 bits. Summing four products needs 2 more bits of headroom in theory; the design uses **20 bits** for the output. The documented worst case is

$$4 \times (127 \times (-128)) = -65024$$

which sits well inside the signed 20-bit range $[-524288,\ 524287]$.

---

## Repository Contents

| File | Description |
|---|---|
| `matrix_mult_4x4.v` | Top level: 16 parallel MAC units |
| `mac_unit4.v` | 4-term MAC with CSA accumulation and FSM |
| `radix4_top.v` | Booth multiplier top (controller + datapath) |
| `radix4_controller.v` | Booth multiplier FSM |
| `radix4_datapath.v` | Booth multiplier datapath |
| `booth_encoder.v` | Radix-4 Booth recoder |
| `operand_generator.v` | Generates 0, ±M, ±2M |
| `alu.v` | 16-bit adder |
| `A_reg.v`, `Q_reg.v`, `PIPO.v`, `history_reg.v`, `shiftreg2.v`, `counter.v` | Registers and counter |
| `matrix_mult_2x2.v`, `mac_unit.v` | 2×2 proof-of-concept (2-term MAC, 18-bit output) |
| `tb_matrix_mult_4x4.v` | Self-checking testbench for the 4×4 design |
| `tb_matrix_mult_2x2.v` | Testbench for the 2×2 prototype |
| `tb_radix4.v` | Testbench for the Booth multiplier |

---

## Getting Started

### Prerequisites

- [Xilinx Vivado](https://www.xilinx.com/support/download.html) (any recent version; the free WebPACK/Standard edition is enough for simulation)

### Simulate the 4×4 matrix multiplier (Vivado GUI)

1. Create a new RTL project (no board or part needed for simulation).
2. **Add Sources → Add or create design sources:** add all `.v` files except the `tb_*.v` files.
3. **Add Sources → Add or create simulation sources:** add `tb_matrix_mult_4x4.v`.
4. In **Sources → Simulation Sources**, right-click `tb_matrix_mult_4x4` and choose **Set as Top**.
5. Click **Run Simulation → Run Behavioral Simulation**.
6. The testbench ends with `$finish`, so use **Run All**. Check the Tcl console for per-element results and `ALL TESTS PASSED`, and inspect the waveform window for signal-level debugging.

### Simulate from the command line (Vivado xsim)

```bash
xvlog tb_matrix_mult_4x4.v matrix_mult_4x4.v mac_unit4.v \
      radix4_top.v radix4_controller.v radix4_datapath.v \
      booth_encoder.v operand_generator.v alu.v \
      PIPO.v A_reg.v Q_reg.v history_reg.v counter.v

xelab -debug typical tb_matrix_mult_4x4 -s sim_4x4
xsim sim_4x4 -runall          # add -gui to open the waveform viewer
```

The testbench prints each output element against its expected value and ends with `ALL TESTS PASSED` or a mismatch count.

### Other testbenches

To simulate the Booth multiplier alone or the 2×2 prototype, repeat the steps above with a different top:

| Testbench | Top module to set | Design files needed |
|---|---|---|
| `tb_radix4.v` | `tb_radix4` | `radix4_top.v`, `radix4_controller.v`, `radix4_datapath.v`, `booth_encoder.v`, `operand_generator.v`, `alu.v`, `PIPO.v`, `A_reg.v`, `Q_reg.v`, `history_reg.v`, `counter.v` |
| `tb_matrix_mult_2x2.v` | `tb_matrix_mult_2x2` | the files above plus `matrix_mult_2x2.v`, `mac_unit.v` |

> In Vivado, add only one testbench as the simulation top at a time.

### Usage

1. Apply `reset`, then release it.
2. Drive the 16 elements of `A` and 16 elements of `B` (row-major, signed 8-bit).
3. Pulse `start` for one clock cycle (inputs must stay stable until `done`).
4. Wait for `done`, then read `C00` … `C33` (signed 20-bit).

---

## Verification

The 4×4 design was verified against independently calculated reference values using a self-checking testbench. The project report documents a **50-case verification suite**, all passing:

| Category | Cases | Purpose |
|---|:---:|---|
| Boundary | 11 | Zero, identity, extreme signed values |
| Basic | 8 | Simple arithmetic, scalar and uniform patterns |
| Reference | 1 | Golden reference vector |
| Stress | 5 | Maximum-magnitude products, accumulator headroom |
| Structural | 13 | Sparse, triangular, symmetric, transpose-related |
| Sign | 7 | Signed arithmetic and cancellation |
| CSA | 5 | Large sums, negative sums, four-term accumulation |
| **Total** | **50** | |

> The `tb_matrix_mult_4x4.v` file in this repository runs a mixed-sign reference case. <!-- TODO: add the remaining test vectors to the testbench, or link to the verification document if you want the full 50 cases reproducible from the repo. -->

**Example (mixed-sign reference case):**

$$
A=\begin{bmatrix}1&2&3&4\\5&6&-7&8\\-9&10&11&-12\\13&-14&15&16\end{bmatrix},\quad
B=\begin{bmatrix}2&0&1&-1\\1&3&-2&2\\0&-1&4&1\\-3&2&1&0\end{bmatrix}
$$

$$
C=A\times B=\begin{bmatrix}-8&11&13&6\\-8&41&-27&0\\28&-5&3&40\\-36&-25&117&-26\end{bmatrix}
$$

---

## Design Notes

- **Area vs. speed:** each MAC reuses one Booth multiplier over four steps, which keeps each MAC small. The 16 MACs run in parallel, so latency does not grow with the number of output elements.
- **Why CSA:** intermediate sums stay in redundant form, so the carry chain is paid once per dot product rather than once per accumulate.
- **Signed handling:** operands are sign-extended into the datapath, the shift is arithmetic, and each 16-bit product is sign-extended to 20 bits before CSA folding.

## Future Work

- Scale to 8×8 using a larger MAC array or a systolic architecture
- Pipelining and parallel Booth multiplier instances for higher throughput
- Synthesis results (area, timing, power) compared with Wallace, Dadda, and array multipliers
- FPGA implementation, later ASIC-oriented synthesis
- Constrained-random and formal verification

## References

1. S. Vishwakarma, Z. Khan, J. J. Lehtomäki, "Impact of MAC Unit Design Architectures and Their Applications in Modern Computing: An In-Depth Review," *IEEE Access*, vol. 14, pp. 24339–24360, 2026.
2. A. Frank and K. B. Ramesh, "Design and Analysis of Multiplier Accumulator Circuit for DSP Applications," *Int. J. Advanced Science and Engineering*, vol. 8, no. 4, pp. 2425–2430, 2022.
3. M. M. Kamble and S. P. Ugale, "FPGA implementation and analysis of different multiplication algorithms," *Int. J. Computer Applications*, vol. 149, no. 2, 2016.

## Author

**Aayush Deole**
B.Tech, Electronics and Telecommunication Engineering
COEP Technological University, Pune
