import { check } from 'k6';
import { SharedArray } from 'k6/data';
import exec from 'k6/execution';
import http from 'k6/http';

export const options = {
  thresholds: {
    http_req_duration: ['p(95)<2'],
  },
  scenarios: {
    find_max_reqs_with_p95_under_100: {
      executor: 'ramping-arrival-rate',
      stages: [
        { duration: '10s', target: 2500 },
        { duration: '60s', target: 2500 },
      ],
      preAllocatedVUs: 256,
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
