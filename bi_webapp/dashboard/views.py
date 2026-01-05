from django.shortcuts import render, redirect
from django.contrib import messages
from django.db import connection

from decimal import Decimal
from datetime import date, datetime
import json
import csv
import io

from .forms import UploadCSVForm


# ---------------------------
# Helpers
# ---------------------------
def _json_default(o):
    """Convert Decimal/dates to JSON-safe values."""
    if isinstance(o, Decimal):
        return float(o)
    if isinstance(o, (date, datetime)):
        return o.isoformat()
    return str(o)


def fetch_all(sql: str, params=None):
    """Run a SQL query and return list of dict rows."""
    with connection.cursor() as cursor:
        cursor.execute(sql, params or [])
        cols = [col[0] for col in cursor.description]
        return [dict(zip(cols, row)) for row in cursor.fetchall()]


def fetch_one_value(sql: str, col_name: str):
    """Run a SQL query expected to return 1 row and return one column."""
    rows = fetch_all(sql)
    if not rows:
        return 0
    return rows[0].get(col_name, 0)


# ---------------------------
# Dashboard view
# ---------------------------
def index(request):
    # KPIs from uploaded data (staging_sales)
    total_revenue = fetch_one_value(
        "SELECT COALESCE(SUM(revenue), 0) AS total_revenue FROM staging_sales;",
        "total_revenue",
    )

    orders = fetch_one_value(
        "SELECT COUNT(DISTINCT order_id) AS orders FROM staging_sales;",
        "orders",
    )

    aov = fetch_one_value(
        """
        SELECT COALESCE(
            SUM(revenue) / NULLIF(COUNT(DISTINCT order_id), 0),
            0
        ) AS aov
        FROM staging_sales;
        """,
        "aov",
    )

    by_country_rows = fetch_all(
        """
        SELECT country, SUM(revenue) AS revenue
        FROM staging_sales
        GROUP BY country
        ORDER BY revenue DESC;
        """
    )

    daily_rows = fetch_all(
        """
        SELECT order_date::date AS date, SUM(revenue) AS revenue
        FROM staging_sales
        GROUP BY order_date::date
        ORDER BY date;
        """
    )

    context = {
        "total_revenue": total_revenue,
        "orders": orders,
        "aov": aov,
        "by_country_json": json.dumps(by_country_rows, default=_json_default),
        "daily_json": json.dumps(daily_rows, default=_json_default),
    }

    return render(request, "dashboard/index.html", context)


# ---------------------------
# Upload view
# ---------------------------
REQUIRED_COLUMNS = {
    "order_id",
    "order_date",
    "customer_name",
    "country",
    "product_name",
    "quantity",
    "revenue",
}


def upload_dataset(request):
    if request.method == "POST":
        form = UploadCSVForm(request.POST, request.FILES)

        if not form.is_valid():
            messages.error(request, f"Form invalid: {form.errors}")
            return render(request, "dashboard/upload.html", {"form": form})

        uploaded_file = form.cleaned_data["file"]
        if not uploaded_file.name.lower().endswith(".csv"):
            messages.error(request, "Please upload a CSV file.")
            return render(request, "dashboard/upload.html", {"form": form})

        # Read bytes -> decode -> normalize newlines
        raw_bytes = uploaded_file.read()
        text = raw_bytes.decode("utf-8-sig", errors="replace")  # handles BOM
        text = text.replace("\r\n", "\n").replace("\r", "\n")   # normalize line endings

        # ✅ Correct CSV parsing: consume header row once
        f = io.StringIO(text)
        raw_reader = csv.reader(f)

        try:
            raw_headers = next(raw_reader)  # consume header line
        except StopIteration:
            messages.error(request, "CSV is empty.")
            return render(request, "dashboard/upload.html", {"form": form})

        headers = [h.strip() for h in raw_headers]
        missing = REQUIRED_COLUMNS - set(headers)
        if missing:
            messages.error(request, f"Missing columns: {', '.join(sorted(missing))}")
            return render(request, "dashboard/upload.html", {"form": form})

        # DictReader will read ONLY the remaining data rows
        reader = csv.DictReader(f, fieldnames=headers)

        rows_read = 0
        rows_inserted = 0

        try:
            with connection.cursor() as cur:
                # Replace dataset each upload (only after validation succeeded)
                cur.execute("TRUNCATE TABLE staging_sales;")

                for row in reader:
                    rows_read += 1

                    order_id = (row.get("order_id") or "").strip()
                    order_date = (row.get("order_date") or "").strip()
                    customer_name = (row.get("customer_name") or "").strip()
                    country = (row.get("country") or "").strip()
                    product_name = (row.get("product_name") or "").strip()

                    # skip blank lines
                    if not order_id or not order_date:
                        continue

                    try:
                        quantity = int((row.get("quantity") or "0").strip())
                        revenue = float((row.get("revenue") or "0").strip())
                    except ValueError as e:
                        raise ValueError(
                            f"Bad number format (quantity/revenue) on CSV data row {rows_read}: {e}"
                        )

                    cur.execute(
                        """
                        INSERT INTO staging_sales
                        (order_id, order_date, customer_name, country, product_name, quantity, revenue)
                        VALUES (%s, %s, %s, %s, %s, %s, %s)
                        """,
                        [order_id, order_date, customer_name, country, product_name, quantity, revenue],
                    )
                    rows_inserted += 1

                # Confirm count in DB
                cur.execute("SELECT COUNT(*) FROM staging_sales;")
                count = cur.fetchone()[0]

        except Exception as e:
            messages.error(request, f"Upload failed: {e}")
            return render(request, "dashboard/upload.html", {"form": form})

        messages.success(
            request,
            f"Upload successful ✅ Rows read: {rows_read}, inserted: {rows_inserted}, in DB: {count}",
        )
        return redirect("index")

    # GET request
    form = UploadCSVForm()
    return render(request, "dashboard/upload.html", {"form": form})
def home(request):
    return render(request, "dashboard/home.html")