"""
Plot Some Basic GSI Diagnostics

shawn.s.murdzek@noaa.gov
"""

#---------------------------------------------------------------------------------------------------
# Import Modules
#---------------------------------------------------------------------------------------------------

import sys
import matplotlib.pyplot as plt
import numpy as np

import pyDA_utils.gsi_fcts as gsi



#---------------------------------------------------------------------------------------------------
# Input Parameters
#---------------------------------------------------------------------------------------------------

bgd_fname = sys.argv[1]
ana_fname = sys.argv[2]
timestamp = sys.argv[3]   # YYYYMMDDHH
out_dir = sys.argv[4]

#---------------------------------------------------------------------------------------------------
# Make Plots
#---------------------------------------------------------------------------------------------------

# Open files
bgd = gsi.read_diag([bgd_fname], ftype='text', date_time=[timestamp])
ana = gsi.read_diag([ana_fname], ftype='text', date_time=[timestamp])

# Make plots
all_typ = bgd['Observation_Type'].unique()
for t in all_typ:
    all_v = list(bgd.loc[bgd['Observation_Type'] == t, 'Observation_Class'].unique())
    if 'uv' in all_v:
        all_v.remove('uv')
        all_v = all_v + ['u', 'v']
    for v in all_v:
        print(f"plotting {t} {v}")
        fig, ax = plt.subplots(nrows=1, ncols=1)
        ax = gsi.plot_hist_omf(bgd, ana, v, t, ax=ax)
        plt.savefig(f"{out_dir}/{t}_{v}_{timestamp}.png")
        plt.close()


"""
End gsi_diag_plots.py
"""
