# Plinko — Defold Test Task

A small **Plinko** game prototype developed with **Defold Engine** and **Lua**.

The player drops metal balls into a pegboard and tries to land them in one of the baskets at the bottom. Each basket awards a configurable amount of points, while the probability of landing in each basket can be adjusted through configuration.

## 🎮 Features

### Core Gameplay

* Classic Plinko gameplay with a configurable number of baskets.
* Ball movement through the peg maze.
* Ability to drop a single ball.
* Ability to drop multiple balls simultaneously.
* Limited number of balls available to the player.
* Automatic ball regeneration over time.
* Configurable maximum number of balls that can be restored.
* Debug button for manually adding balls.

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
* Regeneration continues until the configured maximum is reached.
* The regeneration state is preserved between game sessions.

The debug interface also provides a way to manually add balls for testing purposes.

---

# ⚙️ Configuration

The main gameplay parameters are located in:

```text
scripts/config/game_config.lua
```

## Game Configuration

```lua
M.initial_balls = 10
M.maximum_balls = 10

M.regeneration = {
    interval = 30,
    balls_count = 1,
}

M.baskets = {
    { probability = 5, score = 10 },
    { probability = 4, score = 20 },
    { probability = 5, score = 30 },
    { probability = 3, score = 40 },
    { probability = 1, score = 50 },
    { probability = 1, score = 50 },
    { probability = 3, score = 40 },
    { probability = 5, score = 30 },
    { probability = 4, score = 20 },
    { probability = 5, score = 10 },
}
```

### Initial Ball Count

```lua
M.initial_balls = 10
```

Defines the number of balls the player starts with.

### Maximum Ball Count

```lua
M.maximum_balls = 10
```

Defines the maximum number of balls that can be restored through the regeneration system.

### Ball Regeneration

```lua
M.regeneration = {
    interval = 30,
    balls_count = 1,
}
```

* `interval` — time in seconds between regeneration events.
* `balls_count` — number of balls restored during each regeneration event.

### Basket Configuration

Each entry in `M.baskets` represents one basket.

```lua
{ probability = 5, score = 10 }
```

* `probability` — relative probability weight used when determining the target basket.
* `score` — number of points awarded when a ball lands in this basket.

The probability values are configured independently from the visual/physical board layout, allowing the gameplay balance to be adjusted without changing the gameplay code.

### Changing the Number of Baskets

The number of baskets is determined automatically by the number of entries in the `M.baskets` list.

To add or remove baskets, simply add or remove entries:

```lua
M.baskets = {
    { probability = 5, score = 10 },
    { probability = 4, score = 20 },
    { probability = 5, score = 30 },
}
```

The board and basket layout are generated according to the resulting number of configured baskets.

---

# 🏗️ Board Configuration

The visual and structural parameters of the Plinko board are located in:

```text
scripts/config/board_config.lua
```

Example:

```lua
M.rows = 9
M.width = 560
M.height = 780

M.origin = {
    x = 0.5,
    y = 0.8,
}

M.spawn = {
    y = 720,
}

M.peg = {
    spacing_x = 52,
    spacing_y = 56,
    scale = 1,
}

M.basket = {
    base_width = 64,
    base_y = 50,
    cover_ratio = 0.95,
}
```

This configuration is used by the board builder to generate the game board.

### Board Parameters

* `rows` — number of peg rows.
* `width` — window width used in case if we cannot get value from project properties.
* `height` — window height used in case if we cannot get value from project properties.
* `origin` — normalized board origin.
* `spawn.y` — vertical position where balls are spawned.
* `peg.spacing_x` — horizontal distance between pegs.
* `peg.spacing_y` — vertical distance between peg rows.
* `peg.scale` — peg scale.
* `basket.base_width` — base basket width.
* `basket.base_y` — vertical position of the baskets.
* `basket.cover_ratio` — amount of available horizontal space covered by the basket layout.

These values can be adjusted independently from the gameplay configuration.

---

# 💾 Save System

The game includes persistent game state saving as an additional task.

The following gameplay data is preserved between sessions:

* Current score.
* Current ball count.
* Playable ball count.
* Ball regeneration state.
* Basket hit statistics.

The save system stores the game state locally and restores it when the game starts.

The regeneration system uses an absolute end timestamp rather than storing only the remaining time. This allows the game to correctly calculate offline regeneration when the player returns after closing the application.

---

# 🐞 Debug Statistics

The game includes a debug statistics display for testing the basket probability distribution.

The debug information contains:

* Number of balls that landed in each basket.
* Total number of recorded hits.
* Current player score.
* Percentage of total hits for each basket.

The statistics are displayed using the Defold render system and are intended for development/testing purposes rather than as part of the player-facing UI.

---

# 🖥️ Interface

The game interface provides the following functionality:

* **Run button** — launches a single/multiple balls.
* **Add / Remove ball to next launch** — change amount of balls that weill be launcher on next Run button press.
* **Add +1 Ball** — manually increases the ball count to +1.
* **Add +10 Balls** — manually increases the ball count to +10.
* **Current Balls** — displays the current number of available balls, placed directly on Run butoon.
* **Recovery Timer** — displays the time remaining until the next ball/balls is restored.
* **Score** — displays the current player score.
* **Debug render.draw_text** — used to display debug information

---

# ✅ Implemented Requirements

The following requirements from the task are implemented:

* [x] Classic Plinko gameplay.
* [x] Pegboard with configurable baskets.
* [x] Ball movement through the peg maze.
* [x] Configurable basket probability distribution.
* [x] Configurable score for each basket.
* [x] 10 baskets by default.
* [x] Limited player ball inventory.
* [x] Automatic ball regeneration.
* [x] Configurable regeneration interval.
* [x] Configurable maximum number of regenerable balls.
* [x] Single-ball launch.
* [x] Multiple-ball launch.
* [x] Debug button for manually adding balls.
* [x] Current ball count display.
* [x] Recovery timer display.
* [x] Score display.
* [x] Basket hit statistics.
* [x] Hit percentage statistics.
* [x] Persistent game state saving/loading.
* [x] Configurable number of baskets.

All additional tasks specified in the technical assignment have also been implemented.
