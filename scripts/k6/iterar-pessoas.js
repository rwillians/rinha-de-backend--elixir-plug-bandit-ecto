import { check } from 'k6';
import http from 'k6/http';
import { SharedArray } from 'k6/data';

export const options = {
  thresholds: {
    http_req_failed: ['rate<0.01'],    // http errors should be less than 1%
    http_req_duration: ['p(95)<100'], // 95% of requests should be below 100ms
  },
  scenarios: {
    // sustained_workload: {
    //   executor: 'constant-arrival-rate',
    //   duration: '120s',      // total duration
    //   preAllocatedVUs: 500, // to allocate runtime resources
    //   rate: 500,           // number of constant iterations given `timeUnit`
    //   timeUnit: '1s',
    // },
    find_breaking_point: {
      executor: 'ramping-arrival-rate',
      preAllocatedVUs: 500,
      maxVUs: 1000,
      stages: [
        { duration: '30s', target: 500 },
        { duration: '90s', target: 1000 },
        // ramping up the number of req/s untill 1000 req/s
        // over a couse of 2 minutes
      ]
    }
  },
  discardResponseBodies: true,
};

const pages = new SharedArray('pages.jsonl', function () {
  const xs = [];

  for (const page_no = 0; i < 250_000; page_no++) {
    xs.push(page_no);
  }

  return xs;
})

export default function () {
  const page_no = pages.shift();

  const res = http.get(`http://localhost:8080/pessoas?page=${page_no}&limite=1`, {
    tags: { name: 'http://localhost:8080/pessoas?page=${n}&limit1' },
  });

  check(res, {
    'status is 200': (r) => res.status === 200,
  });
}
