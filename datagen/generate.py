#!/usr/bin/env python3
import argparse
import random
import uuid
from datetime import date, datetime, time, timedelta
from pathlib import Path

import pyarrow as pa
import pyarrow.parquet as pq
from faker import Faker

fake = Faker()

DEFAULT_OUTPUT_DIR = Path(__file__).resolve().parent.parent / "app" / "data-mesh"

CUSTOMERS_SCHEMA = pa.schema(
    [
        ("customer_id", pa.string()),
        ("name", pa.string()),
        ("created_at", pa.timestamp("us")),
    ]
)

TRANSACTIONS_SCHEMA = pa.schema(
    [
        ("transaction_id", pa.string()),
        ("customer_id", pa.string()),
        ("amount", pa.float64()),
        ("created_at", pa.timestamp("us")),
    ]
)


def random_time_on(day: date) -> datetime:
    return datetime.combine(
        day, time(hour=random.randint(0, 23), minute=random.randint(0, 59), second=random.randint(0, 59))
    )


def write_customers_batch(output_dir: Path, day: date, batch_size: int, customer_pool: list[str]) -> int:
    records = []
    for _ in range(batch_size):
        customer_id = str(uuid.uuid4())
        customer_pool.append(customer_id)
        records.append({"customer_id": customer_id, "name": fake.name(), "created_at": random_time_on(day)})

    table = pa.Table.from_pylist(records, schema=CUSTOMERS_SCHEMA)
    partition = output_dir / "sor_crm_customers" / f"ano={day.year}" / f"mes={day.month:02d}"
    partition.mkdir(parents=True, exist_ok=True)
    pq.write_table(table, partition / f"part-{uuid.uuid4().hex}.parquet")
    return len(records)


def write_transactions_day(output_dir: Path, day: date, count: int, customer_pool: list[str]) -> int:
    if not customer_pool:
        return 0

    records = [
        {
            "transaction_id": str(uuid.uuid4()),
            "customer_id": random.choice(customer_pool),
            "amount": round(random.uniform(5, 5000), 2),
            "created_at": random_time_on(day),
        }
        for _ in range(count)
    ]

    table = pa.Table.from_pylist(records, schema=TRANSACTIONS_SCHEMA)
    partition = (
        output_dir / "sor_financial_transactions" / f"ano={day.year}" / f"mes={day.month:02d}" / f"dia={day.day:02d}"
    )
    partition.mkdir(parents=True, exist_ok=True)
    pq.write_table(table, partition / f"part-{uuid.uuid4().hex}.parquet")
    return len(records)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Gera massa de dados (Parquet) do data mesh crm/payment")
    parser.add_argument("--start-date", type=date.fromisoformat, default=date.today())
    parser.add_argument("--days", type=int, default=90)
    parser.add_argument("--customers-per-batch", type=int, default=50)
    parser.add_argument("--customer-batch-interval-days", type=int, default=30)
    parser.add_argument("--tx-per-day-min", type=int, default=20)
    parser.add_argument("--tx-per-day-max", type=int, default=200)
    parser.add_argument("--output-dir", type=Path, default=DEFAULT_OUTPUT_DIR)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    customer_pool: list[str] = []
    total_customers = 0
    total_transactions = 0

    for i in range(args.days):
        day = args.start_date + timedelta(days=i)

        if i % args.customer_batch_interval_days == 0:
            total_customers += write_customers_batch(args.output_dir, day, args.customers_per_batch, customer_pool)

        tx_count = random.randint(args.tx_per_day_min, args.tx_per_day_max)
        total_transactions += write_transactions_day(args.output_dir, day, tx_count, customer_pool)

    print(f"dias simulados: {args.days} ({args.start_date} a {args.start_date + timedelta(days=args.days - 1)})")
    print(f"clientes gerados: {total_customers}")
    print(f"transações geradas: {total_transactions}")
    print(f"saída: {args.output_dir.resolve()}")


if __name__ == "__main__":
    main()
