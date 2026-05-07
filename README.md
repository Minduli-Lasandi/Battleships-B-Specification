# Battleships

A formal specification of the Battleships board game, written in **B (Abstract Machine Notation/Formal method)**. Built as part of a Formal Methods module using **Atelier B** and **ProB**.

## What is B?

B is a formal method used to model and verify software systems mathematically. Instead of writing code, you write a *specification* that describes what a system does using set theory and predicate logic. Tools like **Atelier B** check the specification for correctness and **ProB** lets you animate and simulate it.

## Project Structure

```
├── Battleships_Ctx.mch   # Constants, sets, and types (grid, players, orientations, reports)
├── Fleet.mch             # Ship placement logic for both players
├── Battleships.mch       # Main machine: game state, shooting logic, and enquiry operations
└── .gitignore
```

## Game Rules

- 10x10 grid
- Each player has 3 ships:
  - **Submarine** — 1 square
  - **Destroyer** — 2 squares (horizontal or vertical)
  - **Cruiser** — 3 squares (horizontal or vertical)
- Ships must be placed in order: Submarine → Destroyer → Cruiser
- Once both players have placed all ships, the shooting phase begins (Player 1 goes first)
- First player to sink all of their opponent's ships wins

## Operations

### Deployment
| Operation | Description |
|---|---|
| `DeploySubMarine(player, row, col)` | Places the submarine at a single square |
| `DeployDestroyer(player, row, col, orientation)` | Places the destroyer across 2 squares |
| `DeployCruiser(player, row, col, orientation)` | Places the cruiser across 3 squares |

### Gameplay
| Operation | Description |
|---|---|
| `Shoot(player, target)` | Shoot at a square — returns `HIT`, `MISS`, `SUNK`, `P1_WIN`, or `P2_WIN` |

### Enquiry
| Operation | Description |
|---|---|
| `LocationOfShips(player)` | Returns all squares occupied by a player's fleet |
| `ShipsLeft(player)` | Returns how many ships the player still has afloat |
| `ShotsTaken(player)` | Returns the total number of shots fired by the player |
| `GameState` | Returns the current game state (`setting_up`, `playing`, `p1_win`, `p2_win`) |

## Tools

- [Atelier B](https://www.atelierb.eu/en/) — for type checking and proof obligations
- [ProB](https://prob.hhu.de/w/index.php/ProB) — for animation and model checking
