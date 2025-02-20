#!/bin/bash
# Run script for railway ballast flooding simulation

# Clean any previous run
rm -rf [1-9]*
rm -rf processor*
rm -rf postProcessing
rm -rf log.*
rm -rf constant/polyMesh

# Step 1: Create the mesh
blockMesh
if [ $? -ne 0 ]; then
    echo "ERROR: blockMesh failed. Exiting."
    exit 1
fi
echo "Mesh generation completed."

# Create cell set for ballast region
cat > system/topoSetDict << 'EOF'
/*--------------------------------*- C++ -*----------------------------------*\
| =========                 |                                                 |
| \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\    /   O peration     | Version:  12                                    |
|   \\  /    A nd           | Website:  www.openfoam.org                      |
|    \\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/
FoamFile
{
    version     2.0;
    format      ascii;
    class       dictionary;
    object      topoSetDict;
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

actions
(
    {
        name    ballastCells;
        type    cellSet;
        action  new;
        source  boxToCell;
        box     (5 0 -1) (15 0.5 1);
    }
);
EOF

topoSet
echo "Defined ballast region."

# Step 2: Initialize water level
setFields
echo "Fields initialized."

# Step 3: Run the simulation
echo "Starting solver..."
foamRun -solver incompressibleVoF | tee log.simulation

# Extract flow rate data
echo "Extracting flow rate data..."
foamLog log.simulation

# Plot flow rates if the data exists
if [ -f "postProcessing/inletFlowRate/0/surfaceFieldValue.dat" ] && [ -f "postProcessing/outletFlowRate/0/surfaceFieldValue.dat" ]; then
    cat > plotFlowRates.gnuplot << 'GNUPLOT'
set terminal png size 1200,800
set output "flowRates.png"
set title "Flow Rate Comparison: Inlet vs Outlet"
set xlabel "Time (s)"
set ylabel "Flow Rate (m³/s)"
set grid
plot "postProcessing/inletFlowRate/0/surfaceFieldValue.dat" using 1:2 with lines title "Inlet Q", \
     "postProcessing/outletFlowRate/0/surfaceFieldValue.dat" using 1:2 with lines title "Outlet Q"
GNUPLOT

    gnuplot plotFlowRates.gnuplot
    echo "Flow rates plotted in flowRates.png"
else
    echo "Flow rate data files not found. Skipping plot generation."
fi

echo "=== SIMULATION COMPLETE ==="
echo "Results can be visualized using ParaView with:"
echo "paraFoam"