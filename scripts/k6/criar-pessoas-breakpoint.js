import { check, sleep } from 'k6';
import { SharedArray } from 'k6/data';
import exec from 'k6/execution';
import http from 'k6/http';

export const options = {
  thresholds: {
    http_req_duration: ['p(95)<100'],
  },
  scenarios: {
    finding_max_req_p95_100ms: {
      executor: 'ramping-arrival-rate',
      stages: [
        { duration: '10s', target: 1800 },
        { duration: '60s', target: 1800 },
      ],
      preAllocatedVUs: 1024,
      //               ^ Gargalo é o limite de `worker_connections` do nginx.
      //                 Não adianta aumentar o limite sem dar mais vcpu pro
      //                 nginx e eu não tenho mais de onde tirar vcpu.
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
