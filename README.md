# rk.ctables: Custom Tables for RKWard

![Version](https://img.shields.io/badge/Version-0.0.1-blue.svg)
![License](https://img.shields.io/badge/License-GPL--3-green.svg)
![R Version](https://img.shields.io/badge/R-%3E%3D%203.0.0-lightgrey.svg)

**  

## Features

*   **Stacking (Rows):** Select multiple variables to stack them vertically (e.g., creating a demographic profile section).
*   **Nesting (Columns):** Select multiple grouping variables to create hierarchical headers (e.g., Gender > Age Group).
*   **Weighting:** Built-in support for survey weights (`tab_weight`).
*   **Statistics:** Easily toggle Counts, Column Percentages, and Row Percentages.
*   **Total Control:** Configure the label and position (Top/Bottom/None) of Total rows/columns.
*   **Output:** Generates formatted HTML tables directly in the RKWard output window.

## Requirements

*   **RKWard**: 0.7.5 or higher.
*   **R Packages**:
    *   `expss`
    *   `magrittr` (for piping `%>%`)

## Installation

1.  Open R in RKWard.
2.  Run the following commands in the R console:

```R
local({
## Preparar
require(devtools)
## Computar
  install_github(
    repo="AlfCano/rk.ctables"
  )
## Imprimir el resultado
rk.header ("Resultados de Instalar desde git")
})
```
3.  Restart RKWard to ensure the new menu items appear correctly.

## Usage & Examples

The plugin relies on **Variable Labels** to produce professional tables (just like SPSS). Without labels, the table will show raw variable names (e.g., `sex`) instead of "Gender".

### Step 0: Prepare Data (Penguins)
Copy and run this code in your RKWard console to load the `penguins` dataset and apply labels:

```R
# Load data (Included in R 4.5+ or package palmerpenguins)
data("penguins")

# Apply Labels (expss uses these for the table headers)
library(expss)
penguins = apply_labels(penguins,
    species = "Penguin Species",
    island = "Island Location",
    bill_length_mm = "Bill Length (mm)",
    sex = "Gender",
    year = "Study Year"
)
```

### Example 1: Basic Stacking (Demographics Table)
Create a summary table showing multiple variables stacked vertically.

1.  Navigate to **Analysis > Custom Tables (expss) > Custom Table Builder**.
2.  **Rows (Stacked):** Select `species` AND `island`.
3.  **Columns:** Leave empty (defaults to Total).
4.  **Statistics:** Check **Counts (Cases)** and **Column Percent %**.
5.  Click **Submit**.
    *   *Result:* A vertical table showing the distribution of Species, followed immediately by the distribution of Islands.

### Example 2: Simple Crosstab
Compare groups side-by-side.

1.  **Rows:** Select `species`.
2.  **Columns:** Select `sex`.
3.  **Statistics:** Check **Column Percent %**.
4.  Click **Submit**.
    *   *Result:* A standard crosstab showing Species distribution broken down by Gender.

### Example 3: Complex Nesting (Hierarchical Columns)
Create a highly detailed table by nesting grouping variables.

1.  **Rows:** Select `species`.
2.  **Columns:** Select `sex` AND `year`.
3.  **Statistics:** Check **Counts** and **Column Percent %**.
4.  **Total Position:** Select **After (Right/Bottom)**.
5.  Click **Submit**.
    *   *Result:* A wide table where "Male" and "Female" are the main headers, and each gender is further subdivided by "2007", "2008", and "2009".

## Author

**Alfonso Cano Robles**
*   Email: alfonso.cano@correo.buap.mx

Assisted by Gemini, a large language model from Google.
