function readJson(id) {
  const el = document.getElementById(id);
  if (!el) {
    console.error(`Missing JSON script tag: ${id}`);
    return [];
  }
  try {
    return JSON.parse(el.textContent);
  } catch (e) {
    console.error("JSON parse error:", e);
    console.log(el.textContent);
    return [];
  }
}

// static/charts.js
console.log("charts.js loaded ✅");

function readJson(id) {
  const el = document.getElementById(id);
  if (!el) {
    console.error(`Missing script tag #${id}`);
    return [];
  }
  const raw = (el.textContent || "").trim();
  if (!raw) {
    console.error(`Empty JSON in #${id}`);
    return [];
  }
  try {
    return JSON.parse(raw);
  } catch (e) {
    console.error(`JSON parse error in #${id}`, e);
    console.log("Raw:", raw);
    return [];
  }
}

document.addEventListener("DOMContentLoaded", () => {
  const byCountry = readJson("byCountry-data"); // [{country, revenue}, ...]
  const dailyData = readJson("daily-data"); // [{day, revenue}, ...]

  // ----- Revenue by Country -----
  const countryCanvas = document.getElementById("revenueByCountry");
  if (!countryCanvas) {
    console.error("Canvas #revenueByCountry not found");
  } else {
    const countryLabels = byCountry.map((r) => r.country ?? r.region);
    const countryValues = byCountry.map((r) => Number(r.revenue));

    new Chart(countryCanvas, {
      type: "bar",
      data: {
        labels: countryLabels,
        datasets: [{ label: "Revenue", data: countryValues }],
      },
      options: {
        responsive: true,
      },
    });
  }

  // ----- Revenue Over Time -----
  const dailyCanvas = document.getElementById("revenueDaily");
  if (!dailyCanvas) {
    console.error("Canvas #revenueDaily not found");
  } else {
    const dayLabels = dailyData.map((d) => d.date ?? d.day);

    const dayValues = dailyData.map((d) => Number(d.revenue));

    new Chart(dailyCanvas, {
      type: "line",
      data: {
        labels: dayLabels,
        datasets: [{ label: "Revenue", data: dayValues }],
      },
      options: {
        responsive: true,
      },
    });
  }
  // ----- Revenue Share (Pie Chart) -----
  const shareCanvas = document.getElementById("revenueShare");
  if (shareCanvas) {
    const byCountry = readJson("byCountry-data");
    console.log("By country data:", byCountry);
    const labels = byCountry.map((r) => r.country);
    const values = byCountry.map((r) => Number(r.revenue));

    new Chart(shareCanvas, {
      type: "doughnut", // use "pie" if you prefer
      data: {
        labels: labels,
        datasets: [
          {
            data: values,
            borderWidth: 1,
          },
        ],
      },
      options: {
        responsive: true,
        plugins: {
          legend: {
            position: "right",
          },
          tooltip: {
            callbacks: {
              label: function (context) {
                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                const value = context.raw;
                const pct = ((value / total) * 100).toFixed(1);
                return `${context.label}: ${value} (${pct}%)`;
              },
            },
          },
        },
      },
    });
  }
});
