# FIFO
This project implements a First-In-First-Out (FIFO) memory structure in Verilog and verifies its functionality using SystemVerilog assertions and functional coverage.

Key Features:

Synchronous Design: The FIFO operates synchronously with a single clock signal for read and write operations.
SystemVerilog Assertions: Assertions are employed to verify essential FIFO properties like underflow (attempting to read from an empty FIFO) and overflow (attempting to write to a full FIFO) conditions.
Functional Coverage: SystemVerilog functional coverage monitors various aspects of FIFO behavior to ensure comprehensive verification.
