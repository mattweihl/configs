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

Still valid when modes are truly distinct behaviors: split functions.

```ts
const renderSummaryReport = (data: ReportData): ReportResult => buildSummary(data);
const renderDetailedReport = (data: ReportData): ReportResult => buildDetailed(data);
```

## 4+ Parameters -> Structured Input

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

