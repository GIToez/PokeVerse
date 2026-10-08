# data/spells/scripts/

Intentionally empty. `spells.xml` references move scripts as
`scripts/../../lib/ps/events/spells/scripts/<Move>.lua`; Linux only resolves
that path if this folder exists. The real scripts live in
`data/lib/ps/events/spells/scripts/`.
