# A Local Projections Approach to Difference-in-Differences

## Specification 1. Static two-way fixed-effects regression (static TWFE)

$$ y_it = α_i^STWFE + δ_t^STWFE + β^STWFE · D_it + e_it^STWFE   (2) $$

where:
- α_i are unit-specific intercepts  
- δ_t are common time-specific intercepts  
- e_it denotes the error term  

---

## Specification 2. Dynamic two-way fixed-effects regression (dynamic TWFE)


$$ y_it = α_i^ETWFE + δ_t^ETWFE
     + Σ_{h = −Q}^{H} γ_h^ETWFE · D_{i,t−h}
     + e_it^ETWFE ,   Q, H ≥ 0   (3) $$

where:

$$ β_h^ETWFE = Σ_{j = 0}^{h} γ_j^ETWFE $$

is the effect at horizon h after treatment (0 ≤ h ≤ H)

$$ β_{−h}^ETWFE = − Σ_{j = −h}^{−1} γ_j^ETWFE $$

captures possible pre-trends (−Q ≤ h ≤ −1)

---

## Specification 3. Local Projections regression (LP)

$$ y_{i,t+h} − y_{i,t−1}
= δ_t^h + β_h^LP · ΔD_it + e_it^h $$

for:
- h = −Q, …, 0, …, H  
- Q, H ≥ 0  
- h ≠ −1  

As a result of differencing, unit fixed effects are removed.
A separate regression is estimated for each horizon h.

---

## LP-DiD Estimator

Key idea: restrict comparisons to **clean** treated and control units.

---

## LP-DiD Regression

$$ y_{i,t+h} − y_{i,t−1}
= β_h^{LP-DiD} · ΔD_it
+ δ_t^h
+ e_it^h $$

Estimation sample restricted to:

```
Newly treated:   $$ ΔD_it = 1 $$
Clean control:   $$ D_{i,t+h} = 0 $$
```
