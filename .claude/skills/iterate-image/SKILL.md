---
name: iterate-image
description: Iteratively refine Python graph/chart generation by viewing output images and fixing visual issues like spacing, overlapping titles, legends, or clipped elements. Use when generating matplotlib, seaborn, or plotly visualizations that need layout refinement.
argument-hint: <image-path> [focus-criteria]
allowed-tools: Read, Glob, Grep, Edit, Write, Bash
---

# Image Iteration Protocol

You are refining a Python-generated graph/chart. Your goal is to view the output image, identify visual issues, fix the code, regenerate, and repeat until the image looks correct.

## Setup (First Iteration Only)

1. **Read the image** at path `$ARGUMENTS` using the Read tool
2. **Ask for the generation command** if not provided (e.g., `uv run plot.py`)
3. For subsequent iterations, reference the conversation history to find the command. Ask clarifying questions if confused.

## Iteration Loop (Max 5 iterations)

For each iteration:

### Step 1: Analyze the Image

Read the image and check for visual issues. Use this checklist as a starting point, but also look for any other similar problems not listed here:

**Layout Issues**
- Title clipped or overlapping with plot area
- Subtitle/suptitle overlapping with title or axes
- Axis labels cut off or overlapping tick labels
- Legend overlapping data points or extending outside figure
- Colorbar overlapping or poorly positioned

**Spacing Issues**
- Insufficient margins (elements touching figure edges)
- Text elements too close together
- Subplots overlapping or too cramped
- Tick labels overlapping each other

**Readability Issues**
- Text too small to read
- Poor contrast (light text on light background)
- Overlapping data labels or annotations

**Other**: Look for any visual issues beyond this list - anything that looks wrong, misaligned, or unprofessional.

### Step 2: Report Findings

Briefly state what issues you found (or "no issues detected").

### Step 3: Fix the Code

If issues found, edit the plotting code. Common fixes for matplotlib:

```python
# Prevent clipping
plt.tight_layout()
fig.savefig(..., bbox_inches='tight')

# Adjust subplot spacing
plt.subplots_adjust(top=0.85, bottom=0.15, left=0.1, right=0.9, hspace=0.3, wspace=0.3)

# Move legend outside
ax.legend(loc='upper left', bbox_to_anchor=(1.02, 1))

# Rotate tick labels
plt.xticks(rotation=45, ha='right')

# Increase figure size
fig, ax = plt.subplots(figsize=(12, 8))

# Add padding to title
ax.set_title('Title', pad=20)
fig.suptitle('Suptitle', y=1.02)

# Constrained layout (alternative to tight_layout)
fig, ax = plt.subplots(layout='constrained')
```

### Step 4: Regenerate

Run the generation command (e.g., `uv run plot.py`)

### Step 5: Re-read and Repeat

Read the new image and go back to Step 1.

## Termination

**Stop iterating when:**
- No visual issues detected
- 5 iterations reached (ask user for guidance)
- Stuck in a loop (same issues recurring)

**On completion**, summarize:
- Issues found and fixed
- Final state of the image
- Any remaining concerns
