
async function measurePingWS(wsUrl, runs=10) {
  return new Promise((resolve, reject) => {
    const ws = new WebSocket(wsUrl);
    const times = [];
    let sent = 0;
    ws.onopen = () => {
      const sendPing = () => {
        const client_ts = Date.now();
        ws.send(JSON.stringify({type: "ping", client_ts}));
        sent++;
        if (sent >= runs) {
          // wait for remaining pongs and then close; we'll collect results via onmessage
        } else {
          setTimeout(sendPing, 100);
        }
      };
      sendPing();
    };
    ws.onmessage = (ev) => {
      try {
        const data = JSON.parse(ev.data);
        if (data.type === 'pong' && data.server_ts) {
          const now = Date.now();
          // estimate RTT = now - recv_client_ts
          const rtt = now - (data.recv_client_ts || now);
          times.push(rtt);
        }
      } catch(e) {}
      if (times.length >= runs) {
        ws.close();
        times.sort((a,b)=>a-b);
        const median = times[Math.floor(times.length/2)];
        resolve(median);
      }
    };
    ws.onerror = (e) => {
      reject(e);
    };
    // timeout safety
    setTimeout(()=> {
      if (times.length === 0) reject(new Error("WS ping timed out"));
    }, 5000);
  });
}

async function measureDownloadStream(url, sizes=[2000000,5000000,10000000], onProgress) {
  let best = 0;
  for (let s of sizes) {
    const resp = await fetch(url.replace("{size}", s) + '?_=' + Math.random(), {cache: 'no-store'});
    if (!resp.ok) throw new Error("Download failed: " + resp.status);
    const reader = resp.body.getReader();
    let received = 0;
    let start = performance.now();
    while (true) {
      const {done, value} = await reader.read();
      if (done) break;
      received += value.length;
      const now = performance.now();
      const seconds = (now - start)/1000.0;
      const bits = received * 8;
      const mbps = bits / (seconds * 1_000_000);
      if (onProgress) onProgress({mbps, bytes: received, seconds});
    }
    const end = performance.now();
    const seconds = (end - start)/1000.0;
    const bits = received * 8;
    const mbps = bits / (seconds * 1_000_000);
    best = Math.max(best, mbps);
    await new Promise(r=>setTimeout(r, 150));
  }
  return best;
}

async function measureUpload(url, bytesTarget=5_000_000) {
  const chunk = new Uint8Array(1024*1024);
  for (let i=0;i<chunk.length;i++) chunk[i] = i & 0xff;
  const parts = [];
  let remaining = bytesTarget;
  while (remaining > 0) {
    parts.push(chunk.slice(0, Math.min(chunk.length, remaining)));
    remaining -= chunk.length;
  }
  const blob = new Blob(parts);
  const start = performance.now();
  const resp = await fetch(url + '?_=' + Math.random(), {method: 'POST', body: blob});
  const end = performance.now();
  if (!resp.ok) throw new Error("Upload failed");
  const secs = (end - start)/1000.0;
  const mbps = (bytesTarget * 8) / (secs * 1_000_000);
  return mbps;
}

// Chart setup
const ctx = document.getElementById('chart').getContext('2d');
const chart = new Chart(ctx, {
  type: 'line',
  data: {
    labels: [],
    datasets: [{
      label: 'Instantaneous Mbps',
      data: [],
      fill: false,
      tension: 0.2,
      pointRadius: 0
    }]
  },
  options: {
    responsive: true,
    scales: {
      x: { display: true, title: { display: true, text: 'Time' } },
      y: { display: true, title: { display: true, text: 'Mbps' }, suggestedMin: 0 }
    }
  }
});

function addChartPoint(label, value) {
  chart.data.labels.push(label);
  chart.data.datasets[0].data.push(value);
  if (chart.data.labels.length > 100) {
    chart.data.labels.shift();
    chart.data.datasets[0].data.shift();
  }
  chart.update('none');
}

document.getElementById('run').addEventListener('click', async () => {
  const pingEl = document.getElementById('ping');
  const dlEl = document.getElementById('download');
  const ulEl = document.getElementById('upload');
  const notes = document.getElementById('notes');
  pingEl.textContent = '…';
  dlEl.textContent = '…';
  ulEl.textContent = '…';
  notes.textContent = 'Running tests — allow a few seconds.';

  try {
    // WebSocket ping
    const wsProto = location.protocol === 'https:' ? 'wss' : 'ws';
    const wsUrl = wsProto + '://' + location.host + '/ws/ping/';
    notes.textContent = 'Measuring ping via WebSocket...';
    const ping = await measurePingWS(wsUrl, 8);
    pingEl.textContent = ping + ' ms';

    // Download with real-time updates to chart
    notes.textContent = 'Downloading and plotting throughput...';
    chart.data.labels = [];
    chart.data.datasets[0].data = [];
    chart.update();

    const onProgress = ({mbps, bytes, seconds}) => {
      const label = new Date().toLocaleTimeString();
      addChartPoint(label, mbps.toFixed(2));
    };

    const best = await measureDownloadStream('/download/{size}/', [2000000,5000000,10000000], onProgress);
    dlEl.textContent = best.toFixed(2);

    notes.textContent = 'Uploading ~5 MB...';
    const up = await measureUpload('/upload/', 5_000_000);
    ulEl.textContent = up.toFixed(2);

    notes.textContent = 'Done.';
  } catch (e) {
    console.error(e);
    document.getElementById('notes').textContent = 'Test failed: ' + e.message;
  }
});
