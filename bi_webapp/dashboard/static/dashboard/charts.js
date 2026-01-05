(function () {
  function readJsonScript(id) {
    const el = document.getElementById(id);
    if (!el) {
      console.error(`[charts] Missing JSON script tag: #${id}`);
      return [];
    }
    try {
      return JSON.parse(el.textContent || "[]");
    } catch (e) {
      console.error(`[charts] Failed to parse JSON in #${id}`, e);
      return [];
    }
  }

  // Ensure Chart.js is loaded
  if (typeof Chart === "undefined") {
    console.error("[charts] Chart.js is not loaded (Chart is undefined).");
    return;
  }

  const byCountry = readJsonScript("byCountry-data"); // [{country, revenue}, ...]
  const daily = readJsonScript("daily-data"); // [{date, revenue}, ...]

  // Helpers
  const toNumber = (v) => {
    const n = Number(v);
    return Number.isFinite(n) ? n : 0;
  };

  // ---- Chart 1: Revenue by Country (bar)
  const c1 = document.getElementById("revenueByCountry");
  if (c1) {
    const labels = byCountry.map((r) => r.country || "Unknown");
    const values = byCountry.map((r) => toNumber(r.revenue));

    new Chart(c1, {
      type: "bar",
      data: {
        labels,
        datasets: [{ label: "Revenue", data: values }],
      },
      options: {
        responsive: true,
        plugins: { legend: { display: false } },
      },
    });
  } else {
    console.error("[charts] Missing canvas #revenueByCountry");
  }

  // ---- Chart 2: Revenue share (pie)
  const c2 = document.getElementById("revenueShare");
  if (c2) {
    const labels = byCountry.map((r) => r.country || "Unknown");
    const values = byCountry.map((r) => toNumber(r.revenue));

    new Chart(c2, {
      type: "pie",
      data: {
        labels,
        datasets: [{ label: "Revenue share", data: values }],
      },
      options: { responsive: true },
    });
  } else {
    console.error("[charts] Missing canvas #revenueShare");
  }

  // ---- Chart 3: Revenue over time (line)
  const c3 = document.getElementById("revenueDaily");
  if (c3) {
    const labels = daily.map((r) => (r.date ? String(r.date) : ""));
    const values = daily.map((r) => toNumber(r.revenue));

    new Chart(c3, {
      type: "line",
      data: {
        labels,
        datasets: [{ label: "Revenue", data: values, tension: 0.25 }],
      },
      options: {
        responsive: true,
        plugins: { legend: { display: false } },
        scales: {
          x: { ticks: { maxRotation: 0 } },
        },
      },
    });
  } else {
    console.error("[charts] Missing canvas #revenueDaily");
  }

  console.log("[charts] Charts rendered successfully ✅");
})();
