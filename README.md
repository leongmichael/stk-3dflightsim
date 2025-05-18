# Flight Simulation in STK

## Summary
Simulate flight trajectories in 3D through AGI STK. 


---

## Requirements
- MATLAB (with COM Automation Server enabled)
- AGI STK 12 or later
- Excel file with flight data
- Provided scripts:
  - `pathToEphemeris.m`
  - `generateVideo.m`
  - `SampleOutput.xlsx` (example data)

---

## Setup

### 1. Flight Data

Ensure your Excel file is formatted with the following columns:

> time (s), lat, long, alt (ft), ecef x (ft), ecef y (ft), ecef z (ft), vx, vy, vz


Use `SampleOutput.xlsx` as a reference for the expected format.

---

### 2. Generate Ephemeris File

- Open `pathToEphemeris.m`.
- Set the file path to your Excel file inside the script.
- Run the script to generate a `.e` ephemeris file (plain text format).

This file defines the trajectory for STK to simulate.

---

### 3. Simulate and Record in STK

- Run `generateVideo.m` in MATLAB.
- This script will:
  - Launch STK and create a new scenario
  - Load the ephemeris file
  - Set the camera view and animation parameters
  - Animate the trajectory
  - Record and export a video of the simulation

---
