set terminal png size 1200,800
set output "flowRates.png"
set title "Flow Rate Comparison: Inlet vs Outlet"
set xlabel "Time (s)"
set ylabel "Flow Rate (m³/s)"
set grid
plot "postProcessing/inletFlowRate/0/surfaceFieldValue.dat" using 1:2 with lines title "Inlet Q", \
     "postProcessing/outletFlowRate/0/surfaceFieldValue.dat" using 1:2 with lines title "Outlet Q"
