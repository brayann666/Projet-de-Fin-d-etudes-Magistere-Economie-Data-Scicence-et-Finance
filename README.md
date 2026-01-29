# **Final-Year Project – Reproducibility of a Research Article**

## **Project Context**

This repository is part of the **third‑year research track of the Magistère Ingénieur Économiste**.  
The **Final-Year Project (PFE)** aims to develop key skills required for producing scientific research, including:

- in‑depth understanding of an academic article  
- empirical reproducibility  
- critical assessment of methodological choices  
- rigorous implementation of code and data workflows  

---

## **Objective of the Project**

The project consists in selecting a scientific article and assessing its reproducibility along three main dimensions:

### **1. Reproducibility of the results**  
→ Can the main findings of the paper be replicated?

### **2. Validity of the provided code**  
→ Do the authors’ scripts actually reproduce the theoretical and empirical approach described in the article?

### **3. Robustness of the results**  
→ Do the conclusions hold when the empirical approach is slightly modified (sample, specification, variables, transformations, etc.)?

---

## **Article Under Study**

We chose to reproduce the following article:

**_Carbon Taxation and Greenflation: Evidence from Europe and Canada_**  
**Maximilian Konradt**, Geneva Graduate Institute, Switzerland  
**Beatrice Weder di Mauro**, Geneva Graduate Institute, Switzerland; INSEAD, France  

This article analyzes the effects of carbon taxation policies on price dynamics (“greenflation”) in Europe and Canada, using macroeconomic data and advanced empirical methods.

---

## **Repository Structure**

```
data/         → datasets used or reconstructed for the replication
src/          → Python / R / Stata scripts
notebooks/    → exploratory and replication notebooks
results/      → tables, figures, and empirical outputs
README.md     → project overview
LICENSE       → usage license
.gitignore    → files excluded from Git tracking
```

---

## **General Methodology**

Our approach follows three steps:

### **1. Strict reproduction**
Faithfully reproduce the paper’s results using:

- the original data (when available)  
- the authors’ code  
- or reconstructed data when necessary  

### **2. Verification of methodological consistency**
Compare:

- the methods described in the article  
- the methods actually implemented in the scripts  
- the results obtained  

### **3. Robustness checks**
Assess the stability of the results by modifying:

- econometric specifications  
- samples  
- variables  
- transformations  
- identification strategies  

---

## **Authors**

- **Brayann Adjanohoun**, M2 Economics Research – Magistère Track  
- **Simon Labracherie**, M2 Econometrics Research – Magistère Track  

Supervisor: **Ewen Gallic**

---

## **License**

This project is distributed under the **GNU GPL v3** license.  
See the `LICENSE` file for more information.
