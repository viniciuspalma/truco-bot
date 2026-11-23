# Truco Bot

A rules engine for Argentine Truco, the base for a Slack bot where you play
against an AI or against someone else in your org.

The engine is a plain Ruby library with no dependencies. It knows the rules and
nothing about Slack: callers ask it whose turn it is and which moves are legal,
then hand one of those moves back.

## Rules implemented

1v1 Argentine Truco with the 40-card Spanish deck.

- **Cards**, strongest first: 1 of swords, 1 of clubs, 7 of swords, 7 of golds,
  the 3s, the 2s, 1 of golds and cups, 12s, 11s, 10s, 7 of cups and clubs, 6s,
  5s, 4s. Cards on the same step tie (parda).
- **Hands** are best of three tricks. The mano (the player who did not deal)
  leads the first trick, and whoever wins a trick leads the next. After a tie,
  the first trick someone won decides the hand. If every trick ties, the mano
  wins. The deal passes to the other player after each hand.
- **Truco**: the hand is worth 1 point, then 2 (Truco), 3 (Retruco) or 4 (Vale
  Cuatro) once each call is accepted. Declining pays the caller the value
  already accepted. Only the player who accepted the last call can raise, and a
  raise can be the answer to a call ("quiero retruco").
- **Envido**: Envido (2), Envido (2), Real Envido (3) and Falta Envido, in that
  order, during the first trick before the player lays a card and before any
  Truco is accepted. Accepted, the chain pays its sum (or the Falta); declined,
  it pays what it was worth before the last call, or 1. The best count wins and
  ties go to the mano. Envido can be called over an unanswered opening Truco
  (el envido está primero), and the Truco waits.
- **Falta Envido** and **Contraflor al Resto** are worth what the leader still
  needs to reach the target score.
- **Flor** (off by default): three cards of one suit. Whoever holds it sings it
  instead of Envido, which then disappears for the hand. It scores 3 against an
  opponent without Flor. An opponent with Flor answers Contraflor (6 to the best
  Flor), Contraflor al Resto, or Con Flor Me Achico (4 to the singer).
- **Ir al mazo**: going to the deck gives the opponent what the hand is worth.
- **Scoring**: the match is played to 30 (configurable). It ends the moment
  someone reaches the target, even in the middle of a hand.

## Usage

```ruby
require 'trucobot'
include TrucoBot::Game

alice = Player.new(id: 'U01ALICE', name: 'Alice')
bob   = Player.new(id: 'U02BOB', name: 'Bob')
match = Match.new(players: [alice, bob], rules: Rules.new(target_score: 30, flor: false))

match.actor                   # => alice (who must move now)
match.allowed_actions(alice)  # => every legal Action: card plays, :truco, :envido, ..., :al_mazo
match.act(alice, :truco)
match.act(bob, :quiero)
match.act(alice, :play_card, match.hand.cards_of(alice).first)

match.view(bob)               # what Bob may see: his cards, the table, scores, his options
match.events                  # what happened, for narrating the game
match.finished?               # => false until someone reaches 30
```

An illegal move raises `TrucoBot::IllegalAction`. Pass `random:` to `Match.new`
for reproducible shuffles, or `deal:` to choose the cards.

## Development

The dev shell comes from the flake and pins Ruby 4.0:

```sh
nix develop            # or `use flake` with direnv
bundle install         # gems go to ./.gems
bundle exec rake       # RuboCop and the specs
bin/console            # IRB with the gem loaded
```

CI runs the same commands through `nix develop .#github` on every pull request.
