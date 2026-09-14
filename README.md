# Plinko — Defold Test Task

A small **Plinko** game prototype developed with **Defold Engine** and **Lua**.

The player drops metal balls into a pegboard and tries to land them in one of the baskets at the bottom. Each basket awards a configurable amount of points, while the probability of landing in each basket can be adjusted through configuration.

## 🎮 Features

### Core Gameplay

* Classic Plinko gameplay with a pegboard and **10 baskets**.
* Physics-based ball movement through the peg maze.
* Ability to drop a single ball.
* Ability to drop multiple balls simultaneously.
* Limited number of balls available to the player.
* Automatic ball regeneration over time.
* Configurable maximum number of balls that can be restored.
* Debug button for manually adding balls.

### Configuration

The following gameplay parameters are configurable:

* Initial number of balls.
* Ball regeneration interval.
* Maximum number of regenerable balls.
* Probability of landing in each basket.
* Score awarded by each basket.
* Number of baskets.

The probability distribution is intentionally configurable separately from the physical simulation, allowing the desired gameplay balance to be adjusted without modifying gameplay code.

> Configuration details and exact file locations will be added after the implementation is finalized.

### Scoring

Each basket has its own configurable score value.

When a ball reaches a basket:

1. The corresponding basket is identified.
2. The player's score is increased according to the basket configuration.
3. The basket hit statistics are updated.

### Ball Regeneration

The player has a limited ball inventory.

When a ball is used:

* The inventory decreases by one.
* A regeneration timer starts or continues counting down.
* After the configured interval, a new ball is added.
* Regeneration stops when the configured limit is reached.

The debug interface also provides a way to manually add balls for testing purposes.
