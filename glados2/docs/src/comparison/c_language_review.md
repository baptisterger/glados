# Revue de Sécurité du Langage C

Le langage **C** a servi d'inspiration principale à la syntaxe du Cédric. Cependant, le C est bien connu pour introduire des risques de sécurité majeurs, particulièrement liés à sa gestion de la mémoire et à son absence de mécanismes de sécurité intégrés.

Cette analyse justifie les choix architecturaux et les fonctionnalités de sécurité implémentées dans le Cédric.

---

## 1. Failles Structurelles du C

Le C est un langage de bas niveau qui offre un accès direct à la mémoire, ce qui est une source de puissance, mais aussi de vulnérabilités critiques :

### A. L'Arithmétique des Pointeurs et l'Accès Direct à la Mémoire
Le C permet la manipulation directe des adresses mémoire (pointeurs). Cette flexibilité ouvre la porte à des erreurs de programmation qui se transforment en failles de sécurité majeures :
* **Dépassement de Tampon (Buffer Overflows) :** L'absence de vérification automatique des bornes des tableaux conduit les programmes C à écrire au-delà des limites allouées, corrompant la mémoire adjacente. C'est la source la plus fréquente d'attaques par exécution de code arbitraire.
* **Use-After-Free (UAF) :** Le développeur est responsable de libérer la mémoire manuellement. Si cette mémoire est réutilisée après avoir été libérée, cela cause des bugs ou permet à un attaquant de manipuler le flux d'exécution.

### B. Gestion des Erreurs et Comportement Indéfini
Le C utilise des codes de retour et des variables globales (comme `errno`) pour la gestion des erreurs, une approche facilement ignorée.
* **Comportement Indéfini :** De nombreuses opérations (comme la division par zéro, les déréférencements de pointeurs nuls, ou les débordements d'entiers) résultent en un comportement « indéfini » selon la norme C. Cela signifie que le résultat dépend de l'architecture ou du compilateur, rendant les programmes imprévisibles et souvent vulnérables.

---

## 2. Conclusion de l'Analyse
Pour créer un langage **robuste et sûr**, il est impératif d'intégrer des mécanismes qui suppriment ces dangers structurels, tout en conservant une syntaxe familière et performante. C'est l'objectif de la conception du Cédric.