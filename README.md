# ASIC Acceleration for Graph Convolutional Neural Networks (GCNs)

This project implements a hardware accelerator for Graph Convolutional Neural Networks (GCNs) using ASIC design methodology. The accelerator is designed to perform node classification on graph data, specifically classifying movie nodes into three genres: Action, Humor, and Family.

## Project Overview

Graph Convolutional Networks (GCNs) are neural networks designed for analyzing and processing data represented as graphs. GCNs transform high-dimensional graph data to lower dimensions while preserving the graph structure, making them useful for applications in social networks, bioinformatics, and recommendation systems.

The GCN accelerator implements two main operations:

- **Feature Transformation**: Matrix multiplication between feature matrix and weight matrix
- **Feature Aggregation**: Sparse matrix multiplication using Coordinate (COO) format for efficient computation
- **Classification**: Argmax function to determine the final node classification

## Design Architecture

The accelerator consists of three main blocks:

### Transformation Block

- Performs matrix multiplication between Feature Matrix (6×96) and Weight Matrix (96×3)
- Uses a vector multiplier for efficient computation
- Includes control FSM, scratchpad memory, and counters

### Combination Block

- Processes the COO format of the adjacency matrix
- Performs the aggregation operation
- Translates COO data to matrix multiplication

### Argmax Block

- Performs classification by finding the index of the maximum value for each node
- Outputs the final classification results

## Implementation Flow

The project follows a complete ASIC design flow:

1. **RTL Design**: System Verilog implementation of the GCN module
2. **Functional Verification**: Simulation using Using Synopsys ModelSim and testbench
3. **Synthesis**: Using Synopsys Design Compiler
4. **Place and Route**: Using Cadence Innovus
5. **Post-layout Verification**: Simulation, Timing and power analysis using Synopsys ModelSim

## Performance Targets

- End-to-end latency < 100ns
- Optimized for low power consumption
- Correct functionality matching the expected classification results

## Key Features

- Efficient sparse matrix multiplication using COO format
- Pipelined design for improved throughput
- Parameterized implementation for flexibility
- Power-optimized architecture

## Design Decisions

- The adjacency matrix is represented in COO format for memory efficiency
- Feature transformation is performed before aggregation due to the associative property of matrix multiplication
- The design includes input/output flip-flops at module boundaries
- Memory access is optimized to read one row at a time

## Tools Used

- **RTL Design**: Verilog
- **Simulation**: ModelSim
- **Synthesis**: Synopsys Design Compiler
- **Place & Route**: Cadence Innovus
- **DRC/LVS**: Cadence Virtuoso

## Repository Structure

- [RTL](src/): Verilog source files
- `scripts/`: Synthesis scripts
- `simulation/`: Testbench, Input and Output Data Files
- `docs/`: Documentation and reports

## Results

The design achieves:

- Functional correctness for node classification
- Meets timing constraints with positive slack
- Optimized power consumption
- DRC and LVS clean layout

---

This project provides a comprehensive approach to implementing a GCN accelerator using ASIC design methodologies, ensuring efficient and accurate node classification for graph data.
