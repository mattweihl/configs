# Examples

Use these only when the preferred pattern is ambiguous in the current language.

## Early Return Over Nested Branches

TypeScript:

```ts
const getDiscount = (price: number, tier: 'gold' | 'silver' | 'none'): number => {
  if (price <= 0) {
    return 0;
  }
  if (tier === 'gold') {
    return price * 0.8;
  }
  if (tier === 'silver') {
    return price * 0.9;
  }
  return price;
};
```

Python:

```python
def get_discount(price: float, tier: str) -> float:
    if price <= 0:
        return 0
    if tier == "gold":
        return price * 0.8
    if tier == "silver":
        return price * 0.9
    return price
```

## Avoid Boolean Arguments

TypeScript (prefer `as const` object over native `enum`):

```ts
const REPORT_FORMAT = {
  summary: 'summary',
  detailed: 'detailed',
} as const;

type ReportFormat = (typeof REPORT_FORMAT)[keyof typeof REPORT_FORMAT];

const renderReport = (data: ReportData, format: ReportFormat): ReportResult => {
  if (format === REPORT_FORMAT.summary) {
    return buildSummary(data);
  }
  return buildDetailed(data);
};
```

Python (`Enum`):

```python
from enum import Enum

class ReportFormat(str, Enum):
    SUMMARY = "summary"
    DETAILED = "detailed"

def render_report(data: ReportData, format: ReportFormat) -> ReportResult:
    if format == ReportFormat.SUMMARY:
        return build_summary(data)
    return build_detailed(data)
```

Java (`enum`):

```java
enum ReportFormat { SUMMARY, DETAILED }

ReportResult renderReport(ReportData data, ReportFormat format) {
  if (format == ReportFormat.SUMMARY) {
    return buildSummary(data);
  }
  return buildDetailed(data);
}
```

Go (typed constants):

```go
type ReportFormat string

const (
  ReportSummary ReportFormat = "summary"
  ReportDetailed ReportFormat = "detailed"
)

func RenderReport(data ReportData, format ReportFormat) ReportResult {
  if format == ReportSummary {
    return BuildSummary(data)
  }
  return BuildDetailed(data)
}
```

When callers already know the format, they can call `buildSummary` or `buildDetailed` directly.

## Group Related Parameters

These fields form one creation request. Parameter count alone does not require a wrapper.

Go:

```go
type CreateUserInput struct {
    Name  string
    Email string
    Role  string
    Team  string
}
```

```go
func CreateUser(input CreateUserInput) error {
    // ...
    return nil
}
```

## String Construction

Java (accumulation):

```java
StringBuilder builder = new StringBuilder();
for (Order order : orders) {
  builder.append(order.id()).append(": ").append(order.status()).append("\n");
}
String output = builder.toString();
```

JavaScript (accumulation):

```ts
const output = orders.map((order) => `${order.id}: ${order.status}`).join('\n');
```

## Constants for Meaning

Good:

```ts
const MAX_RETRY_ATTEMPTS = 3;
if (attempts >= MAX_RETRY_ATTEMPTS) {
  throw new Error('Retries exhausted');
}
```

Also good for obvious values:

```ts
if (items.length === 0) {
  return [];
}
```

## Local Mutation and a Single Pass

TypeScript:

```ts
type LineItem = {
  isActive: boolean;
  amountCents: number;
};

const totalActiveCents = (items: readonly LineItem[]): number => {
  let totalCents = 0;
  for (const item of items) {
    if (!item.isActive) {
      continue;
    }
    totalCents += item.amountCents;
  }
  return totalCents;
};
```

The function preserves its inputs. The local accumulator makes the calculation visible in one place.
Keep this operation together; the loop does not need a helper for each step.

## Keep Related Work Together

Python:

```python
def summarize_orders(orders):
    total_cents = 0
    count_by_status = {}

    for order in orders:
        status = order["status"]
        count_by_status[status] = count_by_status.get(status, 0) + 1
        if status == "cancelled":
            continue
        total_cents += order["amount_cents"]

    return {
        "total_cents": total_cents,
        "count_by_status": count_by_status,
    }
```

Counting and totaling serve one purpose: summarizing the orders.
The cancellation rule stays beside the calculation it affects.
A helper for each assignment would make the reader jump around to reconstruct this operation.
Extract a helper when a calculation becomes a distinct policy worth naming or reusing.
