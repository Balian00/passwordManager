## Password Manager (Beta ASM + C)

### 1) Objet du projet
- Implémenter un gestionnaire de mots de passe en assembleur Beta, en suivant les consignes des deux PDF de TP.
- Le code C (`C/password_management.c`) sert de référence fonctionnelle : mêmes cas gérés (mots de passe vides, très longs, erreurs d'index, vérifs correctes/incorrectes) et même logique de hash/stockage. L’ASM doit reproduire fidèlement ces comportements.

### 2) Exécuter et tester `main`
- Générer les constantes de chaînes en Beta ASM : `gcc string_to_beta_asm.c -o string_to_beta_asm` puis exécuter le binaire pour actualiser les `LONG(...)` des mots de passe si besoin.
- Pour des tests déterministes, initialiser la table `T[i] = i` (pas de tirage aléatoire) dans `table.asm`/`util.asm` selon vos stubs, afin que les hachages soient reproductibles.
- Assembler/charger `skeleton/main.asm` dans le simulateur Beta. Les `CALL(verifyPassword, 2)` sont suivis de breakpoints : à chaque arrêt, lire `R0` et comparer à la séquence attendue indiquée en commentaire.

### 3) Avantages et limites
- Avantages : code simple à auditer, tests exhaustifs (bons/mauvais mots de passe, index hors bornes), version C de référence pour valider l’ASM.
- Limites bloquantes pour un usage réel : pas de persistance ni de chiffrement au repos, pas de protection mémoire/isolement, hachage non renforcé (pas de sel/itérations), pas de gestion d’entrées utilisateur hostiles, dépendance au simulateur Beta (non portable sur une vraie machine sans portage lourd).
