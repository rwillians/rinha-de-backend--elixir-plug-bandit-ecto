import { check, sleep } from 'k6';
import { SharedArray } from 'k6/data';
import exec from 'k6/execution';
import http from 'k6/http';

export const options = {
  thresholds: {
    http_req_duration: ['p(95)<100'],
  },
  scenarios: {
    breakingpoint: {
      executor: 'ramping-arrival-rate',
      stages: [
        { duration: '5s', target: 1000 },
        { duration: '5s', target: 1700 },
        { duration: '110s', target: 20000 },
      ],
      preAllocatedVUs: 1024,
      startRate: 1
    },
  },
  discardResponseBodies: true,
};

const users = new SharedArray('pessoas.jsonl', function () {
  return open('pessoas.jsonl').split('\n');
});

export default function () {
  const user = users[exec.scenario.iterationInTest]; // 0, 1, 2, 3...

  const res = http.post('http://localhost:8080/pessoas', user, {
    headers: { 'Content-Type': 'application/json' }
  });

  check(res, {
    'status is 201 or 422': (res) => [201, 422].includes(res.status),
  });
}
