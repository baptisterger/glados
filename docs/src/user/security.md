# Sécurité et Robustesse

Le Cédric a été conçu pour offrir une expérience de programmation **robuste et sûre**, en éliminant les pièges courants des langages hérités comme le C.

---

## 1. Le Cédric est de Type Statique Fort

Votre code est vérifié par le compilateur avant même de s'exécuter.
* **Détection Précoce des Erreurs :** Si vous tentez d'utiliser une variable avec un mauvais type ou d'appeler une fonction avec des arguments incorrects, le compilateur **échouera immédiatement** avec un message d'erreur clair.
* **Exemple d'Erreur Interdite :**

    ```cedric
    skibidi main() {
      int a = 3.14; // ERREUR À LA COMPILATION : impossible d'assigner un float à un int
      return 0;
    }
    ```

---

## 2. Adieu aux Problèmes de Mémoire

En tant qu'utilisateur du Cédric, vous n'aurez **jamais** à vous soucier des dépassements de tampon (*buffer overflows*) ou des accès à la mémoire libérée (*Use-After-Free*).

Le Cédric ne supporte **pas** :
* L'utilisation directe des **pointeurs**.
* L'**arithmétique des pointeurs**.
* La **gestion manuelle de la mémoire**.

Cette interdiction structurelle est notre principal mécanisme de sécurité, car elle élimine la cause la plus fréquente des failles de sécurité logicielles.

---

## 3. Sandboxing par Conception

Grâce à sa cible de compilation **WebAssembly (WASM)**, le code Cédric s'exécute dans un **bac à sable sécurisé** (*sandbox*).
* Votre programme ne peut pas accéder aux ressources du système (fichiers, réseau, etc.) sans autorisation explicite, garantissant ainsi qu'il ne causera pas de dommages involontaires ou malveillants à votre machine.