import { check } from 'k6';
import { SharedArray } from 'k6/data';
import exec from 'k6/execution';
import http from 'k6/http';

export const options = {
  thresholds: {
    http_req_failed: ['rate<0.01'],    // http errors should be less than 1%
    http_req_duration: ['p(95)<200'], // 95% of requests should be below 200ms
  },
  scenarios: {
    find_breaking_point: {
      executor: 'ramping-arrival-rate',
      stages: [
        { duration: '30s', target: 500 },
        { duration: '30s', target: 1000 },
        { duration: '60s', target: 1500 },
        { duration: '10s', target: 1600 },
        { duration: '30s', target: 1600 },
        { duration: '60s', target: 2000 },
      ],
      preAllocatedVUs: 500,
      maxVUs: 3000,
      startRate: 1,
      timeUnit: '1s'
    },
  },
  // discardResponseBodies: true,
};

const pages = new SharedArray('pages.jsonl', function () {
  const xs = [];

  for (let page_no = 0; page_no < 200000; page_no++) {
    xs.push(page_no);
  }

  return xs;
})

export default function () {
  const page_no = pages[exec.scenario.iterationInTest];

  const res1 = http.get(`http://localhost:8080/pessoas?page=${page_no}&limite=1`, {
    tags: { name: 'http://localhost:8080/pessoas?page=${n}&limit1' },
  });

  check(res1, {
    'results page has status 200': (r) => r.status === 200,
  });

  const id = JSON.parse(res1.body).resultados[0].id

  const res2 = http.get(`http://localhost:8080/pessoas/${id}`, {
    tags: { name: 'http://localhost:8080/pessoas/:id' },
  })

  check(res2, {
    'status is 200': (r) => r.status === 200,
  })
}
