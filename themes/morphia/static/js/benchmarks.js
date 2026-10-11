/* ============================================================
   Mapper benchmark history charts
   Reads the benchmark history (github-action-benchmark's data from the
   morphia repo's benchmark-data branch, inlined into the page at build time)
   and draws one line chart per benchmark, with one line per mapper variant.
   Every string from the data goes into the page as text, never as markup.
   ============================================================ */
(function () {
  'use strict';

  var container = document.getElementById('bench-charts');
  if (!container || !window.Chart) return;

  // Fixed variant -> color assignment (validated for CVD separation on the paper surface).
  var COLORS = {
    'reflection': '#b85c10',
    'critter': '#008c84',
    'critter-runtime': '#7d4aa6'
  };
  var INK = '#14110d';
  var INK_MUTED = '#5a5247';
  var INK_FAINT = '#5a5247';
  var RULE = 'rgba(20,17,13,0.10)';
  var PAPER = '#fbf9f3';
  var MONO = "'JetBrains Mono', ui-monospace, SFMono-Regular, Menlo, monospace";

  var SHA = /^[0-9a-f]{40}$/;
  var variants = (container.dataset.variants || 'reflection,critter,critter-runtime').split(',');

  // "dev.morphia.benchmarks.CodecBenchmark.decode ( {"model":"SIMPLE","variant":"critter"} )"
  //   -> { key: "CodecBenchmark.decode | SIMPLE", variant: "critter" }
  function parseName(name) {
    var split = name.indexOf(' ( ');
    var method = split < 0 ? name : name.substring(0, split);
    var label = method.split('.').slice(-2).join('.');
    var variant = null;
    var params = [];
    if (split >= 0) {
      try {
        var parsed = JSON.parse(name.substring(split + 3, name.lastIndexOf(' )')));
        Object.keys(parsed).sort().forEach(function (k) {
          if (k === 'variant') variant = parsed[k];
          else params.push(parsed[k]);
        });
      } catch (e) { /* unparseable params: fall back to the bare method name */ }
    }
    return { key: params.length ? label + ' | ' + params.join(', ') : label, variant: variant };
  }

  function showMessage(text) {
    var p = document.createElement('p');
    p.className = 'bench-meta';
    p.textContent = text;
    container.appendChild(p);
  }

  try {
    var source = document.getElementById('bench-data');
    var data = JSON.parse(source ? source.textContent : 'null');
    if (!data || typeof data.entries !== 'object' || data.entries === null) throw new Error('unexpected data');
    render(data);
  } catch (e) {
    showMessage('The benchmark history could not be loaded; the table above shows the latest run.');
  }

  function render(data) {
    // Collect every commit measured (in run order) and every value per benchmark/variant/commit.
    var commits = [];
    var commitIndex = Object.create(null);
    var groups = Object.create(null);
    var groupOrder = [];

    variants.forEach(function (variant) {
      var runs = data.entries['Mapper: ' + variant];
      (Array.isArray(runs) ? runs : []).forEach(function (run) {
        var id = run && run.commit && run.commit.id;
        if (typeof id !== 'string' || !SHA.test(id) || !Array.isArray(run.benches)) return;
        if (!(id in commitIndex)) {
          commitIndex[id] = commits.length;
          commits.push({
            id: id,
            url: 'https://github.com/MorphiaOrg/morphia/commit/' + id,
            date: new Date(run.date),
            message: String(run.commit.message || '').split('\n')[0]
          });
        }
        run.benches.forEach(function (bench) {
          if (!bench || typeof bench.name !== 'string' || typeof bench.value !== 'number') return;
          var parsed = parseName(bench.name);
          var group = groups[parsed.key];
          if (!group) {
            group = groups[parsed.key] = { unit: String(bench.unit || ''), values: Object.create(null) };
            groupOrder.push(parsed.key);
          }
          (group.values[variant] = group.values[variant] || Object.create(null))[id] = bench.value;
        });
      });
    });

    if (!groupOrder.length) {
      showMessage('No benchmark history has been recorded yet.');
      return;
    }

    commits.sort(function (a, b) { return a.date - b.date; });

    function shortDate(d) {
      return d.toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
    }

    function format(v) {
      if (v == null) return '—';
      return v >= 100 ? v.toFixed(0) : v >= 10 ? v.toFixed(1) : v.toFixed(2);
    }

    // Names each line at its last point so identity never depends on color alone.
    var endLabels = {
      id: 'endLabels',
      afterDatasetsDraw: function (chart) {
        var ctx = chart.ctx;
        ctx.save();
        ctx.font = '500 11px ' + MONO;
        ctx.textBaseline = 'middle';
        var labels = [];
        chart.data.datasets.forEach(function (ds, i) {
          var meta = chart.getDatasetMeta(i);
          if (meta.hidden) return;
          for (var p = meta.data.length - 1; p >= 0; p--) {
            if (ds.data[p] == null) continue;
            labels.push({ text: ds.label, x: meta.data[p].x, y: meta.data[p].y });
            break;
          }
        });
        // spread labels apart top to bottom when lines end close together
        labels.sort(function (a, b) { return a.y - b.y; });
        for (var i = 1; i < labels.length; i++) {
          labels[i].y = Math.max(labels[i].y, labels[i - 1].y + 13);
        }
        ctx.fillStyle = INK_MUTED;
        labels.forEach(function (l) { ctx.fillText(l.text, l.x + 10, l.y); });
        ctx.restore();
      }
    };

    Chart.defaults.font.family = MONO;
    Chart.defaults.font.size = 11;
    Chart.defaults.color = INK_MUTED;

    groupOrder.forEach(function (key) {
      var group = groups[key];

      var figure = document.createElement('figure');
      figure.className = 'bench-chart';
      var caption = document.createElement('figcaption');
      var title = document.createElement('code');
      title.textContent = key;
      var unit = document.createElement('span');
      unit.className = 'bench-unit';
      unit.textContent = group.unit + ', lower is better';
      caption.appendChild(title);
      caption.appendChild(unit);
      var canvasWrap = document.createElement('div');
      canvasWrap.className = 'bench-canvas';
      var canvas = document.createElement('canvas');
      canvas.setAttribute('role', 'img');
      canvas.setAttribute('aria-label', key + ' in ' + group.unit + ' per commit, by mapper variant');
      canvasWrap.appendChild(canvas);
      figure.appendChild(caption);
      figure.appendChild(canvasWrap);
      container.appendChild(figure);

      var datasets = variants.filter(function (v) { return group.values[v]; }).map(function (variant) {
        return {
          label: variant,
          data: commits.map(function (c) { var v = group.values[variant][c.id]; return v == null ? null : v; }),
          borderColor: COLORS[variant] || INK,
          backgroundColor: COLORS[variant] || INK,
          borderWidth: 2,
          pointRadius: 4,
          pointHoverRadius: 6,
          pointBorderColor: PAPER,
          pointBorderWidth: 2,
          pointHitRadius: 12,
          spanGaps: true,
          tension: 0
        };
      });

      new Chart(canvas, {
        type: 'line',
        data: {
          labels: commits.map(function (c) { return c.id.substring(0, 7); }),
          datasets: datasets
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          animation: false,
          layout: { padding: { right: 112, top: 8 } },
          interaction: { mode: 'index', intersect: false },
          scales: {
            x: {
              grid: { display: false },
              border: { color: RULE },
              ticks: {
                color: INK_FAINT,
                maxRotation: 0,
                autoSkip: true,
                callback: function (value, index) {
                  var c = commits[index];
                  return [c.id.substring(0, 7), shortDate(c.date)];
                }
              }
            },
            y: {
              beginAtZero: true,
              grid: { color: RULE },
              border: { display: false },
              ticks: { color: INK_FAINT, maxTicksLimit: 6 },
              title: { display: true, text: group.unit, color: INK_FAINT }
            }
          },
          plugins: {
            legend: {
              position: 'top',
              align: 'start',
              labels: { usePointStyle: true, pointStyle: 'circle', boxWidth: 8, boxHeight: 8, color: INK_MUTED, padding: 14 }
            },
            tooltip: {
              backgroundColor: PAPER,
              borderColor: 'rgba(20,17,13,0.18)',
              borderWidth: 1,
              titleColor: INK,
              bodyColor: INK_MUTED,
              footerColor: INK_FAINT,
              titleFont: { family: MONO, weight: '500' },
              footerFont: { family: MONO, weight: '400', size: 10 },
              padding: 10,
              usePointStyle: true,
              boxWidth: 8,
              boxHeight: 8,
              callbacks: {
                title: function (items) {
                  var c = commits[items[0].dataIndex];
                  return c.id.substring(0, 7) + ' · ' + c.date.toLocaleDateString();
                },
                label: function (item) {
                  return ' ' + item.dataset.label + ': ' + format(item.raw) + ' ' + group.unit;
                },
                footer: function (items) {
                  var msg = commits[items[0].dataIndex].message;
                  return msg.length > 60 ? msg.substring(0, 57) + '…' : msg;
                }
              }
            }
          },
          onClick: function (evt, elements) {
            if (elements.length) window.open(commits[elements[0].index].url, '_blank', 'noopener');
          }
        },
        plugins: [endLabels]
      });
    });
  }
})();
