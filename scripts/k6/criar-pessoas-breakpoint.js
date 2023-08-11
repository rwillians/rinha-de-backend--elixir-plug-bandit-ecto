import { check } from 'k6';
import { SharedArray } from 'k6/data';
import exec from 'k6/execution';
import http from 'k6/http';

export const options = {
  thresholds: {
    http_req_duration: ['p(95)<2'],
  },
  scenarios: {
    finding_max_req_p95_100ms: {
      executor: 'ramping-arrival-rate',
      stages: [
        { duration: '10s', target: 1500 },
        { duration: '60s', target: 1500 },
      ],
      preAllocatedVUs: 5,
      //               ^ Gargalo é o limite de `worker_connections` do nginx.
      //                 Não adianta aumentar o limite sem dar mais vcpu pro
      //                 nginx e eu não tenho mais de onde tirar vcpu.
      //                 Se eu aumentar vcpu para o nginx aceitar mais conexões,
      //                 dai o tamanho tá poll de conexões das instâncias da
      //                 api para com o postgres se tornam insuficientes e
      //                 eu precisaria aumentar cpu para ambos.
      //                 Então vou aceitar o limite de 1024 conexões e buscar
      //                 o número máximo de req/s mantendo p95<100ms -- o qual,
      //                 no momento, aparenta ser 1800 req/s.
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
