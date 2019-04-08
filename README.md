# Wiki du projet Plasma PMOD

Ce dépôt git est dédié à la modification (matérielle et logicielle) du processeur softcore [Plasma](https://opencores.org/project,plasma "Plasma's Homepage") afin de pouvoir gérer des modules PMOD sur les cartes de développement Nexys-4 de Digilent.

* [Documentation](DOCUMENTATION/DOCUMENTATION.md)
* [Tutoriels](DOCUMENTATION/TUTORIELS.md)
* [Memory map](DOCUMENTATION/MEMORY-MAP.md)
# Plasmabyrynthe

## Introduction
Ce projet consiste à réaliser un jeu "labyrinthe" en utilisant le soc plasma et
des modules d'accélération matérielle qui lui sont connectés. Le labyrinthe est
généré aléatoirement au début du jeu et le joueur peut ensuite se déplacer sur
2 axes avec des boutons ou le joystick afin d'atteindre l'autre extrémité. Il
est également possible d'utiliser la technique "du mur à droite" pour résoudre
le labyrinthe car ce dernier est parfait, c'est-à-dire sans cycle ni espaces
disjoints (chaque cellule est reliée à toutes les autres de manière
unique).L'affichage est fait sur un afficheur Oled, et un zoom est disponible
grâce aux switchs.

## Utilisation
Les modules PMOD sont branchés de cette manière :
- PMOD Oled sur JB
- Joystick sur JC

Pour utiliser ce programme, il faut tout d'abord synthétiser le plasma via la
commande
```sh
make
```
puis le programmer :
```sh
make send pgcd
```
Le programme démarre immédiatement, et le labyrinthe peut être généré via le
bouton bas du joystick, la seed du labyrinthe était la valeur du joystick au
moment de l'appui. Le joueur peut ensuite se déplacer vers
haut/bas/gauche/droite grâce au joystick ou aux boutons correspondants disposés
en croix sur la Nexys4. Il est possible de choisir un zoom de la vue grâce aux
switchs sur la carte, une valeur entre 2 et 3 étant conseillée. Celle-ci est
codée en binaire sur le switch, avec ceux de droites de poids faible.

Il est également possible de voir évoluer une résolution automatique du
labyrinthe en appuyant sur le bouton central de la croix sur la Nexys4.

## Fonctionnement
L'architecture utilisée est celle du plasma programmé en C entouré de modules
vhdl pour l'afficheur oled (fourni avec le projet), le joystick (code fourni
par Digilent) et d'un générateur de nombres aléatoires réalisé par nous-mêmes.

### Modules HDL
L'afficheur Oled est entièrement rafraichi pour afficher une matrice stockée
en mémoire régulièrement via le programme.

Le joystick est lu à intervalles réguliers et déclenche un déplacement si sa
valeur est au-dessus d'un certain seuil.

Le générateur de nombres aléatoires est un LFSR du type Galois qui permet de
générer des nombres pseudo-aléatoires à un débit élevé pour générer le
labyrinthe sans consommer de ressources processeur à partie d'une source
d'entropie initiale, qui dans notre cas est une valeur analogique du joystick.

### Programme
Le code C permet d'une part de développer le comportement fonctionnel du jeu,
mais d'autre part d'interagir avec les différents modules matériels externes.

Une première partie s'occupe du stockage et de la génération du labyrinthe.  Le
labyrinthe est stocké dans un tableau d'entiers déclaré en tant que variable
globale au tout début du main. Les tailles du labyrinthe sont forcément
impaires. En effet, les cases aux coordonnées (impaire, impaire) sont des cases
toujours libres, les cases aux coordonnées (paire, paire) sont toujours des
murs, et les autres cases sont des passages ouverts ou non par l'algorithme de
génération, pour créer des passages entre les cases de coordonnées (paire,
paire).  Chaque case représente finalement une cellule du labyrinthe. Si la
case vaut 0, alors le joueur peut la traverser (elle est vide), sinon pour
toute autre valeur, la case est un mur. Chaque case est enregistrée sur un
"int" car l'algorithme de génération nécessite des plages de valeurs entre 0 et
le nombre total de cases dans le labyrinthe.L'algorithme de génération utilisé
se base sur la fusion aléatoire de chemins. L'avantage de cet algorithme, c'est
qu'il assure la construction d'un labyrinthe parfait: c'est-à-dire qu'il existe
un et un seul chemin entre n'importe quel couple de cases du labyrinthe.  Le
principe est le suivant: (source:
[Wikipedia](https://fr.wikipedia.org/wiki/Mod%C3%A9lisation_math%C3%A9matique_de_labyrinthe))
On commence par initialiser le labyrinthe en remplissant toutes les cases par
une valeur extrême remarquable: -1 par exemple. On remplit ensuite toutes les
cases aux coordonnées de type (impaire, impaire) par des entiers tous
différents (entiers que nous assimileront à des couleurs). Ces cases sont les
cellules toujours traversables du labyrinthe mais qui sont au départ toutes
isolées par des murs. On choisit ensuite un mur aléatoire non cassé entre deux
cellules. Si les deux cellules ont une même couleur (ce qui est impossible au
début mais possible après plusieurs itérations), alors on choisit un autre mur,
jusqu'à trouver un mur non cassé entre deux cellules de couleurs différentes.
On casse alors ce mur (en lui affectant 0 par exemple), ce qui a pour effet de
relier deux chemins différents de cellules. Il faut alors ensuite colorier
toutes les cases de l'un des chemins par la couleur de l'autre chemin. Il faut
ensuite réitérer ce processus jusqu'à avoir toutes les cases de la même
couleur.  À ce moment-là, le labyrinthe créé est alors parfait.

Une des multiples propriétés du labyrinthe parfait, est qu'il peut être
parcouru par un algorithme très simple appelé "méthode de la main droite". Le
principe de cet algorithme est le suivant: On commence à un endroit quelconque
du labyrinthe. On imagine ensuite être physiquement présent dans le labyrinthe
et on pose sa main droite sur l'un des murs. Il suffit ensuite d'avancer tout
en gardant sa main sur le mur, et on est assuré de parcourir tout le
labyrinthe, et donc de trouver la sortie.  Cet algorithme a été implémanté très
facilement et permet ainsi d'obtenir un parcours visuel de tout le labyrinthe.

### Interface
Le contrôle du programme se fait à l'aide des différents modules externes
connectés au Plasma.En premier, le module LFSR permet de générer des nombres
aléatoires pour la génération du labyrinthe. Un autre module permet ensuite le
contrôle d'un écran Oled RGB pour afficher l'état du jeu. Un module permet de
communiquer avec un joystick afin de contrôler le curseur dans le labyrinthe.
Ce joystick étant analogique, ses valeurs de sorties sont utilisées pour
initialiser le module LFSR. C'est en quelque sorte, en plus du contrôle, un
générateur d'entropie pour l'aléatoire. Enfin un dernier module permet
d'interagir avec les switchs et les boutons de la carte Nexys 4, pour définir
le zoom graphique de l'écran et pour lancer le pathfinding.

Tous ces modules sont directement connectés au plasma et les entrées sorties
sont directement connectées à certaines adresses internes. Ainsi, une lecture
de sortie de l'un des modules se traduit par une lecture en mémoire à une
adresse définie auparavant. De même, une écrite sur une entrée d'un module se
traduit par une écriture dans la mémoire à une adresse définie auparavant.

De cette façon, le code C permet d'exécuter un algorithme développé tout en
interagissant avec des modules physiques externes.

## Commentaires
L'intégration des modules annexes au processeur fonctionne et tous les modules
sont utilisés dans le code C via des accès mémoire. Seul le joystick présente
parfois une certaines latence dans sa réactivité mais nous n'avons pas
identifié la source de ce problème. Certaines sécurités comme sur le zoom n'ont
pas été totalement implémentées et peuvent causer des plantages du processeur
en carte de trop forte valeur, car la mémoire demandée par le programme est
alors trop importante.
