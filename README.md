#  Projet de Fin d’Études – Reproductibilité d’un Article de Recherche

##  Contexte du projet

Ce dépôt s’inscrit dans le cadre du **parcours de recherche de la troisième année du Magistère Ingénieur Économiste**.  
Le **Projet de Fin d’Études (PFE)** vise à développer des compétences essentielles à la production de recherche scientifique, notamment :

- la compréhension approfondie d’un article académique,  
- la reproductibilité empirique,  
- l’analyse critique des méthodes,  
- la mise en œuvre rigoureuse de codes et de données.

---

##  Objectif du PFE

Le projet consiste à sélectionner un article scientifique et à en étudier la reproductibilité selon trois axes :

### 1. **Reproductibilité des résultats**  
→ Peut‑on retrouver les résultats principaux du papier ?

### 2. **Validité des codes fournis**  
→ Les scripts mis à disposition permettent‑ils réellement de reproduire l’approche théorique et empirique décrite dans l’article ?

### 3. **Robustesse des résultats**  
→ Les conclusions tiennent‑elles lorsque l’on modifie légèrement l’approche empirique (échantillon, spécification, variables, transformations, etc.) ?

---

##  Article étudié

Nous avons choisi de reproduire l’article suivant :

**_Carbon Taxation and Greenflation: Evidence from Europe and Canada_**  
**Maximilian Konradt**, Geneva Graduate Institute, Switzerland  
**Beatrice Weder di Mauro**, Geneva Graduate Institute, Switzerland; INSEAD, France  

Cet article analyse les effets des politiques de taxation carbone sur la dynamique des prix (« greenflation ») en Europe et au Canada, en mobilisant des données macroéconomiques et des approches empiriques avancées.

---

##  Contenu du dépôt

Ce dépôt contient :

- **data/** : données utilisées ou reconstruites pour la reproduction  
- **src/** : scripts Python / R / Stata  
- **notebooks/** : notebooks d’exploration et de reproduction  
- **results/** : tableaux, graphiques et sorties empiriques  
- **README.md** : présentation du projet  
- **LICENSE** : licence d’utilisation  
- **.gitignore** : fichiers à exclure du suivi Git  

---

##  Méthodologie générale

Notre démarche suit trois étapes :

### 1. **Reproduction stricte**
Reproduire fidèlement les résultats du papier à partir :

- des données originales (si disponibles),  
- des codes fournis par les auteurs,  
- ou des données reconstruites lorsque nécessaire.

### 2. **Vérification de la cohérence méthodologique**
Comparer :

- les méthodes décrites dans l’article,  
- les méthodes réellement implémentées dans les scripts,  
- les résultats obtenus.

### 3. **Tests de robustesse**
Explorer la stabilité des résultats en modifiant :

- les spécifications économétriques,  
- les échantillons,  
- les variables,  
- les transformations,  
- ou les méthodes d’identification.

---

##  Auteurs

- **Brayann Adjanohoun**, M2 Économie Recherche – Parcours Magistère  
- **Simon Labracherie**, M2 Économétrie Recherche – Parcours Magistère  

Encadrant : **Ewen Gallic**

---

##  Licence

Ce projet est distribué sous licence **GNU GPL v3**.  
Voir le fichier `LICENSE` pour plus d’informations.

---
