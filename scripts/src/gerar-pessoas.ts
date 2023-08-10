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
  null
]

const STACK_LENGTH = STACK.length;

function rand() {
  return (~~(Math.random() * 10)).toString();
}

function pessoa() {
  const bday = faker.date.birthdate();
  const year = bday.getUTCFullYear();
  const month = (bday.getUTCMonth() + 1).toString().padStart(2, '0');
  const day = bday.getUTCDate().toString().padStart(2, '0');

  return {
    nome: faker.person.fullName(),
    apelido: faker.internet.userName() + rand(),
    data_nascimento: `${year}-${month}-${day}`,
    stack: STACK[~~(Math.random() * STACK_LENGTH)]
  }
}

for (let i = 0; i < 500_000; i++) {
  process.stdout.write(JSON.stringify(pessoa()) + '\n');
}
