import { check } from 'k6';
import http from 'k6/http';
import { SharedArray } from 'k6/data';

export const options = {
  thresholds: {
    http_req_failed: ['rate<0.01'],    // http errors should be less than 1%
    http_req_duration: ['p(95)<100'], // 95% of requests should be below 100ms
  },
  scenarios: {
    my_scenario1: {
      executor: 'constant-arrival-rate',
      duration: '120s',       // total duration
      preAllocatedVUs: 100, // to allocate runtime resources
      rate: 1000,           // number of constant iterations given `timeUnit`
      timeUnit: '1s',
    },
  },
  discardResponseBodies: true,
  // executor: 'ramping-arrival-rate',
  // stages: [
  //   { duration: '120s', target: 10000 },
  // ]
};

const users = new SharedArray('pessoas.jsonl', function () {
  const lines = open('pessoas.jsonl').split('\n')
  const pessoas = [];

  for (const line of lines) {
    pessoas.push(line);
  }

  return pessoas;
});


export default function () {
  const user = users[~~(Math.random() * users.length)];

  const res = http.post('http://localhost:8080/pessoas', user, {
    headers: { 'Content-Type': 'application/json' }
  });

  check(res, {
    'status is 201 or 422': (r) => [201, 422].includes(res.status),
  });
}
