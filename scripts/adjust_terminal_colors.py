#!/usr/bin/env python3
import sys
import pywal
from subprocess import check_output
import json

colorspace = sys.argv[1]
fraction = sys.argv[2]
generate_from_old_colors = len(sys.argv) == 4 
# get current color scheme
if generate_from_old_colors:
    generated_colors = pywal.colors.file("/home/sahin/.cache/wal/.old_colors.json")
else:
    generated_colors = pywal.colors.file("/home/sahin/.cache/wal/colors.json")

reference_colors = ['black', 'red', 'green', 'yellow', 'blue' , 'magenta', 'cyan', 'white']

with open("/home/sahin/.cache/wal/.old_colors.json", 'w') as f:
    json.dump(generated_colors, f)


# we will only use first 8 colors in the terminal
terminal_colors = list(generated_colors['colors'].items())[:8]

for (name, t), ref in zip(terminal_colors, reference_colors):
        command = f"pastel mix {t[1:]} {ref} "\
                  f"--colorspace={colorspace} "\
                  f"--fraction={fraction} | pastel format"
        generated_colors['colors'][name] = check_output(command, 
                shell=True).decode('utf8').strip()

# generated_colors['special']['background'] = generated_colors['colors']['color0']
# generated_colors['special']['foreground'] = generated_colors['colors']['color7']
# generated_colors['special']['cursor'] = generated_colors['colors']['color7']
# print(colors)

# image = generated_colors["wallpaper"]

# Apply the palette to all open terminals.
# Second argument is a boolean for VTE terminals.
# Set it to true if the terminal you're using is
# VTE based. (xfce4-terminal, termite, gnome-terminal.)
pywal.sequences.send(generated_colors)

# Export all template files.
pywal.export.every(generated_colors)

# Reload xrdb, i3 and polybar.
# pywal.reload.env()

# Set the wallpaper.
# pywal.wallpaper.change(image)
