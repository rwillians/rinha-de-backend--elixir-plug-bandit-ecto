import { faker } from '@faker-js/faker';

const STACK = [
  ["JS", "TS", "Node", "MongoDB"],
  ["JS", "TS", "Node", "MySQL"],
  ["PHP", "Laravel", "MySQL", "Redis"],
  ["JS", "TS", "Bun", "MySQL"],
  ["TS", "Bun", "SQLite"],
  ["Elixir", "PostgreSQL"],
  ["Erlang", "PostgreSQL"],
  ["C#", "SQLServer"],
  []
]

const STACK_LENGTH = STACK.length;

function terms() {
  return [faker.internet.userName(), ... STACK[~~(Math.random() * STACK_LENGTH)]]
}

for (let i = 0; i < 10_000; i++) {
  for (const term of terms()) {
    process.stdout.write(term + '\n');
  }
}
