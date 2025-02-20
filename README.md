# Orb Swapper Puzzle Game

The game consists of 10 rows and 10 columns of orbs of different styles: purple '+', blue '-', and orange 'o'.
Orbs can be swapped in fixed patterns, shown by the lines connecting the different orbs.
A purple orb can swap with an orange orb in the adjacent column below it, an orange orb can swap with a blue orb below it, and a blue with a purple orb below it.
Orbs are swapped by either clicking on two connected orbs, or by dragging an orb across a set of orbs.

Every 10 seconds  (indicated by a rising bar on the right) or if the user presses Space Bar, the right-most column of orbs is removed from the game and counted, with a new column coming in from the left.
Purple orbs with a '+' add one to the count, while blue orbs with '-' remove one from the count. Orange orbs are neutral and do not effect the count.
If the count is negative the column moves downward and is ignored. If the count is positive, the column moves upward count is added to the running score.

After 10 rounds, the game ends and the final score is shown.

Available to play at: https://akkamath.github.io/web/orb_swap.html

<img width="1438" alt="Screenshot 2025-01-08 at 8 01 30 PM" src="https://github.com/user-attachments/assets/9b34deb4-65d4-40f0-bf42-40edcc428948" />


Written using [Godot v4.3](https://godotengine.org/), the open-source game engine.
