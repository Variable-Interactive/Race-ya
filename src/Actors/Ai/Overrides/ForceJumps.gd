extends CharacterBody2D

# Usually the Ai is smart enousg to jump on its own but sometimes we may
# have to override its jump system

# Ai will jump as soon as it passes above it

# Jump if Ai is moving from
# Left ---> Right,
# Right ---> Left,
# or Both
@export var jump_if_ai_moves = 0 # (int, "Left to Right", "Right to Left", "Both")
